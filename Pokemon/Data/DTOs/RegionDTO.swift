//
//  RegionDTO.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/26.
//

import Foundation

struct NamedAPIResource: Decodable {
    let name: String
    let url: String
}

struct NamedAPIResourceList: Decodable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [NamedAPIResource]
}

struct RegionDetailDTO: Decodable {
    let id: Int
    let locations: [NamedAPIResource]
}
