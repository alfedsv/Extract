//
//  APIErrorModel.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

/// Модель ошибки от сервера.
nonisolated struct APIErrorModel: Decodable, Sendable {
    let code: Int?
    let message: String

    enum CodingKeys: String, CodingKey {
        case code
        case message
    }
}
