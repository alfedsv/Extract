//
//  AuthRequest.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated enum AuthRequest {

    struct RefreshToken: Encodable, Sendable {
        let refreshToken: String

        enum CodingKeys: String, CodingKey {
            case refreshToken = "refresh_token"
        }
    }

    struct Revoke: Encodable, Sendable {
        let userId: Int

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
        }
    }
}
