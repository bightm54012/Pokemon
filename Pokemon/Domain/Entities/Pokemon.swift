//
//  Pokemon.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

public struct Pokemon: Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let imageURL: URL?
    public let types: [String]

    public init(id: Int, name: String, imageURL: URL?, types: [String]) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.types = types
    }
}
