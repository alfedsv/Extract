//
//  ValidationError.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 07.10.2026.
//

import Foundation

/// Общая ошибка валидации любого поля.
/// Одна на весь проект.
struct ValidationError: Error {
    let source: Source
    let reason: Reason

    enum Source: String {
        case firstName
        case lastName
        case username
        case password
        case confirm
        case switchAgreement
    }

    enum Reason {
        case empty
        case tooShort(actual: Int, min: Int)
        case tooLong(actual: Int, max: Int)
        case invalidFormat(str: String)
        case invalidValue(str: String)
        case mismatch
    }
}

extension ValidationError {
    /// Строка для логов.
    var debugDescription: String {
        switch reason {
        case .empty:
            return "[\(source.rawValue)] empty"
        case .tooShort(let a, let m):
            return "[\(source.rawValue)] tooShort: \(a) < \(m)"
        case .tooLong(let a, let m):
            return "[\(source.rawValue)] tooLong: \(a) > \(m)"
        case .invalidFormat(let str):
            return "[\(source.rawValue)] invalidFormat: \(str)"
        case .invalidValue(let str):
            return "[\(source.rawValue)] invalidValue: \(str)"
        case .mismatch:
            return "[\(source.rawValue)] mismatch"
        }
    }

    /// Сообщение пользователю с кодом поддержки.
    /// Формат кода: E-<SOURCE>-<REASON>.
    var userFacingMessage: String {
        let reasonCode: String
        switch reason {
        case .empty:                        reasonCode = "001"
        case .tooShort:                     reasonCode = "002"
        case .tooLong:                      reasonCode = "003"
        case .invalidFormat:                reasonCode = "004"
        case .invalidValue:                 reasonCode = "005"
        case .mismatch:                     reasonCode = "006"
        }
        let code = "E-\(source.rawValue.uppercased())-\(reasonCode)"
        return "\(L10n.appErrorCode): \(code)."
    }
}
