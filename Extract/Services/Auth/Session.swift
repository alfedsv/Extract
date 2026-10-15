//
//  Session.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 07.10.2026.
//

import Foundation


/// Полная сессия пользователя: токены + id + метки времени.
/// Хранится одним объектом в Keychain → атомарная запись/чтение.
nonisolated struct Session: Codable, Sendable, Equatable {
    let userId: Int
    let accessToken: String
    let refreshToken: String
    let accessTokenBornAt: Date
    let refreshTokenBornAt: Date

    // MARK: - TTL

    private static let accessTTL: TimeInterval = 60 * 15            // 15 минут
    private static let refreshTTL: TimeInterval = 60 * 60 * 24 * 30 // 30 дней

    func isAccessTokenExpired(now: Date = Date()) -> Bool {
        now.timeIntervalSince(accessTokenBornAt) >= Self.accessTTL
    }

    func isRefreshTokenExpired(now: Date = Date()) -> Bool {
        now.timeIntervalSince(refreshTokenBornAt) >= Self.refreshTTL
    }

    /// Обновляем только access-токен (используется в TokenRefresher).
    func withRefreshedAccessToken(_ newAccessToken: String, now: Date = Date()) -> Session {
        Session(
            userId: userId,
            accessToken: newAccessToken,
            refreshToken: refreshToken,
            accessTokenBornAt: now,
            refreshTokenBornAt: refreshTokenBornAt
        )
    }
}
