//
//  SessionError.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 07.10.2026.
//

import Foundation

import Foundation

nonisolated enum SessionError: LocalizedError {
    case noActiveSession

    var errorDescription: String? {
        switch self {
        case .noActiveSession:
            return "Нет активной сессии"
        }
    }
}
