//
//  SessionStore.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 07.10.2026.
//

import Foundation

nonisolated final class SessionStore: SessionStoreProtocol, @unchecked Sendable {

    private let keychain: KeychainStorageProtocol
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    /// In-memory кэш, чтобы не дёргать Keychain на каждый запрос.
    /// Синхронизирован через lock.
    private let lock = NSLock()
    private var cachedSession: Session?
    private var didLoad = false

    init(keychain: KeychainStorageProtocol) {
        self.keychain = keychain
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - SessionStoreProtocol

    var current: Session? {
        lock.withLock {
            loadIfNeeded()
            return cachedSession
        }
    }

    var isAuthorized: Bool {
        guard let session = current else { return false }
        return !session.isRefreshTokenExpired()
    }

    func save(_ session: Session) throws {
        let data = try encoder.encode(session)
        let string = data.base64EncodedString()
        try keychain.save(string, for: .session)
        lock.withLock {
            cachedSession = session
            didLoad = true
        }
    }

    func updateAccessToken(_ token: String) throws {
        guard let session = current else {
            throw SessionError.noActiveSession
        }
        let updated = session.withRefreshedAccessToken(token)
        try save(updated)
    }

    func clear() {
        keychain.delete(.session)
        lock.withLock {
            cachedSession = nil
            didLoad = true
        }
    }

    // MARK: - Private

    private func loadIfNeeded() {
        guard !didLoad else { return }
        didLoad = true

        guard
            let string = try? keychain.read(.session),
            let data = Data(base64Encoded: string),
            let session = try? decoder.decode(Session.self, from: data)
        else {
            cachedSession = nil
            return
        }
        cachedSession = session
    }
}
