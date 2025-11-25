//
//  FetchTypesUseCase.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

public final class FetchTypesUseCase {
    private let repo: PokemonRepository
    public init(repository: PokemonRepository) { self.repo = repository }

    public func execute() async throws -> [String] {
        return try await repo.fetchTypes()
    }
}
