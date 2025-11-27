//
//  MockURLProtocol.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/27.
//

import Foundation

final class MockURLProtocol: URLProtocol {

    static var responseData: Data?
    static var statusCode: Int = 200
    static var error: Error?

    // 新增 requestHandler
    static var requestHandler: ((URLRequest) throws -> (Data, Int))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let handler = MockURLProtocol.requestHandler {
            do {
                let (data, statusCode) = try handler(request)
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil
                )!
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        } else if let error = MockURLProtocol.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: MockURLProtocol.statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = MockURLProtocol.responseData {
                client?.urlProtocol(self, didLoad: data)
            }
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

