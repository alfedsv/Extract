//
//  EndpointParameter.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

enum EndpointParameter: Sendable {
    case string(String)
    case int(Int)
    case bool(Bool)
    case double(Double)
}
