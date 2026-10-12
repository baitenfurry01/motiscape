//
//  Mirage Wallpaper
//
//  Copyright © 2026 王孝慈. All rights reserved.
//

import SwiftUI

struct FirstLaunchView: View {
    @Environment(GlobalSettingsViewModel.self) private var globalSettingsViewModel
    
    @ObservedObject private var localization = MirageLocalization.shared
    @State var checked = !(UserDefaults.standard.object(forKey: "IsFirstLaunch") as? Bool ?? true)
    @State private var guidePage: OnboardingPage?
    @State private var welcomeContentHeight: CGFloat = 440
    
    var body: some View {
        Group {
            if let guidePage {
                OnboardingGuideView(page: guidePage,
                                    onBack: goBack, onNext: goNext, onFinish: finish)
            } else {
                welcomeContent
            }
        }
        .environment(\.locale, localization.locale)
    }

    private var welcomeContent: some View {
        VStack(spacing: 12) {
            VStack(spacing: 5) {
                Text(L("欢迎使用 Mirage"))
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Divider()
            }
            ScrollView {
                VStack(spacing: 24) {
                    NewSection(title: "三类壁纸，一站渲染",
                               text: "支持 Wallpaper Engine 的场景、网页、视频三类壁纸，由专用引擎以独立进程渲染到桌面，兼顾画质与稳定。",
                               systemImage: "square.stack.3d.up",
                               imageColor: .purple)
                    NewSection(title: "自动加载创意工坊壁纸",
                               text: "自动读取 Steam 创意工坊已订阅的壁纸，也可将本地文件夹或视频导入到 Mirage 自有壁纸库。",
                               systemImage: "square.and.arrow.down")
                    NewSection(title: "熟悉的界面布局",
                               text: "沿用 Wallpaper Engine 的界面布局，上手无门槛，并针对 macOS 做了本地化与视觉优化。",
                               systemImage: "macwindow.on.rectangle",
                               imageColor: .yellow)
                    NewSection(title: "实时属性调节",
                               text: "根据壁纸自带的属性动态生成调节控件，音量、速度、颜色、开关等即改即生效。",
                               systemImage: "slider.horizontal.3",
                               imageColor: .green)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .padding(.horizontal, 24)
                .background {
                    GeometryReader { geometry in
                        Color.clear.preference(key: WelcomeContentHeightKey.self, value: geometry.size.height)
                    }
                }
            }
            .frame(height: min(welcomeContentHeight, 440))
            .onPreferenceChange(WelcomeContentHeightKey.self) { height in
                if height > 0 { welcomeContentHeight = height }
            }
            Button {
                globalSettingsViewModel.saveWelcomePreference(dontShowAgain: checked)
                guidePage = .library
            } label: {
                Text(L("下一步"))
                    .frame(minWidth: 100)
            }
            .buttonStyle(.borderedProminent)
            HStack {
                Toggle(L("不再显示"), isOn: $checked)
                Spacer()
            }
        }
        .textSelection(.enabled)
        .padding()
        .frame(width: 600)
        .environment(\.locale, localization.locale)
    }

    private func goBack() {
        guidePage = guidePage.flatMap { OnboardingPage(rawValue: $0.rawValue - 1) }
    }

    private func goNext() {
        guard let page = guidePage else { return }
        guidePage = OnboardingPage(rawValue: page.rawValue + 1) ?? page
    }

    private func finish() {
        globalSettingsViewModel.finishWelcome(dontShowAgain: checked)
    }

}

private struct WelcomeContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

extension FirstLaunchView {
    struct NewSection: View {
        @ObservedObject private var localization = MirageLocalization.shared
        var title: String
        var text: String
        var textColor: Color = .primary
        var systemImage: String
        var imageColor: Color = .accentColor
        
        var body: some View {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: systemImage)
                    .frame(width: 50, height: 50)
                    .font(.largeTitle)
                    .foregroundStyle(imageColor)
                VStack(alignment: .leading) {
                    Text(L(title))
                        .foregroundStyle(textColor)
                        .font(.title2)
                        .bold()
                    Text(L(text))
                        .foregroundStyle(textColor)
                }
                .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
        }
    }
}

extension AppDelegate {
    @objc func showQuickStartGuide() {
        openMainWindow()
        globalSettingsViewModel.presentWelcome()
    }

    @objc func resetFirstLaunch() {
        UserDefaults.standard.set(true, forKey: "IsFirstLaunch")
    }
}

struct FirstLaunchView_Previews: PreviewProvider {
    static var previews: some View {
        FirstLaunchView()
    }
}
