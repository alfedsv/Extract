//
//  KeychainStorageProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated protocol KeychainStorageProtocol: AnyObject, Sendable {
    func save(_ value: String, for key: KeychainKey) throws
    func read(_ key: KeychainKey) throws -> String?
    func delete(_ key: KeychainKey)
    func clear()
}

nonisolated enum KeychainKey: String, CaseIterable {
    case accessToken
    case refreshToken
    case wsToken
}
