//
//  NetworkService.swift
//  CallMe
//
//  Created by Mehmet Tarhan on 19/12/2023.
//

import Foundation

protocol NetworkService: AnyObject {
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }
    var urlSession: URLSession { get }

    /// Handles GET requests
    /// - Parameter url: Endpoint of service call
    /// - Returns: Specified type
    func handleDataTask<T: HTTPResponse>(from url: URL) async throws -> T

    /// Handles POST requests
    /// - Parameter urlRequest: URLRequest of service call
    /// - Returns: Specified type
    func handleDataTask<T: HTTPResponse>(for urlRequest: URLRequest) async throws -> T
}

extension NetworkService {
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }

    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.keyEncodingStrategy = .convertToSnakeCase

        return encoder
    }

    var urlSession: URLSession {
        URLSession.shared
    }

    func handleDataTask<T: HTTPResponse>(from url: URL) async throws -> T {
        let (data, _) = try await urlSession.data(from: url)
        return try decoder.decode(T.self, from: data)
    }

    func handleDataTask<T: HTTPResponse>(for urlRequest: URLRequest) async throws -> T {
        let (data, _) = try await urlSession.data(for: urlRequest)
        return try decoder.decode(T.self, from: data)
    }
}

struct BaseURLs {
    static let productionBaseURL = "https://callme-62da96c87a3c.herokuapp.com"
}

struct BaseURL {
    static var shared: String {
        BaseURLs.productionBaseURL
    }
}
