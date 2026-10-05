//
//  TokenRefresherProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

protocol TokenRefresherProtocol: Sendable {
    /// Обновляет access-токен, используя refresh-токен.
    /// Если refresh-токен отсутствует или истёк — бросает `APIError.unauthorized`.
    /// Безопасен при параллельных вызовах: если refresh уже идёт,
    /// параллельный вызов дождётся того же результата, а не запустит второй запрос.
    func refresh() async throws
}
