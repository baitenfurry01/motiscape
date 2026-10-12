//
//  Mirage Wallpaper
//
//  Copyright © 2026 王孝慈. All rights reserved.
//

import Cocoa
import SwiftUI

protocol SettingsPage: View {
    var viewModel: GlobalSettingsViewModel { get set }

    init(globalSettings: GlobalSettingsViewModel)
}

struct SettingsView: View {
    @Environment(GlobalSettingsViewModel.self) var viewModel
    @ObservedObject private var localization = MirageLocalization.shared

    // Compares against an in-memory snapshot of the last-saved settings instead
    // of decoding GlobalSettings JSON from UserDefaults on every footer render.
    private var hasUnsavedChanges: Bool {
        viewModel.settings != viewModel.savedSettings || viewModel.isResetAllPending
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if viewModel.selection == 4 {
                    VStack(spacing: 0) {
                        HStack {
                            Button {
                                viewModel.selection = 1
                            } label: {
                                Label(L("返回"), systemImage: "chevron.left")
                            }
                            .accessibilityIdentifier("settings.about.back")
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        AboutUsView()
                    }
                } else {
                    settingsTabs
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            footer
        }
        .frame(minWidth: 720, idealWidth: 780, minHeight: 520, idealHeight: 620)
        .environment(\.locale, localization.locale)
    }

    private var settingsTabs: some View {
        @Bindable var viewModel = viewModel
        return TabView(selection: $viewModel.selection) {
            GeneralPage(globalSettings: viewModel)
                .tabItem { Label(L("通用"), systemImage: "gearshape") }.tag(1)
            PerformancePage(globalSettings: viewModel)
                .tabItem { Label(L("性能"), systemImage: "speedometer") }.tag(0)
            PluginsPage(globalSettings: viewModel)
                .tabItem { Label(L("插件"), systemImage: "puzzlepiece.extension") }.tag(2)
            ScreenSaverPage(globalSettings: viewModel)
                .tabItem { Label(L("屏保"), systemImage: "sparkles.tv") }.tag(3)
        }
    }

    private var footer: some View {
        HStack {
            if hasUnsavedChanges {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.yellow)
                Text("已修改")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                AppDelegate.shared.closeSettingsWindow(commit: false)
            } label: {
                Text("取消").frame(width: 50)
            }
            .keyboardShortcut(.cancelAction)
            Button {
                AppDelegate.shared.closeSettingsWindow(commit: true)
            } label: {
                Text("好").frame(width: 50)
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
            .disabled(viewModel.settings.httpProxy?.enabled == true && viewModel.settings.httpProxy?.isValid != true)
        }
        .padding(20)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment({ () -> GlobalSettingsViewModel in
                let viewModel = GlobalSettingsViewModel()
                viewModel.selection = 2
                return viewModel
            }())
            .frame(width: 780, height: 620)
    }
}
