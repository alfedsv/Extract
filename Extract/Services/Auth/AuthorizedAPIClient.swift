//
//  AuthorizedAPIClient.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated final class AuthorizedAPIClient: APIClientProtocol, Sendable {

    private let client: APIClientProtocol
    private let tokenStorage: TokenStorageProtocol
    private let refresher: TokenRefresherProtocol

    init(
        client: APIClientProtocol,
        tokenStorage: TokenStorageProtocol,
        refresher: TokenRefresherProtocol
    ) {
        self.client = client
        self.tokenStorage = tokenStorage
        self.refresher = refresher
    }

    func request<T: Decodable & Sendable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        try await performWithAuth { try await client.request(endpoint, as: type) }
    }

    func request(_ endpoint: Endpoint) async throws {
        try await performWithAuth { try await client.request(endpoint) }
    }

    private func performWithAuth<T>(_ block: () async throws -> T) async throws -> T {
        do {
            return try await block()
        } catch APIError.unauthorized {
            try await refresher.refresh()
            return try await block()
        }
    }
}
