//
//  FavoritesManager.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

final class FavoritesManager {
    static let shared = FavoritesManager()
    private let key = "favorites"
    private var cache: Set<Int>

    private init() {
        if let arr = UserDefaults.standard.array(forKey: key) as? [Int] {
            cache = Set(arr)
        } else { cache = [] }
    }

    func isFavorite(id: Int) -> Bool { cache.contains(id) }
    func toggleFavorite(id: Int) {
        if cache.contains(id) { cache.remove(id) } else { cache.insert(id) }
        UserDefaults.standard.set(Array(cache), forKey: key)
    }
}
