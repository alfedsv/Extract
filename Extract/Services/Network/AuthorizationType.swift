//
//  AuthorizationType.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation


/// Тип авторизации запроса.
nonisolated enum AuthorizationType: Sendable  {
    /// Запрос идёт без токена (логин, регистрация).
    case none
    /// Запрос с access-токеном.
    case access
    /// Запрос с refresh-токеном (обновление access).
    case refresh
}
