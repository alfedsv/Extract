//
//  HelperLabel.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 12.10.2026.
//

import UIKit

final class WarningHelperLabel: UILabel {

    enum State {
        case helper
        case warning
    }
    
    init(state: State, text: String = "") {
        super.init(frame: .zero)
        self.text = text
        font = Fonts.warningAndHelper.value
        numberOfLines = 0
        setup(state: state)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setup(state: State) {
        switch state {
        case .helper:
            textColor = Colors.Text.helper.color
        case .warning:
            textColor = Colors.Text.error.color
        }
    }

}
