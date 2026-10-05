//
//  AuthError.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case weakPassword
    case userNotFound
    case server(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Неверный логин или пароль"
        case .weakPassword:       return "Пароль слишком короткий"
        case .userNotFound:       return "Пользователь не найден"
        case .server(let msg):    return msg
        }
    }
}
