//
//  Mirage Wallpaper
//
//  Copyright © 2026 王孝慈. All rights reserved.
//

import SwiftUI

extension AppDelegate {
    @objc func showAboutUs() {
        globalSettingsViewModel.selection = 4
        openSettingsWindow()
    }
}

struct AboutUsView: View {
    @ObservedObject private var localization = MirageLocalization.shared

    private static let developers: [DeveloperCredit] = [
        .init(name: "Xiaoci Wang", username: "laobamac", role: "项目作者 · 开发者"),
        .init(name: "Jiale Yu", username: "dawalishi821", role: "开发者"),
        .init(name: "Pikachu Ren", username: "PIKACHUIM", role: "开发者"),
        .init(name: "Yinan Qin", username: "elysia-best", role: "开发者"),
    ]

    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.3.33"
    }

    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? L("开发构建")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    if let icon = NSImage(named: "AppIcon") {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 80, height: 80)
                    }
                    Text(verbatim: "motiscape")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    Text("macOS 动态壁纸引擎")
                        .foregroundStyle(.secondary)
                    Text(L("版本 %@（构建 %@）", version, build))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                GroupBox {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(verbatim: "BaiTenG").font(.headline)
                            Text("本项目开发者")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(10)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("本项目与原项目均遵守 GPLv3 协议开源。")
                        .font(.callout)
                    Text("以下是原项目作者和 GitHub 链接。")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Self.developers) { developer in
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(verbatim: developer.name).font(.headline)
                                    Text(developer.role)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Link(destination: developer.profileURL) {
                                    Text(verbatim: "@\(developer.username)")
                                }
                                .help(L("打开 %@ 的 GitHub 主页", developer.name))
                            }
                        }
                        Divider()
                        Link(destination: URL(string: "https://github.com/laobamac/MirageWallpaper")!) {
                            Label("原项目 GitHub：MirageWallpaper", systemImage: "link")
                        }
                    }
                    .padding(10)
                } label: {
                    Label("原项目作者", systemImage: "person.3")
                }
            }
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
            .padding(24)
        }
        .textSelection(.enabled)
        .environment(\.locale, localization.locale)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct DeveloperCredit: Identifiable {
    let name: String
    let username: String
    let role: LocalizedStringKey

    var id: String { username }
    var profileURL: URL { URL(string: "https://github.com/\(username)")! }
}

struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View { AboutUsView() }
}
