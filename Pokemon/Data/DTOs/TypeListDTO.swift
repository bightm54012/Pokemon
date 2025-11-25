//
//  TypeListDTO.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

struct TypeListDTO: Decodable {
    struct Item: Decodable { let name: String; let url: String }
    let results: [Item]
}
