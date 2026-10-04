//
//  KeyboardAccessoryView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

final class KeyboardAccessoryView: UIView {

    var onPrevious: (() -> Void)?
    var onNext: (() -> Void)?
    var onDone: (() -> Void)?

    private lazy var previousButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(Icons.Chevron.Up.enabled.image, for: .normal)
        b.setImage(Icons.Chevron.Up.disabled.image, for: .disabled)
        b.addAction(UIAction { [weak self] _ in self?.onPrevious?() }, for: .touchUpInside)
        return b
    }()

    private lazy var nextButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(Icons.Chevron.Down.enabled.image, for: .normal)
        b.setImage(Icons.Chevron.Down.disabled.image, for: .disabled)
        b.addAction(UIAction { [weak self] _ in self?.onNext?() }, for: .touchUpInside)
        return b
    }()

    private lazy var readyButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(L10n.keyboardReady.localized, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17)
        b.addAction(UIAction { [weak self] _ in self?.onDone?() }, for: .touchUpInside)
        return b
    }()

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        autoresizingMask = .flexibleWidth
        backgroundColor = .clear
        isOpaque = false
        
        let stack = UIStackView(arrangedSubviews: [
            previousButton, nextButton, UIView(), readyButton
        ])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func setNavigation(previous: Bool, next: Bool) {
        previousButton.isEnabled = previous
        nextButton.isEnabled = next
    }
}
