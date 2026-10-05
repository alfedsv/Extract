//
//  AuthEndpoint.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

enum AuthEndpoint: Endpoint {
    
    var method: HTTPMethod { return .post }
    
    case refreshToken(refreshToken: String)
    case revoke(userId: Int)

    var path: String {
        switch self {
        case .refreshToken: return "token_refresh"
        case .revoke:       return "token_revoke"
        }
    }

    var parameters: [String: EndpointParameter]? {
        switch self {
        case .refreshToken(let token):
            return [
                "refresh_token": .string(token)
            ]
        case .revoke(let userId):
            return [
                "user_id": .int(userId)
            ]
        }
    }

    var authorization: AuthorizationType {
        switch self {
        case .refreshToken: return .refresh
        case .revoke:       return .access
        }
    }
}

