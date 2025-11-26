//
//  RegionDTO.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/26.
//

import Foundation

public struct Region {
    public let name: String
    public let url: String

    public init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}

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
