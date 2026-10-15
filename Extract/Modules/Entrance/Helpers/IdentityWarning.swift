//
//  IdentityWarning.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 06.10.2026.
//

import Foundation

struct IdentityWarning {
    enum Warning: Equatable {
        case empty
        case notUserExists
        case usernameNotValid
        case tooShort(val: Int)
        case confirmNotMatch
        case agreementNotSigned
        case usernameTaken
    }

    let warning: Warning
    // nul - значение для switch, все остальное TextView
    let textViewType: IdentityTextViewType?
    
    var message: String {
        switch warning {
        case .notUserExists:
            return L10n.Entrance.Identity.Warning.usernameAbsent.localized
        case .usernameNotValid:
            return L10n.Entrance.Identity.Warning.usernameNotValid.localized
        case .empty:
            return L10n.Entrance.Identity.Warning.empty.localized
        case .tooShort(let val):
            return L10n.Entrance.Identity.Warning.tooShort.localized(val)
        case .confirmNotMatch:
            return L10n.Entrance.Identity.Warning.confirmNotMatch.localized
        case .agreementNotSigned:
            return L10n.Entrance.Identity.Warning.agreement.localized
        case .usernameTaken:
            return L10n.Entrance.Identity.Warning.usernameTaken.localized
        }
    }
}
