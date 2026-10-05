//
//  AuthDTO.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated struct AuthDTO {
    struct RefreshTokenResponse: Decodable, Sendable {
        let accessToken: String

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}
