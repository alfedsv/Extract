//
//  PrintLogger.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated final class PrintLogger: LoggerProtocol {
    func debug(_ message: String)   { print("🟢 [DEBUG] \(message)") }
    func info(_ message: String)    { print("🔵 [INFO] \(message)") }
    func warning(_ message: String) { print("🟡 [WARN] \(message)") }
    func error(_ message: String)   { print("🔴 [ERROR] \(message)") }

    func error(_ error: Error, context: String) {
        print("🔴 [ERROR] \(context): \(error.localizedDescription)")
    }
}
