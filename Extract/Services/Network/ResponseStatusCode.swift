//
//  ResponseStatusCode.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated enum ResponseStatusCode: Int, Sendable {
    case successful = 200
    case badRequest = 400
    case unauthorized = 401
    case notFound = 404
    case internalServerError = 500
}
