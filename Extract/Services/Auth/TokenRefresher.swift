//
//  TokenRefresher.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

actor TokenRefresher: TokenRefresherProtocol {

    private let client: APIClientProtocol
    private let tokenStorage: TokenStorageProtocol
    private var ongoingTask: Task<Void, Error>?

    init(client: APIClientProtocol, tokenStorage: TokenStorageProtocol) {
        self.client = client
        self.tokenStorage = tokenStorage
    }

    func refresh() async throws {
        if let ongoingTask {
            return try await ongoingTask.value
        }
        let task = Task { try await performRefresh() }
        ongoingTask = task
        defer { ongoingTask = nil }
        try await task.value
    }

    private func performRefresh() async throws {
        guard let refreshToken = tokenStorage.refreshToken,
              !tokenStorage.isRefreshTokenExpired()
        else {
            tokenStorage.clear()
            throw APIError.unauthorized(nil)
        }

        let response = try await client.request(
            AuthEndpoint.refreshToken(refreshToken: refreshToken),
            as: AuthDTO.RefreshTokenResponse.self
        )

        tokenStorage.accessToken = response.accessToken
    }
}
