//
//  Mirage Wallpaper
//
//  Copyright © 2026 王孝慈. All rights reserved.
//

import Cocoa

AppIntegrationFixture.validateInvocation()
if AppIntegrationFixture.isLibraryUI {
    // Register this actual app, not a sandbox-exec wrapper, before restricting
    // local UI tests. No business model has been initialized at this point.
    _ = NSApplication.shared
    AppIntegrationFixture.installLibrarySandbox()
}
AppIntegrationFixture.record("entry")
if WEConditionEvaluator.runWorkerIfRequested() { exit(0) }

let mirageOpenWindowNotification = Notification.Name("com.BaiTenG.motiscape.openMainWindow")
let mirageLaunchAtLogin = ProcessInfo.processInfo.arguments.contains("--launch-at-login")

if let bundleID = Bundle.main.bundleIdentifier,
   NSWorkspace.shared.runningApplications.contains(where: {
       $0.bundleIdentifier == bundleID &&
       $0.processIdentifier != ProcessInfo.processInfo.processIdentifier
   }) {
    if !mirageLaunchAtLogin && !AppIntegrationFixture.isEnabled {
        DistributedNotificationCenter.default().postNotificationName(
            mirageOpenWindowNotification, object: nil, userInfo: nil, deliverImmediately: true)
    }
    exit(0)
}

if !AppIntegrationFixture.isEnabled {
    let defaults = UserDefaults.standard
    if !defaults.bool(forKey: "motiscape.brandingMigration.v1") {
        if NSWorkspace.shared.runningApplications.contains(where: {
            ["com.BaiTenG.wallpaperformacos", "com.BaiTenG.wallpaperformacos.Development",
             "cn.laobamac.Mirage", "cn.laobamac.Mirage.Development"].contains($0.bundleIdentifier ?? "")
        }) {
            let alert = NSAlert()
            alert.messageText = "motiscape"
            alert.informativeText = L("请先退出旧版本，再打开本项目以迁移数据。")
            alert.runModal()
            exit(1)
        }
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        do {
            #if DEBUG
            let domainSuffix = ".Development"
            #else
            let domainSuffix = ""
            #endif
            // Prefer the latest predecessor. Only use the original project as a
            // fallback; never bring deleted wallpapers back from an older backup.
            let previousBrand = FileManager.default.fileExists(atPath: support.appending(path: "wallpaperformacos").path)
                || defaults.persistentDomain(forName: "com.BaiTenG.wallpaperformacos" + domainSuffix) != nil
            let migration = BrandingMigration(
                oldRoot: support.appending(path: previousBrand ? "wallpaperformacos" : "Mirage"),
                newRoot: support.appending(path: "motiscape"))
            try migration.copyData()
            try LibraryIndexActor.rebrandMetadata(
                directory: migration.newRoot.appending(path: "LibraryMetadata"),
                path: migration.path, payload: migration.payload)
            try migration.migrateDefaults(defaults, oldDomain:
                (previousBrand ? "com.BaiTenG.wallpaperformacos" : "cn.laobamac.Mirage") + domainSuffix)
            // Credentials intentionally start fresh. Do not query old Keychain services.
            defaults.set(true, forKey: "motiscape.brandingMigration.v1")
        } catch {
            let alert = NSAlert()
            alert.messageText = "motiscape"
            alert.informativeText = L("旧版本数据迁移未完成，原数据已保留。请解决以下问题后重新打开：%@", error.localizedDescription)
            alert.runModal()
            exit(1)
        }
    }
}

if LibraryMetadataRecovery.needsMaintenanceStartup {
    AppIntegrationFixture.record("maintenance-route")
    // Do not even initialize the production delegate's eager business models.
    let maintenanceDelegate = MainActor.assumeIsolated { LibraryMetadataRecoveryAppDelegate() }
    NSApplication.shared.delegate = maintenanceDelegate
    withExtendedLifetime(maintenanceDelegate) { NSApplication.shared.run() }
    exit(0)
}

if AppIntegrationFixture.isEnabled && !AppIntegrationFixture.isLibraryUI { AppIntegrationFixture.runReopenProbe() }

NSApplication.shared.delegate = AppDelegate.shared
NSApplication.shared.run()
