//
//  UseCasesTests.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/27.
//

import XCTest
@testable import Pokemon

final class UseCasesTests: XCTestCase {

    func makeMockSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    func test_FetchPokemonListUseCase() async throws {
        let resultItem = PokemonListDTO.ResultItem(
            name: "bulbasaur",
            url: "https://pokeapi.co/api/v2/pokemon/1"
        )
        let listDTO = PokemonListDTO(
            count: 1,
            next: nil,
            previous: nil,
            results: [resultItem]
        )
        let listData = try JSONEncoder().encode(listDTO)

        MockURLProtocol.requestHandler = { _ in (listData, 200) }

        let repo = PokemonRepositoryImpl(network: NetworkService(session: makeMockSession()))
        let useCase = FetchPokemonListUseCase(repository: repo)

        let result = try await useCase.execute(limit: 20, offset: 0)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].name, "Bulbasaur")
    }

    func test_FetchPokemonDetailUseCase() async throws {
        let detailDTO = PokemonDTO(
            id: 25,
            name: "pikachu",
            sprites: .init(front_default: URL(string: "https://pokeapi.co/media/sprites/pikachu.png")),
            types: [
                .init(slot: 1, type: .init(name: "electric", url: ""))
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
        MockURLProtocol.requestHandler = { _ in (detailData, 200) }

        let repo = PokemonRepositoryImpl(network: NetworkService(session: makeMockSession()))
        let useCase = FetchPokemonDetailUseCase(repository: repo)

        let pokemon = try await useCase.execute(idOrName: "25")

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

    func test_FetchTypesUseCase() async throws {
        let typeListDTO = TypeListDTO(results: [
            .init(name: "fire", url: "")
        ])
        let data = try JSONEncoder().encode(typeListDTO)

        MockURLProtocol.requestHandler = { _ in (data, 200) }

        let repo = PokemonRepositoryImpl(network: NetworkService(session: makeMockSession()))
        let useCase = FetchTypesUseCase(repository: repo)

        let types = try await useCase.execute()

        XCTAssertEqual(types, ["Fire"])
    }

    func test_FetchRegionsUseCase() async throws {
        let regionList = NamedAPIResourceList(
            count: 1,
            next: nil,
            previous: nil,
            results: [
                NamedAPIResource(name: "kanto", url: "https://pokeapi.co/api/v2/region/1")
            ]
        )
        let data = try JSONEncoder().encode(regionList)

        MockURLProtocol.requestHandler = { _ in (data, 200) }

        let repo = PokemonRepositoryImpl(network: NetworkService(session: makeMockSession()))
        let useCase = FetchRegionsUseCase(repository: repo)

        let regions = try await useCase.execute()

        XCTAssertEqual(regions.count, 1)
        XCTAssertEqual(regions[0].name, "kanto")
        XCTAssertEqual(regions[0].url, "https://pokeapi.co/api/v2/region/1")
    }
}
