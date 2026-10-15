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

    private let showsNavigation: Bool

    private lazy var previousButton: AccessoryIconView = {
        let v = AccessoryIconView(
            enabledImage: Icons.Chevron.Up.enabled.image,
            disabledImage: Icons.Chevron.Up.disabled.image
        )
        v.onTap = { [weak self] in self?.onPrevious?() }
        v.isEnabled = false
        return v
    }()

    private lazy var nextButton: AccessoryIconView = {
        let v = AccessoryIconView(
            enabledImage: Icons.Chevron.Down.enabled.image,
            disabledImage: Icons.Chevron.Down.disabled.image
        )
        v.onTap = { [weak self] in self?.onNext?() }
        v.isEnabled = false
        return v
    }()

    private lazy var doneButton: AccessoryLabelView = {
        let v = AccessoryLabelView(text: L10n.keyboardReady.localized)
        v.onTap = { [weak self] in self?.onDone?() }
        return v
    }()

    init(showsNavigation: Bool) {
        self.showsNavigation = showsNavigation
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        autoresizingMask = .flexibleWidth
        backgroundColor = .clear
        isOpaque = false

        var subviews: [UIView] = []
        if showsNavigation {
            subviews.append(previousButton)
            subviews.append(nextButton)
        }
        subviews.append(UIView())      // распорка
        subviews.append(doneButton)

        let stack = UIStackView(arrangedSubviews: subviews)
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 1
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stack.insetsLayoutMarginsFromSafeArea = false
        
        addSubview(stack)
        setupConstraints(stack: stack)
        
    }

    required init?(coder: NSCoder) { fatalError() }

    func setNavigation(previous: Bool, next: Bool) {
        guard showsNavigation else { return }
        previousButton.isEnabled = previous
        nextButton.isEnabled = next
    }
}
private extension KeyboardAccessoryView {
    func setupConstraints(stack: UIStackView) {
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
