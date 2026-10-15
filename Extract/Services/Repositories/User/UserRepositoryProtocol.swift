//
//  UserRepositoryProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 07.10.2026.
//

import Foundation

nonisolated protocol UserRepositoryProtocol: AnyObject, Sendable {
    var cachedCurrentUser: User? { get }
    func cacheCurrentUser(_ user: User)
    func clearCache()
}
