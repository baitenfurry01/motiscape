# motiscape

<p align="center">
  <img src="Mirage/Mirage%20Wallpaper/Resources/Assets.xcassets/AppIcon.appiconset/icon_256.png" width="128" alt="motiscape 图标">
</p>

面向 macOS 的原生动态壁纸管理器，基于 [MirageWallpaper](https://github.com/laobamac/MirageWallpaper) 二次开发，由 BaiTenG 维护。

简体中文 · [English](README_EN.md)

## 功能

- 播放场景、网页和视频壁纸，提供独立渲染进程与多显示器支持。
- 导入和管理本地壁纸，支持搜索、排序、筛选、收藏和播放列表。
- 浏览 Steam 创意工坊、发现作品、查看订阅并下载壁纸。
- 提供 SwiftUI / AppKit 原生界面、屏保和动态锁屏集成。
- 创意工坊安全模式默认开启，开启时仅允许“所有人”内容分级。

Wallpaper Engine 场景兼容性仍在完善，部分作品的特效、脚本或材质表现可能不同。Steam 下载仍使用客户端 Steam 登录；本项目不是 Valve 或 Wallpaper Engine 的官方客户端。

## 系统要求

- macOS 14.2 或更高版本；原生动态锁屏扩展需要 macOS 26 或更高版本。
- 支持 Apple Silicon 和 Intel Mac；本地构建默认针对当前机器架构。
- 完整构建需要 Xcode（含 macOS 26 或更高版本 SDK）、Homebrew、CMake 4.3.1+、LLVM 22 和 .NET 10 SDK。

## 从源码构建

```bash
git clone https://github.com/baitenfurry01/motiscape.git
cd motiscape
brew install cmake ninja pkg-config llvm@22 molten-vk vulkan-loader vulkan-headers glslang glfw freetype fontconfig lz4 dav1d nasm
```

另外安装 .NET 10 SDK，并确保 `dotnet`、Homebrew 的 `cmake` 和 `ninja` 位于 PATH 中。首次构建需要联网获取 Swift / NuGet 依赖，以及构建脚本指定的 FFmpeg、MoltenVK 源码。

```bash
bash scripts/build_all.sh
```

默认构建 Release，输出为 `Mirage/dist/motiscape.app`。本地默认使用 ad-hoc 签名，不代表已完成 Developer ID 签名或 Apple 公证。

其他构建方式：

```bash
bash scripts/build_all.sh renderers  # 只构建三个渲染器
bash scripts/build_all.sh app        # 已有渲染器时，仅构建和打包 App
bash scripts/build_ui.sh             # 仅编译 UI，不是可分发的完整播放器
```

此仓库使用独立 Git 历史，默认构建号取当前仓库提交数量。需要延续旧版本构建号时，可通过 `MIRAGE_BUILD_NUMBER` 指定递增的构建号。用户可在 App 中配置 Steam Web API Key，无需将凭据写入源代码。

## 项目结构

| 目录 | 内容 |
| --- | --- |
| `Mirage/` | macOS App、登录项、屏保、动态锁屏扩展和打包脚本 |
| `SceneRenderer/` | 场景渲染器与所需第三方源码 |
| `WebRenderer/` | 网页壁纸渲染器 |
| `VideoRenderer/` | 视频壁纸渲染器 |
| `SteamService/` | Steam 登录与下载服务 |
| `assets/` | 运行所需的着色器、材质、字体等资源 |
| `scripts/` | 构建入口与依赖构建脚本 |

保留原有内部工程、目标及源码文件名，避免影响构建和运行逻辑。用户数据默认位于 `~/Library/Application Support/motiscape`，缓存位于 `~/Library/Caches/motiscape`。

本仓库从 `baitenfurry01/macwallpaperengine` 的 `iconchange` 分支提交 `ce1f349b8e830566a0f158d50dfff481825f4824` 提取为独立源码快照。已移除历史开发文档、设计原稿、旧网站、旧 CI 工作流、测试套件及测试脚本；不包含旧仓库 Git 历史、本地构建产物或缓存。

## 作者与许可证

- 本项目开发者：**BaiTenG**。
- 原项目作者：**Xiaoci Wang**（[@laobamac](https://github.com/laobamac)）、**Jiale Yu**（[@dawalishi821](https://github.com/dawalishi821)）。
- 原项目：[laobamac/MirageWallpaper](https://github.com/laobamac/MirageWallpaper)。

本项目与原项目均遵守 [GPLv3](LICENSE) 协议开源。原作者版权声明及第三方依赖的 LICENSE、COPYING、NOTICE 等文件予以保留；第三方组件另遵循各自许可证。壁纸作品的版权属于各自作者。
