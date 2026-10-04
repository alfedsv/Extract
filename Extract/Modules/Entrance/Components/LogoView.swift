//
//  LogoView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit


final class LogoView: UIView {
    
    private let layerGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.cornerRadius = 0
        layer.masksToBounds = true
        layer.colors = [Colors.LogoGradient.start.cgColor, Colors.LogoGradient.end.cgColor]
        return layer
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "E X T R A C T"
        label.font = .systemFont(ofSize: 16)
        label.textColor = Colors.Text.textCommon.color
        return label
    }()
    private var image: UIView = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    private func setup() {
        addSubview(label)
        addSubview(image)
        image.layer.addSublayer(layerGradient)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - 3)
        image.frame = CGRect(x: 0, y: bounds.height - 3, width: bounds.width, height: 3)
        layerGradient.frame = image.bounds
    }

}
extension LogoView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.layerGradient.colors = [Colors.LogoGradient.start.cgColor, Colors.LogoGradient.end.cgColor]
    }
}
