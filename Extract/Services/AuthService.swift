//
//  AuthService.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation

/// Сервис авторизации — единая точка для всех вопросов "кто я и можно ли мне".
///
/// В реальном проекте здесь были бы сетевые вызовы, refresh-токены и т.п.
/// Здесь — минимальная логика поверх Keychain, чтобы показать архитектуру.
protocol AuthServiceProtocol {
    var isAuthorized: Bool { get }
    func login(username: String, password: String) async throws
    func register(username: String, password: String) async throws
    func logout()
}

final class AuthService: AuthServiceProtocol {

    private let storage: KeychainStorage

    init(storage: KeychainStorage = KeychainStorage()) {
        self.storage = storage
    }

    /// Авторизован ли пользователь.
    /// В реальном проекте здесь была бы проверка срока жизни токена,
    /// а не просто "есть ли он".
    var isAuthorized: Bool {
        storage.read(.token)?.isEmpty == false
    }

    /// Логин. В реальности — сетевой запрос.
    func login(username: String, password: String) async throws {
        // Имитация запроса.
        try await Task.sleep(nanoseconds: 700_000_000)

        // Простейшая проверка — в реале валидация на сервере.
        guard !username.contains(" "), password.count >= 4 else {
            throw AuthError.invalidCredentials
        }

        try storage.save("fake-token-\(UUID().uuidString)", for: .token)
    }

    /// Регистрация. В реальности — сетевой запрос.
    func register(username: String, password: String) async throws {
        try await Task.sleep(nanoseconds: 700_000_000)
        guard !username.contains(" "), password.count >= 6 else {
            throw AuthError.weakPassword
        }
        try storage.save("fake-token-\(UUID().uuidString)", for: .token)
    }

    /// Выход — чистим токен.
    func logout() {
        storage.delete(.token)
    }
}

/// Ошибки авторизации.
enum AuthError: LocalizedError {
    case invalidCredentials
    case weakPassword

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Неверный логин или пароль"
        case .weakPassword:       return "Пароль слишком короткий"
        }
    }
}
