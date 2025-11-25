//
//  PokemonRepositoryImpl.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

public final class PokemonRepositoryImpl: PokemonRepository {
    private let network: NetworkService

    public init(network: NetworkService = .shared) {
        self.network = network
    }

    public func fetchList(limit: Int, offset: Int) async throws -> [Pokemon] {
        let dto: PokemonListDTO = try await network.request(path: "pokemon", queryItems: [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ])
        let entities: [Pokemon] = dto.results.compactMap { item in
            // extract id from url
            let parts = item.url.split(separator: "/")
            let id = parts.compactMap { Int($0) }.last ?? 0
            let imageURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
            return Pokemon(id: id, name: item.name.capitalized, imageURL: imageURL, types: [])
        }
        return entities
    }

    public func fetchDetail(idOrName: String) async throws -> Pokemon {
        let dto: PokemonDTO = try await network.request(path: "pokemon/\(idOrName)")
        return dto.toEntity()
    }

    public func fetchTypes() async throws -> [String] {
        let dto: TypeListDTO = try await network.request(path: "type")
        return dto.results.map { $0.name.capitalized }
    }
}
