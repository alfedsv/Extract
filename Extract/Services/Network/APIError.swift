//
//  APIError.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated enum APIError: Error, LocalizedError {
    case invalidURL(String)
    case invalidResponse
    case transport(Error)
    case decoding(Error)
    case unauthorized(APIErrorModel?)
    case server(status: Int, model: APIErrorModel?)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL(let path):
            return "Invalid URL: \(path)"
        case .invalidResponse:
            return "Invalid response"
        case .transport(let error):
            return error.localizedDescription
        case .decoding:
            return "Failed to decode response"
        case .unauthorized:
            return "Unauthorized"
        case .server(let status, let model):
            return model?.message ?? "Server error \(status)"
        case .unknown:
            return "Unknown error"
        }
    }
}
