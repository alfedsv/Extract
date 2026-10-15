//
//  IdentityTextViewType.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 13.10.2026.
//

import Foundation

enum IdentityTextViewType {
    case username
    case password
    case confirm
    case firstName
    case lastName
    
    func placeholder() -> String {
        switch self {
        case .username:
            L10n.Entrance.Identity.Placeholder.username.localized
        case .password:
            L10n.Entrance.Identity.Placeholder.password.localized
        case .confirm:
            L10n.Entrance.Identity.Placeholder.confirm.localized
        case .firstName:
            L10n.Entrance.Identity.Placeholder.firstName.localized
        case .lastName:
            L10n.Entrance.Identity.Placeholder.lastName.localized
        }
    }
    
    func maxChars() -> Int {
        switch self {
        case .username:
            Settings.IdentityTextView.usernameClosedRange.upperBound
        case .password, .confirm:
            Settings.IdentityTextView.passwordClosedRange.upperBound
        case .firstName, .lastName:
            Settings.IdentityTextView.nameClosedRange.upperBound
        }
    }
}
