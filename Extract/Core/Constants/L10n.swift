//
//  L10n.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation


protocol L10nPath: RawRepresentable where RawValue == String {
    var localized: String { get }
}


enum L10n: String, L10nPath {
    case keyboardReady = "keyboard.ready"
    case appError = "app.error.title"
    case appErrorSupport = "app.error.support"
    case appErrorCode = "app.error.code"
    
    enum Entrance {
        enum Welcome {
            enum Button: String, L10nPath {
                case login = "entrance.welcome.button.login"
                case registration = "entrance.welcome.button.registration"
                case demo = "entrance.welcome.button.demo"
                case representers = "entrance.welcome.button.representers"
            }
        }
        enum Identity {
            enum Button: String, L10nPath {
                case username = "entrance.button.username"
                case password = "entrance.button.password"
                case registration = "entrance.button.registration"
            }
            enum Placeholder: String, L10nPath {
                case firstName = "entrance.identity.placeholder.firstName"
                case lastName = "entrance.identity.placeholder.lastName"
                case username = "entrance.identity.placeholder.username"
                case password = "entrance.identity.placeholder.password"
                case confirm = "entrance.identity.placeholder.confirm"
            }
            enum Warning: String, L10nPath {
                case agreement = "entrance.warning.agreement"
                case empty = "entrance.warning.empty"
                case confirmNotMatch = "entrance.warning.notMatch"
                case passwordWrong = "entrance.warning.password.wrong"
                case usernameAbsent = "entrance.warning.username.absent"
                case usernameNotValid = "entrance.warning.username.notValid"
                case usernameReserved = "entrance.warning.usernameReserved"
                case usernameTaken =  "entrance.warning.usernameTaken"
                case tooShort =  "entrance.warning.tooShort"
            }
            enum Helper: String, L10nPath {
                case usernameValid = "entrance.helper.username.valid"
                case passwordValid = "entrance.helper.password.valid"
            }
            enum RegistrationAgreement: String, L10nPath {
                case agreement = "entrance.agreement"
            }
        }
    }

}

extension L10nPath {

    /// Обычная локализация без параметров.
    var localized: String {
        rawValue.localized()
    }

    /// Строка с одним целочисленным плейсхолдером (%lld).
    func localized(_ value: Int) -> String {
        String(format: rawValue.localized(), value)
    }

    /// Строка с одним строковым плейсхолдером (%@).
    func localized(_ value: String) -> String {
        String(format: rawValue.localized(), value)
    }

    /// Строка с двумя целочисленными плейсхолдерами.
    func localized(_ a: Int, _ b: Int) -> String {
        String(format: rawValue.localized(), a, b)
    }

    /// Строка с целым + строкой
    func localized(_ a: String, _ b: Int) -> String {
        String(format: rawValue.localized(), a, b)
    }
}
