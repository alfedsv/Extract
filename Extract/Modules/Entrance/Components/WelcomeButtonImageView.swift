//
//  WelcomeButtonImageView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit


protocol WelcomeButtonDelegate: AnyObject {
    func buttonTapped(command: WelcomeButtonCommand)
    func welcomeButtonsLock(isLocked: Bool)
}

enum WelcomeButtonCommand {
    case login
    case registrate
    case demo
    case representers
    case lock
}

final class WelcomeButtonImageView: UIImageView {

    
    weak var delegate: WelcomeButtonDelegate?
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let command: WelcomeButtonCommand
    
    init(command: WelcomeButtonCommand) {
        self.command = command
        super.init(frame: .zero)
        setupUI()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
        setupConstraints()
    }
    
    func refreshLocalization() {
        applyText()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        isUserInteractionEnabled = true
        contentMode = .scaleToFill
        image = Assets.Welcome.buttonBackgroundWelcome.image
        applyText()
    }

    private func applyText() {
        switch command {
        case .login:
            titleLabel.textColor = Colors.Text.textCommon.color
            titleLabel.font = .systemFont(ofSize: 21)
            titleLabel.text = L10n.Entrance.Welcome.Button.login.localized
        case .registrate:
            titleLabel.textColor = Colors.Text.textCommon.color
            titleLabel.font = .systemFont(ofSize: 21)
            titleLabel.text = L10n.Entrance.Welcome.Button.registration.localized
        case .demo:
            titleLabel.textColor = Colors.Text.textOrange.color
            titleLabel.font = .systemFont(ofSize: 21)
            titleLabel.text = L10n.Entrance.Welcome.Button.demo.localized
        case .representers:
            titleLabel.textColor = Colors.Text.textCommon.color
            titleLabel.font = .systemFont(ofSize: 19)
            titleLabel.text = L10n.Entrance.Welcome.Button.representers.localized
        case .lock:
            titleLabel.isHidden = true
        }
    }

    @objc
    private func tapped() {
        guard let delegate = delegate else { return }
        delegate.welcomeButtonsLock(isLocked: true)
        UIView.animate(withDuration: Settings.animationTime) {
            self.layer.opacity = 0.8
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: Settings.animationTime) {
                self.layer.opacity = 1
                self.transform = .identity
            } completion: { _ in
                delegate.buttonTapped(command: self.command)
                delegate.welcomeButtonsLock(isLocked: false)
            }
        }
    }
}

private extension WelcomeButtonImageView {
    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
