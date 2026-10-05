//
//  OSLogger.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation
import os

nonisolated final class OSLogger: LoggerProtocol {
    private let logger = os.Logger(subsystem: "com.extract.app", category: "general")

    func debug(_ message: String)   { logger.debug("\(message, privacy: .public)") }
    func info(_ message: String)    { logger.info("\(message, privacy: .public)") }
    func warning(_ message: String) { logger.warning("\(message, privacy: .public)") }
    func error(_ message: String)   { logger.error("\(message, privacy: .public)") }
    func error(_ error: Error, context: String) {
        logger.error("\(context): \(error.localizedDescription, privacy: .public)")
    }
}
