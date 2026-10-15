//
//  PlaceholderLabel.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 11.10.2026.
//

import UIKit

final class PlaceholderLabel: UILabel {

    init() {
        super.init(frame: .zero)
        textColor = Colors.TextView.placeholder.color
        font = Fonts.placeholder.value
        numberOfLines = 1
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
