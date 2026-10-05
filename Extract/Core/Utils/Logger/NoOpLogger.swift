//
//  NoOpLogger.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated final class NoOpLogger: LoggerProtocol {
    func debug(_ message: String) {}
    func info(_ message: String) {}
    func warning(_ message: String) {}
    func error(_ message: String) {}
    func error(_ error: Error, context: String) {}
}
