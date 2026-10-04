//
//  Assets.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import UIKit

protocol AssetsPath: RawRepresentable where RawValue == String {
    var image: UIImage { get }
    var templateImage: UIImage { get } // с рендерингом как template (для tint)
}

enum Assets {
    enum Welcome: String, ImagePath {
        case buttonBackgroundWelcome = "Welcome/buttonBackground"
    }
}

extension AssetsPath {

    var image: UIImage {
        UIImage(named: self.rawValue) ?? UIImage()
    }
    var templateImage: UIImage {
        (UIImage(named: self.rawValue) ?? UIImage()).withRenderingMode(.alwaysTemplate)
    }
}
