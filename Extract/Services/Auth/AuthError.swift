//
//  AuthError.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated enum AuthError: LocalizedError {

    case invalidCredentials
    case wrongPassword(attemptsLeft: Int)
    case weakPassword
    case userNotFound
    case server(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Неверный логин или пароль"
        case .wrongPassword(let attempts):
            return attempts > 0 ? "Неверный пароль. Осталось попыток: \(attempts)" : "Аккаунт заблокирован"
        case .weakPassword:
            return "Пароль слишком короткий"
        case .userNotFound:
            return "Пользователь не найден"
        case .server(let msg):
            return msg
        }
    }
}
