//
//  TokenStorage.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated final class TokenStorage: TokenStorageProtocol, @unchecked Sendable {

    private enum DefaultsKeys {
        static let accessBorn = "AccessTokenBorn"
        static let refreshBorn = "RefreshTokenBorn"
    }

    private let keychain: KeychainStorageProtocol
    private let defaults: UserDefaults
    private let accessTTL: TimeInterval = 60 * 15
    private let refreshTTL: TimeInterval = 60 * 60 * 24 * 30
    private let clock: @Sendable () -> Date

    init(
        keychain: KeychainStorageProtocol,
        defaults: UserDefaults = .standard,
        clock: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.keychain = keychain
        self.defaults = defaults
        self.clock = clock
    }

    // MARK: - Tokens
    
    var accessToken: String? {
        get { try? keychain.read(.accessToken) }
        set {
            if let newValue {
                try? keychain.save(newValue, for: .accessToken)
                defaults.set(Int(clock().timeIntervalSince1970), forKey: DefaultsKeys.accessBorn)
            } else {
                keychain.delete(.accessToken)
                defaults.removeObject(forKey: DefaultsKeys.accessBorn)
            }
        }
    }

    var refreshToken: String? {
        get { try? keychain.read(.refreshToken) }
        set {
            if let newValue {
                try? keychain.save(newValue, for: .refreshToken)
                defaults.set(Int(clock().timeIntervalSince1970), forKey: DefaultsKeys.refreshBorn)
            } else {
                keychain.delete(.refreshToken)
                defaults.removeObject(forKey: DefaultsKeys.refreshBorn)
            }
        }
    }

    var wsToken: String? {
        get { try? keychain.read(.wsToken) }
        set {
            if let newValue {
                try? keychain.save(newValue, for: .wsToken)
            } else {
                keychain.delete(.wsToken)
            }
        }
    }

    // MARK: - Expiration

    func isAccessTokenExpired() -> Bool {
        guard accessToken != nil else { return true }
        let born = defaults.integer(forKey: DefaultsKeys.accessBorn)
        guard born > 0 else { return true }
        return Int(clock().timeIntervalSince1970) - born >= Int(accessTTL)
    }

    func isRefreshTokenExpired() -> Bool {
        guard refreshToken != nil else { return true }
        let born = defaults.integer(forKey: DefaultsKeys.refreshBorn)
        guard born > 0 else { return true }
        return Int(clock().timeIntervalSince1970) - born >= Int(refreshTTL)
    }

    func clear() {
        keychain.clear()
        defaults.removeObject(forKey: DefaultsKeys.accessBorn)
        defaults.removeObject(forKey: DefaultsKeys.refreshBorn)
    }
}
