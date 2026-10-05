//
//  EntranceAPI.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

final class EntranceAPI: EntranceAPIProtocol {

    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func loginByName(username: String, password: String) async throws -> EntranceDTO.LoginAuth {
        try await client.request(
            EntranceEndpoint.login(username: username, password: password),
            as: EntranceDTO.LoginAuth.self
        )
    }

    func isUserInDB(username: String) async throws -> EntranceDTO.IsUserExistingInDB {
        try await client.request(
            EntranceEndpoint.isLoginInDB(username: username),
            as: EntranceDTO.IsUserExistingInDB.self
        )
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
