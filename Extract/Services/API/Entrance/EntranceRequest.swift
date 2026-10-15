//
//  EntranceRequest.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated enum EntranceRequest {

    struct Login: Encodable, Sendable {
        let username: String
        let password: String
        enum CodingKeys: String, CodingKey {
            case username = "login"
            case password
        }
    }

    struct UserExistance: Encodable, Sendable {
        let username: String
        enum CodingKeys: String, CodingKey {
            case username = "login"
        }
    }

    struct Register: Encodable, Sendable {
        let username: String
        let password: String
        let firstName: String
        let lastName: String

        enum CodingKeys: String, CodingKey {
            case username = "login"
            case password
            case firstName = "first_name"
            case lastName = "last_name"
        }
    }
}
