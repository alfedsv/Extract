//
//  EntranceRepositoryProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 06.10.2026.
//

import Foundation

nonisolated protocol EntranceRepositoryProtocol: Sendable {
    func isUserExists(username: String) async throws -> Bool
}
