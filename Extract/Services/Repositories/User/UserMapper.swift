//
//  UserMapper.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 07.10.2026.
//

import Foundation

nonisolated enum UserMapper {

    static func toDomain(_ dto: EntranceDTO.LoginAuth) -> User {
        User(
            id: 0,
            username: dto.username,
            firstName: dto.firstName,
            lastName: dto.lastName,
            accountType: dto.accountType,
            avatarURL: dto.avatarHash,
            about: dto.about,
            friendsCount: dto.friendsCount,
            followersCount: dto.followersCount,
            followingCount: dto.followingCount,
            mood: Mood(color: dto.moodColor, name: dto.moodName, id: dto.moodNameId)
        )
    }

}
