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

## 作者与许可证

- 本项目开发者：**BaiTenG**。
- 原项目作者：**Xiaoci Wang**（[@laobamac](https://github.com/laobamac)）、**Jiale Yu**（[@dawalishi821](https://github.com/dawalishi821)）。
- 原项目：[laobamac/MirageWallpaper](https://github.com/laobamac/MirageWallpaper)。

本项目与原项目均遵守 [GPLv3](LICENSE) 协议开源。原作者版权声明及第三方依赖的 LICENSE、COPYING、NOTICE 等文件予以保留；第三方组件另遵循各自许可证。壁纸作品的版权属于各自作者。
