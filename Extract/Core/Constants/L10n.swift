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
            enum Placeholder: String, L10nPath {
                case firstName = "entrance.identity.placeholder.firstName"
                case lastName = "entrance.identity.placeholder.lastName"
                case username = "entrance.identity.placeholder.username"
                case password = "entrance.identity.placeholder.password"
                case confirm = "entrance.identity.placeholder.confirm"
            }
            enum Warning {
                
            }
        }
    }

}

extension L10nPath {

    var localized: String {
        rawValue.localized()
    }

    func localized(with arguments: CVarArg...) -> String {
        String(format: rawValue.localized(), arguments: arguments)
    }
}
