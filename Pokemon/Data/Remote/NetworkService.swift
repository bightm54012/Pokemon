//
//  NetworkService.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import Foundation

public enum APIError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decoding(Error)
}

public final class NetworkService {
    public static let shared = NetworkService()
    private let baseURL = URL(string: "https://pokeapi.co/api/v2")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    public func request<T: Decodable>(path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        var comps = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)!
        if !queryItems.isEmpty { comps.queryItems = queryItems }
        guard let url = comps.url else { throw APIError.invalidURL }

        let (data, resp) = try await session.data(from: url)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw APIError.statusCode(http.statusCode) }

        do {
            let obj = try JSONDecoder().decode(T.self, from: data)
            return obj
        } catch {
            throw APIError.decoding(error)
        }
    }
}
