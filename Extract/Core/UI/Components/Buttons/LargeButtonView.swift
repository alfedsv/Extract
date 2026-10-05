//
//  LargeButtonView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 06.10.2026.
//

import UIKit


final class LargeButtonView: UIView {

    var onPressed: (() -> Void)?

    var isActive: Bool {
        didSet {
            updateBackground()
        }
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = Colors.Buttons.LargeButton.text.color
        return label
    }()

    init(title: String, isActive: Bool) {
        self.isActive = isActive
        super.init(frame: .zero)
        addSubview(label)
        label.text = title
        layer.cornerRadius = Layout.largeButtonRadius
        layer.cornerCurve = .continuous
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        updateBackground()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func updateBackground() {
        backgroundColor = isActive ? Colors.Buttons.LargeButton.Background.Enabled.normal.color : Colors.Buttons.LargeButton.Background.Disabled.normal.color
    }

    @objc
    private func tapped() {
        isUserInteractionEnabled = false
        UIView.animate(withDuration: Settings.animationTime) {
            self.alpha = 0.9
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.backgroundColor = self.isActive ? Colors.Buttons.LargeButton.Background.Enabled.selected.color : Colors.Buttons.LargeButton.Background.Disabled.selected.color
        } completion: { [weak self] _ in
            UIView.animate(withDuration: Settings.animationTime) {
                guard let self = self else { return }
                self.alpha = 1
                self.transform = .identity
                self.updateBackground()
            } completion: { [weak self] _ in
                guard let self = self else { return }
                if self.isActive {
                    self.onPressed?()
                    print("1")
                }
                print("2")
                self.isUserInteractionEnabled = true
            }
        }
    }
}
private extension LargeButtonView {
    func setupConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
}
