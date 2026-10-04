//
//  Icons.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

protocol ImagePath: RawRepresentable where RawValue == String {
    var image: UIImage { get }
    var templateImage: UIImage { get } // с рендерингом как template (для tint)
}

enum Icons {

    enum Eye: String, ImagePath {
        case opened = "Eye/opened"
        case closed = "Eye/closed"
    }
    
    enum Bars {
        enum Navigation: String, ImagePath {
            case back = "Bars/Navigation/back"
            case home = "Bars/Navigation/home"
            case chats = "Bars/Navigation/chats"
            case dots = "Bars/Navigation/dots"
        }

        enum Entrance: String, ImagePath {
            case light = "Bars/Entrance/moon"
            case dark = "Bars/Entrance/sun"
            case languadgeRu = "Bars/Entrance/ru"
            case languadgeEn = "Bars/Entrance/en"
        }
        
    }
    
    enum Chevron {
        enum Up: String, ImagePath {
            case enabled = "Chevron/Up/enabled"
            case disabled = "Chevron/Up/disabled"
        }
        enum Down: String, ImagePath {
            case enabled = "Chevron/Down/enabled"
            case disabled = "Chevron/Down/disabled"
        }
    }
    
}

extension ImagePath {

    var image: UIImage {
        UIImage(named: self.rawValue) ?? UIImage()
    }
    var templateImage: UIImage {
        (UIImage(named: self.rawValue) ?? UIImage()).withRenderingMode(.alwaysTemplate)
    }
}
