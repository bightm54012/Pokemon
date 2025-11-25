//
//  PokemonRepository.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation
import Combine

public protocol PokemonRepository {
    func fetchList(limit: Int, offset: Int) async throws -> [Pokemon]
    func fetchDetail(idOrName: String) async throws -> Pokemon
    func fetchTypes() async throws -> [String]
}
