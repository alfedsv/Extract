//
//  TokenRefresher.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

actor TokenRefresher: TokenRefresherProtocol {

    private let client: APIClientProtocol
    private let sessionStore: SessionStoreProtocol
    private var ongoingTask: Task<Void, Error>?

    init(client: APIClientProtocol, sessionStore: SessionStoreProtocol) {
        self.client = client
        self.sessionStore = sessionStore
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
        guard
            let session = sessionStore.current,
            !session.isRefreshTokenExpired()
        else {
            sessionStore.clear()
            throw APIError.unauthorized(nil)
        }

        let response = try await client.request(
            AuthEndpoint.refreshToken(refreshToken: session.refreshToken),
            as: AuthDTO.RefreshTokenResponse.self
        )

        try sessionStore.updateAccessToken(response.accessToken)
    }
}
