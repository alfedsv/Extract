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

    struct IsUserExistingInDB: Decodable, Sendable {
        var isUserExisting: Bool
        private enum CodingKeys: String, CodingKey {
            case isUserExisting = "is_found"
        }
    }
    
    protocol LoginProtocol {}

    struct LoginAuth: Decodable, Sendable, LoginProtocol {
        var username: String
        var firstName: String
        var lastName: String
        var accountType: String
        var avatarHash: String?
        var friendsCount: Int
        var followersCount: Int
        var followingCount: Int
        var isVisibleOnMap: Bool = false
        var isVisibleFriends: Bool = false
        var isVisibleFollowers: Bool = false
        var isVisibleFollowing: Bool = false
        var accessToken: String
        var refreshToken: String
        var about: String
        var moodColor: String?
        var moodName: String?
        var moodNameId: Int?
        private enum CodingKeys: String, CodingKey {
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
            case about = "about"
            case moodColor = "mood_color"
            case moodName = "mood_name"
            case moodNameId = "mood_id"
        }
    }
    
    struct LoginUnauth: Decodable, Sendable, LoginProtocol {
        var attempts: Int
        var accountType: String
        private enum CodingKeys: String, CodingKey {
            case attempts
            case accountType = "account_type"
        }
    }

    struct UserId: Decodable, Sendable {
        var userId: Int
        private enum CodingKeys: String, CodingKey {
            case userId = "user_id"
        }
    }
    
    struct UserRegistrate: Decodable, Sendable {
    }
}
