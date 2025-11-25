//
//  Pokemon.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import SwiftUI
import Foundation

public struct Pokemon: Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let imageURL: URL?
    public let types: [String]
    public let weight: Int
    public let height: Int
    public let hp: Int
    public let atk: Int
    public let def: Int
    public let spd: Int

    public init(
        id: Int,
        name: String,
        imageURL: URL?,
        types: [String],
        weight: Int,
        height: Int,
        hp: Int,
        atk: Int,
        def: Int,
        spd: Int
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.types = types
        self.weight = weight
        self.height = height
        self.hp = hp
        self.atk = atk
        self.def = def
        self.spd = spd
    }
}

extension String {
    var typeColor: Color {
        switch self.lowercased() {
        case "grass":   return Color.green
        case "poison":  return Color.purple
        case "fire":    return Color.red
        case "water":   return Color.blue
        case "bug":     return Color.green.opacity(0.6)
        case "normal":  return Color.gray
        case "electric":return Color.yellow
        case "ground":  return Color.brown
        case "fairy":   return Color.pink
        case "fighting":return Color.red.opacity(0.7)
        case "psychic": return Color.pink.opacity(0.8)
        case "rock":    return Color.brown.opacity(0.7)
        case "ghost":   return Color.purple.opacity(0.7)
        case "ice":     return Color.cyan
        case "dragon":  return Color.indigo
        case "dark":    return Color.black.opacity(0.8)
        case "steel":   return Color.gray.opacity(0.5)
        default:
            return Color.gray.opacity(0.3)
        }
    }
}

public extension Pokemon {

    // Type → color
    static func typeColor(for type: String) -> Color {
        switch type.lowercased() {
        case "grass":     return Color.green
        case "poison":    return Color.purple
        case "fire":      return Color.red
        case "water":     return Color.blue
        case "electric":  return Color.yellow
        case "bug":       return Color.green.opacity(0.6)
        case "normal":    return Color.gray
        case "ground":    return Color.brown
        case "fairy":     return Color.pink
        case "fighting":  return Color.red.opacity(0.7)
        case "psychic":   return Color.pink.opacity(0.8)
        case "rock":      return Color.brown.opacity(0.7)
        case "ghost":     return Color.purple.opacity(0.7)
        case "ice":       return Color.cyan
        case "dragon":    return Color.indigo
        case "dark":      return Color.black.opacity(0.8)
        case "steel":     return Color.gray.opacity(0.5)
        default:          return Color.gray.opacity(0.3)
        }
    }
    
    var typeColors: [Color] {
        types.map { Pokemon.typeColor(for: $0) }
    }
    
    /// 1 type = 單色
    /// 2 type = 漸層
    var headerGradient: LinearGradient {
        if typeColors.count == 1 {
            return LinearGradient(colors: [typeColors[0], typeColors[0]],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        } else {
            return LinearGradient(colors: typeColors,
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        }
    }
}

// Color from hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
