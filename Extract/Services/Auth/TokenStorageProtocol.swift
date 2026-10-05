//
//  TokenStorageProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated protocol TokenStorageProtocol: AnyObject, Sendable {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    var wsToken: String? { get set }

    func isAccessTokenExpired() -> Bool
    func isRefreshTokenExpired() -> Bool
    func clear()
}
