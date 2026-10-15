//
//  AccessoryIconView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 06.10.2026.
//

import UIKit

final class AccessoryIconView: TapView {

    var isEnabled: Bool = true {
        didSet {
            guard isEnabled != oldValue else { return }
            imageView.image = isEnabled ? enabledImage : disabledImage
            isUserInteractionEnabled = isEnabled
        }
    }

    private let enabledImage: UIImage?
    private let disabledImage: UIImage?

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .center
        return iv
    }()

    init(enabledImage: UIImage?, disabledImage: UIImage?) {
        self.enabledImage = enabledImage
        self.disabledImage = disabledImage
        super.init(frame: .zero)
        imageView.image = enabledImage
        imageView.isUserInteractionEnabled = false
        addSubview(imageView)
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError() }

}
private extension AccessoryIconView {
    func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 8
        let minW = widthAnchor.constraint(greaterThanOrEqualToConstant: 44 + padding * 2)
        let minH = heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        minW.priority = .defaultHigh
        minH.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            minW,
            minH,
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

    }
}
