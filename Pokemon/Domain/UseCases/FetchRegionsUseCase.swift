//
//  FetchRegionsUseCase.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/26.
//

import Foundation

public final class FetchRegionsUseCase {
    private let repo: PokemonRepository
    public init(repository: PokemonRepository) { self.repo = repository }
    
    public func execute() async throws -> [Region] {
        return try await repo.fetchRegionsList()
    }
}
