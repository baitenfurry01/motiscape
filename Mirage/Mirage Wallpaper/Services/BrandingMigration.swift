import Foundation

/// Copies the previous app's data once. The original directory is kept intact.
/// Only app-owned metadata is rewritten; wallpaper content and log bodies are not.
struct BrandingMigration {
    let oldRoot: URL
    let newRoot: URL
    private let fm = FileManager.default

    func path(_ value: String) -> String {
        var result = value
        let cache = fm.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let oldCache = cache.appending(path: oldRoot.lastPathComponent)
        let newCache = cache.appending(path: newRoot.lastPathComponent)
        for (old, new) in [(oldRoot.path, newRoot.path),
                           (oldRoot.absoluteString, newRoot.absoluteString),
                           (oldCache.path, newCache.path),
                           (oldCache.absoluteString, newCache.absoluteString)] {
            if result == old { return new }
            let prefix = old.hasSuffix("/") ? old : old + "/"
            let replacement = new.hasSuffix("/") ? new : new + "/"
            result = result.replacingOccurrences(of: prefix, with: replacement)
        }
        return result
    }

    func value(_ object: Any) throws -> Any {
        if let string = object as? String { return path(string) }
        if let array = object as? [Any] { return try array.map(value) }
        if let dictionary = object as? [String: Any] {
            var result: [String: Any] = [:]
            for (key, item) in dictionary { result[path(key)] = try value(item) }
            return result
        }
        if let data = object as? Data,
           let object = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) {
            return try JSONSerialization.data(withJSONObject: value(object), options: [.sortedKeys, .fragmentsAllowed])
        }
        return object
    }

    func payload(_ data: Data) throws -> Data {
        let object = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        return try JSONSerialization.data(withJSONObject: value(object), options: [.sortedKeys, .fragmentsAllowed])
    }

    func copyData() throws {
        guard fm.fileExists(atPath: oldRoot.path) else { return }
        try fm.createDirectory(at: newRoot, withIntermediateDirectories: true)
        for item in try fm.contentsOfDirectory(at: oldRoot, includingPropertiesForKeys: nil) {
            // Cached copies of installed helpers are not user data. The new app
            // installs its own correctly named/signed components when requested.
            guard item.lastPathComponent != "Components" else { continue }
            try copyMissing(from: item, to: newRoot.appendingPathComponent(item.lastPathComponent))
        }
        // Root JSON files belong to the app (playlists, library additions, saver config).
        for url in try fm.contentsOfDirectory(at: newRoot, includingPropertiesForKeys: nil)
            where url.pathExtension == "json" {
            try rewriteJSON(url)
        }
        // Wallpaper assets must not be rewritten. Only our transaction marker changes.
        for name in ["Wallpapers", "Workshop"] {
            let root = newRoot.appendingPathComponent(name)
            guard let items = fm.enumerator(at: root, includingPropertiesForKeys: [.isSymbolicLinkKey]) else { continue }
            for case let url as URL in items {
                if try url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink == true {
                    items.skipDescendants()
                    continue
                }
                guard [".mirage-import.json", ".wallpaperformacos-import.json", ".motiscape-import.json"]
                    .contains(url.lastPathComponent) else { continue }
                let target = url.deletingLastPathComponent().appendingPathComponent(".motiscape-import.json")
                if url == target {
                    try rewriteJSON(url)
                    continue
                }
                if !fm.fileExists(atPath: target.path) {
                    try payload(Data(contentsOf: url)).write(to: target, options: .atomic)
                }
                try fm.removeItem(at: url) // Only the copied marker, never the original library.
            }
        }
    }

    private func copyMissing(from source: URL, to destination: URL) throws {
        if !fm.fileExists(atPath: destination.path) {
            try fm.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
            try fm.copyItem(at: source, to: destination)
            return
        }
        let values = try source.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard values.isDirectory == true, values.isSymbolicLink != true else { return }
        for item in try fm.contentsOfDirectory(at: source, includingPropertiesForKeys: nil) {
            try copyMissing(from: item, to: destination.appendingPathComponent(item.lastPathComponent))
        }
    }

    private func rewriteJSON(_ url: URL) throws {
        let original = try Data(contentsOf: url)
        let updated = try payload(original)
        if original != updated { try updated.write(to: url, options: .atomic) }
    }

    func migrateDefaults(_ defaults: UserDefaults, oldDomain: String) throws {
        for (key, item) in defaults.persistentDomain(forName: oldDomain) ?? [:] {
            let newKey = path(key)
            if defaults.object(forKey: newKey) == nil { defaults.set(try value(item), forKey: newKey) }
        }
    }
}
