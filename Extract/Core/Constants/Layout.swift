//
//  Layout.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

enum Layout {
    
    static let logoViewSize: CGSize = .init(width: 100, height: 30)

    static let navigationBarsHeight: CGFloat = 45
    static let navigationBarIconSide: CGFloat = 35

    static let largeButtonHeight: CGFloat = 50
    static let largeButtonRadius: CGFloat = 10
    static let sideOutsetStandart: CGFloat = 25
    
    enum Welcome {
        static let buttonHeight: CGFloat = 55
        static let buttonSidePadding: CGFloat = 30
        static let buttonSpacing: CGFloat = 25
        static let buttonsY: CGFloat = -60
    }
    
    enum Identity {
        static let textViewHeight: CGFloat = 40
        static let textViewBorderWidth: CGFloat = 1
        static let textViewRadius: CGFloat = 10
        static let textViewEyeSide: CGFloat = 25
        static let textViewInsets: UIEdgeInsets = .init(top: 10, left: 15, bottom: 10, right: 15)
        static let textViewPasswordInsets: UIEdgeInsets = .init(top: 10, left: 15, bottom: 10, right: 50)
    }
}
