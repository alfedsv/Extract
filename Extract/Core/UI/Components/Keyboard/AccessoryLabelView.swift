//
//  AccessoryLabelView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 06.10.2026.
//

import UIKit

final class AccessoryLabelView: UIView {

    var onTap: (() -> Void)?

    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17)
        l.textColor = .systemBlue
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }

    init(text: String?) {
        super.init(frame: .zero)
        label.text = text
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let minH = heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        minH.priority = .defaultHigh
        minH.isActive = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func handleTap() {
        onTap?()
    }
}
