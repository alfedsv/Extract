//
//  Logger+Validation.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 07.10.2026.
//

import Foundation

extension LoggerProtocol {

    /// Логирует ошибку валидации с контекстом.
    /// Не падает — только пишет.
    func logValidation(_ error: ValidationError, in context: String) {
        self.error("\(context) → \(error.debugDescription)")
    }

    /// Логирует ошибку валидации и падает в DEBUG.
    /// Используй, когда валидация должна быть на UI, а сюда попасть не может.
    func crashOnValidation(_ error: ValidationError, in context: String) {
        self.error("\(context) → \(error.debugDescription)")
        // assertionFailure("Unexpected validation failure in \(context): \(error.debugDescription)") // TODO: - Так удобнее при отладке
    }
}
