//
//  AuthAPI.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

final class AuthAPI: AuthAPIProtocol {

    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func revokeTokens(userId: Int) async throws {
        try await client.request(AuthEndpoint.revoke(userId: userId))
    }

    func refreshAccessToken(refreshToken: String) async throws -> String {
        let response = try await client.request(
            AuthEndpoint.refreshToken(refreshToken: refreshToken), as: AuthDTO.RefreshTokenResponse.self
        )
        return response.accessToken
    }
}
