//
//  User.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 07.10.2026.
//

import Foundation

nonisolated struct User: Sendable, Equatable {
    let id: Int
    let username: String
    let firstName: String
    let lastName: String
    let accountType: String
    let avatarURL: String?
    let about: String
    let friendsCount: Int
    let followersCount: Int
    let followingCount: Int
    let mood: Mood?

    var fullName: String { "\(firstName) \(lastName)" }
}

