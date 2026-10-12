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

## Authors and license

- Project developer: **BaiTenG**.
- Original authors: **Xiaoci Wang** ([@laobamac](https://github.com/laobamac)) and **Jiale Yu** ([@dawalishi821](https://github.com/dawalishi821)).
- Upstream: [laobamac/MirageWallpaper](https://github.com/laobamac/MirageWallpaper).

This project and its upstream are open source under [GPLv3](LICENSE). Original copyright notices and third-party LICENSE, COPYING and NOTICE files are retained. Third-party components remain subject to their respective licenses. Wallpaper artwork belongs to its respective creators.
