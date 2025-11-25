//
//  FetchPokemonDetailUseCase.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

public final class FetchPokemonDetailUseCase {
    private let repository: PokemonRepository
    public init(repository: PokemonRepository) {
        self.repository = repository
    }

    public func execute(idOrName: String) async throws -> Pokemon {
        return try await repository.fetchDetail(idOrName: idOrName)
    }
}
