//
//  Colors.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

protocol ColorPath: RawRepresentable where RawValue == String {
    var color: UIColor { get }
    var cgColor: CGColor { get }
}

enum Colors {
    
    enum App: String, ColorPath {
        case background = "App/background"
        
    }
    
    enum LogoGradient: String, ColorPath {
        case start = "LogoGradient/start"
        case end = "LogoGradient/end"
    }
    
    enum Buttons {
        enum LargeButton: String, ColorPath {
            case text = "Buttons/LargeButton/text"
            enum Background {
                enum Enabled: String, ColorPath {
                    case normal = "Buttons/Background/LargeButton/normal"
                    case selected = "Buttons/Background/LargeButton/selected"
                }
                enum Disabled: String, ColorPath {
                    case normal = "Buttons/Background/LargeButton/normal"
                    case selected = "Buttons/Background/LargeButton/selected"
                }
            }
        }
    }
    
    enum Text: String, ColorPath {
        case textCommon = "Text/common"
        case textOrange = "Text/orange"
    }
    
    enum TextView: String, ColorPath {
        case background = "TextView/background"
        case placeholder = "TextView/placeholder"
        enum Border: String, ColorPath {
            case active = "TextView/Border/active"
            case inactive = "TextView/Border/inactive"
            case error = "TextView/Border/error"
        }
        enum Text: String, ColorPath {
            case active = "TextView/Text/active"
            case inactive = "TextView/Text/inactive"
        }
    }
    
}

extension ColorPath {

    var color: UIColor {
        UIColor(named: self.rawValue) ?? .clear
    }
    var cgColor: CGColor {
        color.cgColor
    }
}
