//
//  PokemonRepositoryTests.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/27.
//

import XCTest
@testable import Pokemon

final class PokemonRepositoryImplTests: XCTestCase {

    func makeMockSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    func test_fetchList_success() async throws {
        // 1st API: Pokemon list
        let resultItem = PokemonListDTO.ResultItem(name: "pikachu", url: "https://pokeapi.co/api/v2/pokemon/25")
        let listDTO = PokemonListDTO(count: 1, next: nil, previous: nil, results: [resultItem])
        let listData = try JSONEncoder().encode(listDTO)

        // 2nd API: Pokemon detail
        let detailDTO = PokemonDTO(
            id: 25,
            name: "pikachu",
            sprites: .init(front_default: URL(string: "https://pokeapi.co/media/sprites/pikachu.png")),
            types: [
                .init(slot: 1, type: .init(name: "electric", url: "https://pokeapi.co/api/v2/type/13"))
            ],
            weight: 60,
            height: 4,
            stats: [
                .init(base_stat: 35, effort: 0, stat: .init(name: "hp", url: "")),
                .init(base_stat: 55, effort: 0, stat: .init(name: "attack", url: "")),
                .init(base_stat: 40, effort: 0, stat: .init(name: "defense", url: "")),
                .init(base_stat: 90, effort: 0, stat: .init(name: "speed", url: ""))
            ]
        )
        let detailData = try JSONEncoder().encode(detailDTO)

        var callCount = 0
        MockURLProtocol.requestHandler = { _ in
            callCount += 1
            if callCount == 1 {
                return (listData, 200)
            } else {
                return (detailData, 200)
            }
        }

        let repo = PokemonRepositoryImpl(network: NetworkService(session: makeMockSession()))
        let result = try await repo.fetchList(limit: 20, offset: 0)

        XCTAssertEqual(result.count, 1)
        let pokemon = result.first!
        XCTAssertEqual(pokemon.id, 25)
        XCTAssertEqual(pokemon.name, "Pikachu")
        XCTAssertEqual(pokemon.imageURL?.absoluteString,
                       "https://pokeapi.co/media/sprites/pikachu.png")
        XCTAssertEqual(pokemon.types, ["electric"])
        XCTAssertEqual(pokemon.weight, 60)
        XCTAssertEqual(pokemon.height, 4)
        XCTAssertEqual(pokemon.hp, 35)
        XCTAssertEqual(pokemon.atk, 55)
        XCTAssertEqual(pokemon.def, 40)
        XCTAssertEqual(pokemon.spd, 90)
    }

    func test_fetchDetail_success() async throws {
        let detailDTO = PokemonDTO(
            id: 1,
            name: "bulbasaur",
            sprites: .init(front_default: URL(string: "https://pokeapi.co/media/sprites/bulbasaur.png")),
            types: [.init(slot: 1, type: .init(name: "grass", url: ""))],
            weight: 69,
            height: 7,
            stats: [
                .init(base_stat: 45, effort: 0, stat: .init(name: "hp", url: "")),
                .init(base_stat: 49, effort: 0, stat: .init(name: "attack", url: "")),
                .init(base_stat: 49, effort: 0, stat: .init(name: "defense", url: "")),
                .init(base_stat: 45, effort: 0, stat: .init(name: "speed", url: ""))
            ]
        )
        let data = try JSONEncoder().encode(detailDTO)

        MockURLProtocol.requestHandler = { _ in (data, 200) }

        let repo = PokemonRepositoryImpl(network: NetworkService(session: makeMockSession()))
        let pokemon = try await repo.fetchDetail(idOrName: "1")

        XCTAssertEqual(pokemon.id, 1)
        XCTAssertEqual(pokemon.name, "Bulbasaur")
        XCTAssertEqual(pokemon.imageURL?.absoluteString,
                       "https://pokeapi.co/media/sprites/bulbasaur.png")
        XCTAssertEqual(pokemon.types, ["grass"])
        XCTAssertEqual(pokemon.weight, 69)
        XCTAssertEqual(pokemon.height, 7)
        XCTAssertEqual(pokemon.hp, 45)
        XCTAssertEqual(pokemon.atk, 49)
        XCTAssertEqual(pokemon.def, 49)
        XCTAssertEqual(pokemon.spd, 45)
    }

    func test_fetchTypes_success() async throws {
        let typeListDTO = TypeListDTO(results: [
            .init(name: "fire", url: ""),
            .init(name: "water", url: "")
        ])
        let data = try JSONEncoder().encode(typeListDTO)

        MockURLProtocol.requestHandler = { _ in (data, 200) }

        let repo = PokemonRepositoryImpl(network: NetworkService(session: makeMockSession()))
        let types = try await repo.fetchTypes()

        XCTAssertEqual(types, ["Fire", "Water"])
    }

    func test_fetchRegions_success() async throws {
        let regionList = NamedAPIResourceList(
            count: 1,
            next: nil,
            previous: nil,
            results: [NamedAPIResource(name: "kanto", url: "https://pokeapi.co/api/v2/region/1")]
        )
        let data = try JSONEncoder().encode(regionList)

        MockURLProtocol.requestHandler = { _ in (data, 200) }

        let repo = PokemonRepositoryImpl(network: NetworkService(session: makeMockSession()))
        let regions = try await repo.fetchRegionsList()

        XCTAssertEqual(regions.count, 1)
        XCTAssertEqual(regions.first?.name, "kanto")
        XCTAssertEqual(regions.first?.url, "https://pokeapi.co/api/v2/region/1")
    }
}
