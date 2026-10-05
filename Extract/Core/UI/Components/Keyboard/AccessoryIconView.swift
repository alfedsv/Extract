//
//  AccessoryIconView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 06.10.2026.
//

import UIKit

final class AccessoryIconView: UIView {

    var onTap: (() -> Void)?

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
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    init(enabledImage: UIImage?, disabledImage: UIImage?) {
        self.enabledImage = enabledImage
        self.disabledImage = disabledImage
        super.init(frame: .zero)

        imageView.image = enabledImage
        imageView.isUserInteractionEnabled = false
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let minW = widthAnchor.constraint(greaterThanOrEqualToConstant: 44)
        let minH = heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        minW.priority = .defaultHigh
        minH.priority = .defaultHigh
        NSLayoutConstraint.activate([minW, minH])

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func handleTap() {
        guard isEnabled else { return }
        onTap?()
    }
}
