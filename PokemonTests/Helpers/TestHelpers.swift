//
//  TestHelpers.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/27.
//

import Foundation

func makeMockSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}
