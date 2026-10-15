//
//  AuthServiceProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated protocol AuthServiceProtocol: Sendable {
    var isAuthorized: Bool { get }
    func login(username: String, password: String) async throws -> User
    func logout() async
}
