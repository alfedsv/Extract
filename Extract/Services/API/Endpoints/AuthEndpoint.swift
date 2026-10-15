//
//  AuthEndpoint.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated enum AuthEndpoint: Endpoint {

    case refreshToken(refreshToken: String)
    case revoke(userId: Int)

    var method: HTTPMethod { .post }

    var path: String {
        switch self {
        case .refreshToken: return "token_refresh"
        case .revoke:       return "token_revoke"
        }
    }

    var body: Data? {
        switch self {
        case .refreshToken(let refreshToken):
            return encode(AuthRequest.RefreshToken(refreshToken: refreshToken))
        case .revoke(let userId):
            return encode(AuthRequest.Revoke(userId: userId))
        }
    }

    var authorization: AuthorizationType {
        switch self {
        case .refreshToken: return .refresh
        case .revoke:       return .access
        }
    }

    // MARK: - Private

    private func encode<T: Encodable>(_ value: T) -> Data? {
        do {
            return try JSONEncoder().encode(value)
        } catch {
            assertionFailure("Encode failed for \(self): \(error)")
            return nil
        }
    }
}
