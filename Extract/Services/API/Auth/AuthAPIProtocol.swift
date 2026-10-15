//
//  AuthAPIProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated protocol AuthAPIProtocol: Sendable {
    func revokeTokens(userId: Int) async throws
    func refreshAccessToken(refreshToken: String) async throws -> String
}
