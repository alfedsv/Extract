//
//  Endpoint.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

@preconcurrency
nonisolated protocol Endpoint: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var authorization: AuthorizationType { get }
}

extension Endpoint {
    var method: HTTPMethod { .post }
    var parameters: [String: Any]? { nil }
    var authorization: AuthorizationType { .access }
}
