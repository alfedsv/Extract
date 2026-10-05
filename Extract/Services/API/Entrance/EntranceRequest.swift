//
//  EntranceRequest.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated enum EntranceRequest {
    struct Login: Encodable, Sendable {}
    struct Register: Encodable, Sendable {}
}
