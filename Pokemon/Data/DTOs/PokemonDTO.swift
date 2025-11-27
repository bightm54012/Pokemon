//
//  PokemonDTO.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

struct PokemonDTO: Codable {
    let id: Int
    let name: String
    let sprites: Sprites
    let types: [TypeSlot]
    let weight: Int
    let height: Int
    let stats: [StatSlot]

    struct Sprites: Codable {
        let front_default: URL?
    }

    struct TypeSlot: Codable {
        let slot: Int
        let type: NamedResource
    }

    struct NamedResource: Codable {
        let name: String
        let url: String
    }

    struct StatSlot: Codable {
        let base_stat: Int
        let effort: Int
        let stat: NamedResource
    }
}

extension PokemonDTO {
    func toEntity() -> Pokemon {
        let t = types.map { $0.type.name }
        
        func statValue(for name: String) -> Int {
            stats.first(where: { $0.stat.name.lowercased() == name.lowercased() })?.base_stat ?? 0
        }

        return Pokemon(
            id: id,
            name: name.capitalized,
            imageURL: sprites.front_default,
            types: t,
            weight: weight,
            height: height,
            hp: statValue(for: "hp"),
            atk: statValue(for: "attack"),
            def: statValue(for: "defense"),
            spd: statValue(for: "speed")
        )
    }
}
