//
//  Fonts.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 15.10.2026.
//

import UIKit

enum Fonts {
    case warningAndHelper
    case placeholder
    case identityTextView
        
    var value: UIFont {
        switch self {
        case .warningAndHelper:
            .systemFont(ofSize: 14)
        case .placeholder:
            .systemFont(ofSize: 14)
        case .identityTextView:
            UIFont(name: "Menlo-Regular", size: 16) ?? .systemFont(ofSize: 16)

        }
    }
}
