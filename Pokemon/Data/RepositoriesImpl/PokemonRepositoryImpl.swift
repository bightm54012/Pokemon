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

    // Pokemon
    public func fetchList(limit: Int, offset: Int) async throws -> [Pokemon] {
        let dto: PokemonListDTO = try await network.request(path: "pokemon", queryItems: [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ])
        
        var entities: [Pokemon] = []
        
        // 串每個 Pokemon 的詳細資料
        for item in dto.results {
            let parts = item.url.split(separator: "/")
            let id = parts.compactMap { Int($0) }.last ?? 0
            do {
                let detailDTO: PokemonDTO = try await network.request(path: "pokemon/\(id)")
                entities.append(detailDTO.toEntity())
            } catch {
                // 如果抓 detail 失敗， fallback 用簡單資料
                let imageURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
                entities.append(Pokemon(id: id, name: item.name.capitalized, imageURL: imageURL, types: [], weight: 0, height: 0, hp: 0, atk: 0, def: 0, spd: 0))
            }
        }
        
        return entities
    }
    
    public func fetchDetail(idOrName: String) async throws -> Pokemon {
        let dto: PokemonDTO = try await network.request(path: "pokemon/\(idOrName)")
        return dto.toEntity()
    }

    // Type
    public func fetchTypes() async throws -> [String] {
        let dto: TypeListDTO = try await network.request(path: "type")
        return dto.results.map { $0.name.capitalized }
    }
    
    // Region
    public func fetchRegionsList() async throws -> [Region] {
        let dto: NamedAPIResourceList = try await network.request(path: "region")
        return dto.results.map { Region(name: $0.name, url: $0.url) }
    }
    
    // Internal detail fetch (optional)
    func fetchRegionDetail(name: String) async throws -> RegionDetailDTO {
        let dto: RegionDetailDTO = try await network.request(path: "region/\(name)")
        return dto
    }
}
