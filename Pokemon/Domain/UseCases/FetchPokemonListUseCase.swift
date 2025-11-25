//
//  FetchPokemonListUseCase.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

public final class FetchPokemonListUseCase {
    private let repo: PokemonRepository
    public init(repository: PokemonRepository) { self.repo = repository }

    public func execute(limit: Int = 20, offset: Int = 0) async throws -> [Pokemon] {
        return try await repo.fetchList(limit: limit, offset: offset)
    }
}
