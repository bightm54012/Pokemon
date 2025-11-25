//
//  PokemonListViewModel.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

@MainActor
final class PokemonListViewModel: ObservableObject {
    @Published private(set) var pokemons: [Pokemon] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repo: PokemonRepository
    private var offset = 0
    private let limit = 20
    private var canLoadMore = true

    init(repo: PokemonRepository = PokemonRepositoryImpl()) {
        self.repo = repo
    }

    func loadInitial() async {
        guard pokemons.isEmpty else { return }
        await loadMore()
    }

    func loadMore() async {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        do {
            let list = try await repo.fetchList(limit: limit, offset: offset)
            pokemons += list
            offset += list.count
            canLoadMore = list.count == limit
        } catch {
            errorMessage = error.localizedDescription
            canLoadMore = false
        }
        isLoading = false
    }
}
