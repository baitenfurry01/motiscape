# motiscape

<p align="center">
  <img src="Mirage/Mirage%20Wallpaper/Resources/Assets.xcassets/AppIcon.appiconset/icon_256.png" width="128" alt="motiscape icon">
</p>

A native live wallpaper manager for macOS, developed by BaiTenG on top of [MirageWallpaper](https://github.com/laobamac/MirageWallpaper).

[简体中文](README.md) · English

## Features

- Scene, web and video wallpapers with separate renderer processes and multi-display support.
- Local imports, library search, sorting, filters, favorites and playlists.
- Steam Workshop discovery, subscriptions and wallpaper downloads.
- Native SwiftUI / AppKit interface, screen saver and dynamic lock screen integration.
- Workshop safe mode enabled by default, restricting content ratings to Everyone.

Wallpaper Engine scene compatibility is still evolving; some effects, scripts and materials may render differently. Downloads still use client-side Steam login. This is not an official Valve or Wallpaper Engine client.

## Requirements

- macOS 14.2 or later. The native dynamic lock screen extension requires macOS 26 or later.
- Apple Silicon and Intel Macs; local builds target the host architecture by default.
- Xcode with the macOS 26 SDK or later, Homebrew, CMake 4.3.1+, LLVM 22 and the .NET 10 SDK for a full build.

## Build from source

```bash
git clone https://github.com/baitenfurry01/motiscape.git
cd motiscape
brew install cmake ninja pkg-config llvm@22 molten-vk vulkan-loader vulkan-headers glslang glfw freetype fontconfig lz4 dav1d nasm
```

Install the .NET 10 SDK separately and ensure `dotnet`, Homebrew's `cmake` and `ninja` are on PATH. The first build needs network access for Swift / NuGet dependencies and the FFmpeg / MoltenVK sources selected by the build scripts.

```bash
bash scripts/build_all.sh
```

The default configuration is Release, producing `Mirage/dist/motiscape.app`. Local builds use ad-hoc signing by default; they are not Developer ID signed or notarized automatically.

```bash
bash scripts/build_all.sh renderers  # Build only the three renderers
bash scripts/build_all.sh app        # Build/package the app using existing renderers
bash scripts/build_ui.sh             # UI-only build, not a complete distributable player
```

This repository has an independent Git history. The default build number is its commit count; set `MIRAGE_BUILD_NUMBER` to a monotonically increasing value when continuing a previous release series. Users can configure a Steam Web API Key in the app without storing credentials in source code.

## Source layout

| Directory | Contents |
| --- | --- |
| `Mirage/` | macOS app, login item, screen saver, wallpaper extension and packaging scripts |
| `SceneRenderer/` | Scene renderer and required third-party sources |
| `WebRenderer/` | Web wallpaper renderer |
| `VideoRenderer/` | Video wallpaper renderer |
| `SteamService/` | Steam authentication and download service |
| `assets/` | Runtime shaders, materials, fonts and other resources |
| `scripts/` | Build entry points and dependency builders |

Internal project, target and source names are preserved to keep existing build/runtime behavior. Default user data is stored in `~/Library/Application Support/motiscape`, with caches in `~/Library/Caches/motiscape`.

This independent source snapshot comes from commit `ce1f349b8e830566a0f158d50dfff481825f4824` on the `iconchange` branch of `baitenfurry01/macwallpaperengine`. Historical development documents, design drafts, the old website, previous CI workflows, test suites and test scripts have been removed. Old Git history, local build products and caches are not included.

## Authors and license

- Project developer: **BaiTenG**.
- Original authors: **Xiaoci Wang** ([@laobamac](https://github.com/laobamac)) and **Jiale Yu** ([@dawalishi821](https://github.com/dawalishi821)).
- Upstream: [laobamac/MirageWallpaper](https://github.com/laobamac/MirageWallpaper).

This project and its upstream are open source under [GPLv3](LICENSE). Original copyright notices and third-party LICENSE, COPYING and NOTICE files are retained. Third-party components remain subject to their respective licenses. Wallpaper artwork belongs to its respective creators.
