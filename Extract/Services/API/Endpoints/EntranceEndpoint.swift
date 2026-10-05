//
//  EntranceEndpoint.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

enum EntranceEndpoint: Endpoint {

    
    var method: HTTPMethod { return .post }
    
    case login(username: String, password: String)
    case isLoginInDB(username: String)
    //case registration(parameters: [String: Any])
    case getUserId
    case getWS
    
    var path: String {
        switch self {
        case .login:                     return "login"
        case .isLoginInDB:               return "is_login_in_db"
        //case .registration:              return "registration"
        case .getUserId:                 return "user_own_id_get"
        case .getWS:                     return "user_ws_id_get"
        }
    }

    var parameters: [String: EndpointParameter]? {
        switch self {
        case .login(let username, let password):
            return [
                "login": .string(username),
                "password": .string(password)
            ]
        
        case .isLoginInDB(let username):
            return [
                "login": .string(username)
            ]
        /*case .registration(let params):
            return params*/
        case .getUserId, .getWS:
            return nil
        }
    }

    var authorization: AuthorizationType {
        switch self {
        case .login, .isLoginInDB/*,
             .registration*/:
            return .none
        case .getUserId, .getWS:
            return .access
        }
    }
}
