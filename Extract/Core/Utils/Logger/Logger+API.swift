//
//  Logger+API.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 07.10.2026.
//

import Foundation

extension LoggerProtocol {

    func logAPI(_ error: APIError, endpoint: String) {
        switch error {
        case .unauthorized:
            self.warning("🔒 401 at \(endpoint)")
        case .server(let status, let model):
            self.error("❌ \(status) at \(endpoint): \(model?.message ?? "")")
        case .transport(let underlying):
            self.error("🌐 Transport at \(endpoint): \(underlying.localizedDescription)")
        case .decoding(let underlying):
            self.error("📦 Decoding at \(endpoint): \(underlying.localizedDescription)")
        default:
            self.error("⚠️ \(endpoint): \(error.localizedDescription)")
        }
    }
}
