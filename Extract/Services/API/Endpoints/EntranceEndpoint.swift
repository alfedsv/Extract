//
//  EntranceEndpoint.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation


nonisolated enum EntranceEndpoint: Endpoint {

    case login(username: String, password: String)
    case isUserExists(username: String)
    case getUserId
    case getWS

    var method: HTTPMethod { .post }

    var path: String {
        switch self {
        case .login:        return "login"
        case .isUserExists:  return "is_login_in_db"
        case .getUserId:    return "user_own_id_get"
        case .getWS:        return "user_ws_id_get"
        }
    }

    var body: Data? {
        switch self {
        case .login(let username, let password):
            return encode(EntranceRequest.Login(username: username, password: password))
        case .isUserExists(let username):
            return encode(EntranceRequest.UserExistance(username: username))
        case .getUserId, .getWS:
            return nil
        }
    }

    var authorization: AuthorizationType {
        switch self {
        case .login, .isUserExists: return .none
        case .getUserId, .getWS:   return .access
        }
    }
    
    var treats401AsSuccess: Bool {
        switch self {
        case .login: return true       // 401 на логине = «неверный пароль, N попыток»
        default:     return false
        }
    }

    // MARK: - Private

    private func encode<T: Encodable>(_ value: T) -> Data? {
        do {
            return try JSONEncoder().encode(value)
        } catch {
            assertionFailure("Encode failed for \(self): \(error)")
            return nil
        }
    }
}
