//
//  EntranceAPI.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated final class EntranceAPI: EntranceAPIProtocol {

    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func login(username: String, password: String) async throws -> EntranceDTO.LoginResult {
        try await client.request(
            EntranceEndpoint.login(username: username, password: password),
            as: EntranceDTO.LoginResult.self
        )
    }

    func isUserExists(username: String) async throws -> EntranceDTO.UserExistance {
        return try await client.request(EntranceEndpoint.isUserExists(username: username), as: EntranceDTO.UserExistance.self)
    }

    /*func register(parameters: [String: Any]) async throws -> EntranceDTO.UserRegistrate {
        try await client.request(
            EntranceEndpoint.registration(parameters: parameters),
            as: EntranceDTO.UserRegistrate.self
        )
    }*/

    func getUserId() async throws -> EntranceDTO.UserId {
        try await client.request(EntranceEndpoint.getUserId, as: EntranceDTO.UserId.self)
    }

    func getWebSocketToken() async throws -> EntranceDTO.TokenWS {
        try await client.request(EntranceEndpoint.getWS, as: EntranceDTO.TokenWS.self)
    }
}
