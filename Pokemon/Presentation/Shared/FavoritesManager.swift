//
//  FavoritesManager.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import SwiftUI
import Combine

final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published private(set) var favoriteIDs: Set<Int>
    private let key = "favorites"
    
    private init() {
        if let arr = UserDefaults.standard.array(forKey: key) as? [Int] {
            favoriteIDs = Set(arr)
        } else {
            favoriteIDs = []
        }
    }
    
    func isFavorite(id: Int) -> Bool {
        favoriteIDs.contains(id)
    }
    
    func toggleFavorite(id: Int) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        UserDefaults.standard.set(Array(favoriteIDs), forKey: key)
    }
}
