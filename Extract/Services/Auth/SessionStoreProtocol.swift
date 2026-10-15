//
//  SessionStoreProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 07.10.2026.
//

import Foundation

nonisolated protocol SessionStoreProtocol: AnyObject, Sendable {
    /// Текущая сессия, если она есть.
    var current: Session? { get }

    /// Есть ли авторизованная сессия (refresh-токен жив).
    var isAuthorized: Bool { get }

    /// Сохранить сессию (атомарно — либо записалась полностью, либо нет).
    func save(_ session: Session) throws

    /// Обновить только access-токен (после refresh).
    func updateAccessToken(_ token: String) throws

    /// Удалить сессию.
    func clear()
}
