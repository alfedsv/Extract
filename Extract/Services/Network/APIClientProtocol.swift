//
//  APIClientProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

protocol APIClientProtocol: Sendable {
    func request<T: Decodable & Sendable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
    func request(_ endpoint: Endpoint) async throws
}
