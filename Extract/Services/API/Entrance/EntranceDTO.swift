//
//  EntranceDTO.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated struct EntranceDTO {

    struct TokenWS: Codable, Sendable {
        var wsId: String
        private enum CodingKeys: String, CodingKey {
            case wsId = "ws_id"
        }
    }

    struct UserExistance: Decodable, Sendable {
        var isUserExists: Bool
        private enum CodingKeys: String, CodingKey {
            case isUserExists = "is_found"
        }
    }
    
    struct LoginAuth: Decodable, Sendable {
        let username: String
        let firstName: String
        let lastName: String
        let accountType: String
        let avatarHash: String?
        let friendsCount: Int
        let followersCount: Int
        let followingCount: Int
        let isVisibleOnMap: Bool
        let isVisibleFriends: Bool
        let isVisibleFollowers: Bool
        let isVisibleFollowing: Bool
        let accessToken: String
        let refreshToken: String
        let about: String
        let moodColor: String?
        let moodName: String?
        let moodNameId: Int?

        enum CodingKeys: String, CodingKey {
            case username = "login"
            case firstName = "first_name"
            case lastName = "last_name"
            case accountType = "account_type"
            case avatarHash = "avatar_hash"
            case friendsCount = "friends"
            case followersCount = "followers"
            case followingCount = "following"
            case isVisibleOnMap = "is_visible_on_map"
            case isVisibleFriends = "is_visible_friends"
            case isVisibleFollowers = "is_visible_followers"
            case isVisibleFollowing = "is_visible_following"
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
            case about
            case moodColor = "mood_color"
            case moodName = "mood_name"
            case moodNameId = "mood_id"
        }
    }

    struct LoginUnauth: Decodable, Sendable {
        let attempts: Int
        let accountType: String

        enum CodingKeys: String, CodingKey {
            case attempts
            case accountType = "account_type"
        }
    }

    /// Ответ логина: либо токены+профиль, либо «не пустили, осталось N попыток».
    enum LoginResult: Decodable, Sendable {
        case authorized(LoginAuth)
        case unauthorized(LoginUnauth)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let auth = try? container.decode(LoginAuth.self) {
                self = .authorized(auth)
                return
            }
            if let unauth = try? container.decode(LoginUnauth.self) {
                self = .unauthorized(unauth)
                return
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown login response"
            )
        }
    }

    struct UserId: Decodable, Sendable {
        let userId: Int

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
        }
    }
    
    struct UserRegistrate: Decodable, Sendable {
    }
}
