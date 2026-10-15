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
    var body: Data? { get }
    var authorization: AuthorizationType { get }
    var treats401AsSuccess: Bool { get }
}
nonisolated extension Endpoint {
    var treats401AsSuccess: Bool { false }   // по умолчанию 401 — ошибка
}

