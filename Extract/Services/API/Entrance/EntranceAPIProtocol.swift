//
//  EntranceAPIProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated protocol EntranceAPIProtocol: Sendable {
    func login(username: String, password: String) async throws -> EntranceDTO.LoginResult
    func isUserExists(username: String) async throws -> EntranceDTO.UserExistance
    //func register(parameters: [String: Any]) async throws -> EntranceDTO.UserRegistrate
    func getUserId() async throws -> EntranceDTO.UserId
    func getWebSocketToken() async throws -> EntranceDTO.TokenWS
}
