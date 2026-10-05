//
//  EntranceAPIProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

protocol EntranceAPIProtocol {
    func loginByName(username: String, password: String) async throws -> EntranceDTO.LoginAuth
    func isUserInDB(username: String) async throws -> EntranceDTO.IsUserExistingInDB
    //func register(parameters: [String: Any]) async throws -> EntranceDTO.UserRegistrate
    func getUserId() async throws -> EntranceDTO.UserId
    func getWebSocketToken() async throws -> EntranceDTO.TokenWS
}
