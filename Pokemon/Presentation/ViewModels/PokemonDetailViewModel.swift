//
//  PokemonDetailViewModel.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published var pokemon: Pokemon?
    @Published var isLoading = false
    @Published var error: Error?

    private let repo: PokemonRepository
    private let idOrName: String

    init(repo: PokemonRepository = PokemonRepositoryImpl(), idOrName: String) {
        self.repo = repo
        self.idOrName = idOrName
    }

    func load() async {
        guard pokemon == nil else { return }
        isLoading = true
        do {
            let p = try await repo.fetchDetail(idOrName: idOrName)
            pokemon = p
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
