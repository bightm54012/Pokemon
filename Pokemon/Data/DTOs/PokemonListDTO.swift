//
//  PokemonListDTO.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

struct PokemonListDTO: Decodable {
    struct ResultItem: Decodable {
        let name: String
        let url: String
    }
    let count: Int
    let next: String?
    let previous: String?
    let results: [ResultItem]
}
