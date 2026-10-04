//
//  String+Localization.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation


extension String {

    /// Локализует строку, используя текущий язык приложения.
    func localized(comment: StaticString? = nil) -> String {
        String(
            localized: String.LocalizationValue(self),
            bundle: .localizedBundle(),
            comment: comment
        )
    }
    
    /// Локализует строку с форматированием.
    func localized(with arguments: CVarArg...) -> String {
        String(format: localized(), arguments: arguments)
    }
}
