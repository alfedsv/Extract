//
//  EntranceRepository.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 06.10.2026.
//

import Foundation

final class EntranceRepository: EntranceRepositoryProtocol {
    
    private let entranceAPI: EntranceAPIProtocol

    init(entranceAPI: EntranceAPIProtocol) {
        self.entranceAPI = entranceAPI
    }

    func isUserExists(username: String) async throws -> Bool {
        let dto = try await entranceAPI.isUserExists(username: username)
        return dto.isUserExists
    }
    
}
