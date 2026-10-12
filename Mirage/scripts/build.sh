#!/bin/bash
set -euo pipefail

CONFIG="${1:-Release}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_DIR="$(cd "$HERE/.." && pwd)"
ROOT="$(cd "$PROJ_DIR/.." && pwd)"
BUILD_DIR="$PROJ_DIR/build"
OUT="${MIRAGE_OUTPUT_DIR:-$PROJ_DIR/dist}"
# An explicit output is a new candidate, never a replacement of a running app.
validate_candidate_output() {
    if [ -n "${MIRAGE_OUTPUT_DIR:-}" ]; then
        case "$OUT" in
            /*) ;;
            *) echo "[build] MIRAGE_OUTPUT_DIR 必须为绝对路径" >&2; exit 1 ;;
        esac
        if [ -e "$OUT/motiscape.app" ] || [ -L "$OUT/motiscape.app" ]; then
            echo "[build] 独立输出中已有 App，拒绝覆盖：$OUT/motiscape.app" >&2
            exit 1
        fi
    fi
}
validate_candidate_output
PROJECT="$PROJ_DIR/Mirage Wallpaper.xcodeproj"
SCHEME="Mirage Wallpaper"
TARGET_ARCH="${MIRAGE_ARCH:-$(uname -m)}"
STEAM_API_KEY="${MIRAGE_STEAM_WEB_API_KEY:-}"
GIT_COMMIT="${MIRAGE_GIT_COMMIT:-$(git -C "$ROOT" rev-parse HEAD)}"
BUILD_NUMBER="${MIRAGE_BUILD_NUMBER:-$(git -C "$ROOT" rev-list --count HEAD)}"
LOCAL_SECRET="$ROOT/.secrets/steam_web_api_key"
TEMP_XCCONFIG=""
SIGN_IDENTITY="${MIRAGE_SIGN_IDENTITY:--}"
# Local packaging signs the assembled bundle after renderers are embedded.
# Xcode 27 otherwise requires a provisioning profile for the Release extension
# even with CODE_SIGNING_REQUIRED=NO and an ad-hoc identity. Do not weaken the
# separately authorized Developer ID/profile path.
XCODE_SIGNING_ALLOWED=YES
if [ "$SIGN_IDENTITY" = "-" ]; then
    XCODE_SIGNING_ALLOWED=NO
fi
DEVELOPMENT_TEAM="${MIRAGE_DEVELOPMENT_TEAM:-}"
NOTARY_PROFILE="${MIRAGE_NOTARY_PROFILE:-}"
NOTARY_KEYCHAIN="${MIRAGE_NOTARY_KEYCHAIN:-}"
NOTARY_TEMP_DIR=""

case "$TARGET_ARCH" in
    arm64|x86_64) ;;
    *) echo "[build] 不支持的更新架构: $TARGET_ARCH" >&2; exit 1 ;;
esac

[[ "$GIT_COMMIT" =~ ^[A-Fa-f0-9]{40}$ ]] || {
    echo "[build] MIRAGE_GIT_COMMIT 必须是完整 Git commit SHA" >&2
    exit 1
}
[[ "$BUILD_NUMBER" =~ ^[1-9][0-9]*$ ]] || {
    echo "[build] MIRAGE_BUILD_NUMBER 必须是正整数" >&2
    exit 1
}

if [ -z "$STEAM_API_KEY" ] && [ -f "$LOCAL_SECRET" ]; then
    IFS= read -r STEAM_API_KEY < "$LOCAL_SECRET"
fi

XCCONFIG_ARGS=()
TEMP_XCCONFIG="$(mktemp -t mirage-build-settings)"
chmod 600 "$TEMP_XCCONFIG"
printf 'CURRENT_PROJECT_VERSION = %s\n' "$BUILD_NUMBER" >> "$TEMP_XCCONFIG"
printf 'MIRAGE_GIT_COMMIT = %s\n' "$GIT_COMMIT" >> "$TEMP_XCCONFIG"
printf 'MIRAGE_UPDATE_ARCH = %s\n' "$TARGET_ARCH" >> "$TEMP_XCCONFIG"
if [ "$SIGN_IDENTITY" != "-" ]; then
    [ -n "$DEVELOPMENT_TEAM" ] || { echo "[build] 正式签名需要 MIRAGE_DEVELOPMENT_TEAM" >&2; exit 1; }
    printf 'ENABLE_HARDENED_RUNTIME = YES\n' >> "$TEMP_XCCONFIG"
fi
XCCONFIG_ARGS=(-xcconfig "$TEMP_XCCONFIG")
if [ -n "$STEAM_API_KEY" ]; then
    [[ "$STEAM_API_KEY" =~ ^[A-Fa-f0-9]{32}$ ]] || {
        echo "[build] Steam Web API Key 必须是 32 位十六进制字符" >&2
        exit 1
    }
    printf 'MIRAGE_STEAM_WEB_API_KEY = %s\n' "$STEAM_API_KEY" >> "$TEMP_XCCONFIG"
else
    echo "[build] 未提供内置 Steam Web API Key；App 仍可构建，用户需在设置中填写自己的 Key" >&2
fi

cleanup() {
    [ -z "$TEMP_XCCONFIG" ] || rm -f "$TEMP_XCCONFIG"
    [ -z "$NOTARY_TEMP_DIR" ] || rm -rf "$NOTARY_TEMP_DIR"
    if [ -n "${APP:-}" ]; then
        rm -rf "$APP" "$BUILD_DIR/DD/Build/Products/$CONFIG/motiscapeWallpaperExtension.appex"
    fi
}
trap cleanup EXIT

APP="$BUILD_DIR/DD/Build/Products/$CONFIG/motiscape.app"

if [ -d "$APP/Contents/Resources/Renderers" ]; then
    echo "[build] 清理旧构建塞进产物里的渲染器残留..."
    rm -rf "$APP"
fi

mkdir -p "$BUILD_DIR"
BUILD_LOG="$BUILD_DIR/xcodebuild-$CONFIG.log"
: > "$BUILD_LOG"
chmod 600 "$BUILD_LOG"

RELEASE_FLAGS=()
if [ "$CONFIG" = Release ]; then
    RELEASE_FLAGS=(ENABLE_CODE_COVERAGE=NO CLANG_COVERAGE_MAPPING=NO DEPLOYMENT_POSTPROCESSING=YES)
fi
echo "[build] 编译 ($CONFIG)..."
if ! xcodebuild "${XCCONFIG_ARGS[@]}" -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIG" \
    -destination 'platform=macOS' \
    -derivedDataPath "$BUILD_DIR/DD" \
    ARCHS="$TARGET_ARCH" ONLY_ACTIVE_ARCH=YES \
    CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED="$XCODE_SIGNING_ALLOWED" \
    ${RELEASE_FLAGS[@]+"${RELEASE_FLAGS[@]}"} \
    build > "$BUILD_LOG" 2>&1; then
    echo "[build] 编译失败，错误摘要:" >&2
    { grep -nE "error:|error extracting|not signed at all|In subcomponent:|failed with a nonzero|The following build commands failed" \
        "$BUILD_LOG" | tail -20 >&2; } || true
    echo "[build] 完整日志: $BUILD_LOG" >&2
    exit 1
fi
tail -3 "$BUILD_LOG"

[ -d "$APP" ] || { echo "[build] 未找到产物: $APP" >&2; exit 1; }

validate_candidate_output
mkdir -p "$OUT"
if [ -z "${MIRAGE_OUTPUT_DIR:-}" ]; then
    rm -rf "$OUT/motiscape.app"
else
    # Reserve the candidate atomically; a concurrent builder cannot merge into
    # or replace a bundle created after the preflight check.
    mkdir "$OUT/motiscape.app"
fi
ditto "$APP" "$OUT/motiscape.app"

echo "[build] 内嵌渲染器与依赖..."
bash "$HERE/bundle_renderers.sh" "$OUT/motiscape.app" "$ROOT" "$SIGN_IDENTITY"

codesign --verify --deep --strict --verbose=2 "$OUT/motiscape.app"
bash "$HERE/report_bundle_size.sh" "$OUT/motiscape.app"

if [ "$SIGN_IDENTITY" != "-" ] && [ -n "$NOTARY_PROFILE" ]; then
    NOTARY_TEMP_DIR="$(mktemp -d -t mirage-notary)"
    ditto -c -k --keepParent "$OUT/motiscape.app" "$NOTARY_TEMP_DIR/Mirage.zip"
    NOTARY_AUTH_ARGS=(--keychain-profile "$NOTARY_PROFILE")
    if [ -n "$NOTARY_KEYCHAIN" ]; then
        NOTARY_AUTH_ARGS+=(--keychain "$NOTARY_KEYCHAIN")
    fi
    NOTARY_RESULT="$NOTARY_TEMP_DIR/result.json"
    if ! xcrun notarytool submit "$NOTARY_TEMP_DIR/Mirage.zip" "${NOTARY_AUTH_ARGS[@]}" --wait --output-format json > "$NOTARY_RESULT"; then
        cat "$NOTARY_RESULT" >&2
        SUBMISSION_ID="$(plutil -extract id raw -o - "$NOTARY_RESULT" 2>/dev/null || true)"
        if [ -n "$SUBMISSION_ID" ]; then
            xcrun notarytool log "$SUBMISSION_ID" "${NOTARY_AUTH_ARGS[@]}" >&2 || true
        fi
        exit 1
    fi
    cat "$NOTARY_RESULT"
    NOTARY_STATUS="$(plutil -extract status raw -o - "$NOTARY_RESULT")"
    if [ "$NOTARY_STATUS" != "Accepted" ]; then
        SUBMISSION_ID="$(plutil -extract id raw -o - "$NOTARY_RESULT")"
        xcrun notarytool log "$SUBMISSION_ID" "${NOTARY_AUTH_ARGS[@]}" >&2 || true
        exit 1
    fi
    xcrun stapler staple "$OUT/motiscape.app"
    xcrun stapler validate "$OUT/motiscape.app"
fi

echo "[build] 完成  产物: $OUT/motiscape.app"
