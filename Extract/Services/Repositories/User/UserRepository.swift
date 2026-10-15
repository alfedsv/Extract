//
//  UserRepository.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 07.10.2026.
//

import Foundation

nonisolated final class UserRepository: UserRepositoryProtocol, @unchecked Sendable {

    private let lock = NSLock()
    private var cached: User?

    var cachedCurrentUser: User? {
        lock.withLock { cached }
    }

    func cacheCurrentUser(_ user: User) {
        lock.withLock { cached = user }
    }

    func clearCache() {
        lock.withLock { cached = nil }
    }
}
