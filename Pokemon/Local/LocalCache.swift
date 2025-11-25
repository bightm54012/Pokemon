//
//  LocalCache.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

final class LocalCache {
    static let shared = LocalCache()
    private let folder: URL

    private init() {
        let fm = FileManager.default
        if let dir = fm.urls(for: .cachesDirectory, in: .userDomainMask).first {
            folder = dir.appendingPathComponent("PokemonAppCache", isDirectory: true)
            if !fm.fileExists(atPath: folder.path) {
                try? fm.createDirectory(at: folder, withIntermediateDirectories: true)
            }
        } else {
            folder = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("PokemonAppCache", isDirectory: true)
        }
    }

    func save<T: Encodable>(_ value: T, key: String) throws {
        let url = folder.appendingPathComponent(key).appendingPathExtension("json")
        let data = try JSONEncoder().encode(value)
        try data.write(to: url, options: .atomic)
    }

    func load<T: Decodable>(_ type: T.Type, key: String) throws -> T {
        let url = folder.appendingPathComponent(key).appendingPathExtension("json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func exists(key: String) -> Bool {
        let url = folder.appendingPathComponent(key).appendingPathExtension("json")
        return FileManager.default.fileExists(atPath: url.path)
    }

    func remove(key: String) throws {
        let url = folder.appendingPathComponent(key).appendingPathExtension("json")
        try FileManager.default.removeItem(at: url)
    }
}
