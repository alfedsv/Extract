//
//  Settings.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation

enum Settings {

    static let animationTime: Double = 0.5
    
    enum IdentityTextView {

        static let nameClosedRange: ClosedRange = 1...32
        static let usernameClosedRange: ClosedRange = 4...32
        static let passwordClosedRange: ClosedRange = 8...128
        static let loginAllowedCharacterSet: CharacterSet = {
            var set = CharacterSet()
            set.insert(charactersIn: "abcdefghijklmnopqrstuvwxyz")
            set.insert(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
            set.insert(charactersIn: "0123456789_")
            return set
        }()
    }

}
