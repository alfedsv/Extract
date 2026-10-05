//
//  KeychainStorage.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation
import Security

nonisolated final class KeychainStorage: KeychainStorageProtocol {

    // MARK: - Configuration

    /// Идентификатор сервиса. По умолчанию — bundle id приложения.
    private let service: String

    /// Уровень доступности записи.
    /// Храним как String, чтобы не тащить CFString (не Sendable) в stored property.
    /// При передаче в Security API строка автоматически бриджится в CFString.
    private let accessible: String

    // MARK: - Init

    init(
        service: String = Bundle.main.bundleIdentifier ?? "com.extract.tokens",
        accessible: String = kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
    ) {
        self.service = service
        self.accessible = accessible
    }

    // MARK: - Public

    func save(_ value: String, for key: KeychainKey) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.dataConversionFailed
        }

        let updateQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        let updateAttributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessible
        ]

        let updateStatus = SecItemUpdate(
            updateQuery as CFDictionary,
            updateAttributes as CFDictionary
        )

        switch updateStatus {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            try add(data: data, for: key)
        default:
            throw KeychainError.unexpectedStatus(updateStatus)
        }
    }

    func read(_ key: KeychainKey) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard
                let data = result as? Data,
                let string = String(data: data, encoding: .utf8)
            else {
                throw KeychainError.dataConversionFailed
            }
            return string
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func delete(_ key: KeychainKey) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }

    func clear() {
        for key in KeychainKey.allCases {
            delete(key)
        }
    }

    // MARK: - Private

    private func add(data: Data, for key: KeychainKey) throws {
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessible
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
