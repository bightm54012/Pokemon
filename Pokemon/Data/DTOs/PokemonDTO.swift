//
//  PokemonDTO.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

struct PokemonDTO: Decodable {
    let id: Int
    let name: String
    let sprites: Sprites
    let types: [TypeSlot]

    struct Sprites: Decodable {
        let front_default: URL?
    }

    struct TypeSlot: Decodable {
        let slot: Int
        let type: NamedResource
    }

    struct NamedResource: Decodable {
        let name: String
        let url: String
    }
}

extension PokemonDTO {
    func toEntity() -> Pokemon {
        let t = types.map { $0.type.name }
        return Pokemon(id: id, name: name.capitalized, imageURL: sprites.front_default, types: t)
    }
}
