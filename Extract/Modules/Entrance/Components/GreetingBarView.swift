//
//  GreetingBarView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

protocol GreetingBarDelegate: AnyObject {

    func changeLanguage()
    func changeColorTheme()
}

final class GreetingBarView: UIView {


    weak var delegate: GreetingBarDelegate?

    private let languageView = UIView()
    private let themeView = UIView()
    private let languageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let themeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    init() {
        super.init(frame: .zero)
        setupUI()
        setupGestures()
        setupConstraints()
        updateLanguageIcon()
        updateThemeIcon()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshIcons() {
        updateLanguageIcon()
        updateThemeIcon()
    }

    private func setupUI() {
        addSubview(languageView)
        addSubview(themeView)
        languageView.addSubview(languageImageView)
        themeView.addSubview(themeImageView)
    }

    private func setupGestures() {
        languageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedLanguage)))
        themeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedChangeColorTheme)))
    }

    private func updateLanguageIcon() {
        switch LanguageManager.shared.getCurrentLanguage() {
        case .russian:
            languageImageView.image = Icons.Bars.Entrance.languadgeEn.image
        case .english:
            languageImageView.image = Icons.Bars.Entrance.languadgeRu.image
        }
    }

    private func updateThemeIcon() {
        if ThemeManager.shared.isDarkMode() {
            // Сейчас тёмная -> предлагаем светлую.
            themeImageView.image = Icons.Bars.Entrance.dark.image
        } else {
            // Сейчас светлая -> предлагаем тёмную.
            themeImageView.image = Icons.Bars.Entrance.light.image
        }
    }

    @objc
    private func tappedLanguage() {
        guard let delegate = delegate else { return }

        animateTap(on: languageImageView, disablingInteractionOn: languageView) { [weak self] in
            delegate.changeLanguage()
            self?.updateLanguageIcon()
        }
    }

    @objc
    private func tappedChangeColorTheme() {
        guard let delegate = delegate else { return }

        animateTap(on: themeImageView, disablingInteractionOn: themeView) { [weak self] in
            delegate.changeColorTheme()
            self?.updateThemeIcon()
        }
    }

    private func animateTap(on animatedView: UIView, disablingInteractionOn interactionView: UIView, completion: @escaping () -> Void) {
        interactionView.isUserInteractionEnabled = false
        let duration = Settings.animationTime
        UIView.animate(withDuration: duration) {
            animatedView.layer.opacity = 0.7
        } completion: { _ in
            completion()
            UIView.animate(withDuration: duration) {
                animatedView.layer.opacity = 1
            } completion: { _ in
                interactionView.isUserInteractionEnabled = true
            }
        }
    }
}

private extension GreetingBarView {

    func setupConstraints() {
        [
            languageView,
            themeView,
            languageImageView,
            themeImageView
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            languageView.topAnchor.constraint(equalTo: topAnchor),
            languageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            languageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            languageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            themeView.topAnchor.constraint(equalTo: topAnchor),
            themeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            themeView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            themeView.trailingAnchor.constraint(equalTo: trailingAnchor),

            languageImageView.centerYAnchor.constraint(equalTo: languageView.centerYAnchor),
            languageImageView.leadingAnchor.constraint(equalTo: languageView.leadingAnchor, constant: 25),
            
            languageImageView.widthAnchor.constraint(equalToConstant: Layout.navigationBarIconSide - 8),
            languageImageView.heightAnchor.constraint(equalToConstant: Layout.navigationBarIconSide - 8),

            themeImageView.centerYAnchor.constraint(equalTo: themeView.centerYAnchor),
            themeImageView.trailingAnchor.constraint(equalTo: themeView.trailingAnchor, constant: -25),
            
            themeImageView.widthAnchor.constraint(equalToConstant: Layout.navigationBarIconSide),
            themeImageView.heightAnchor.constraint(equalToConstant: Layout.navigationBarIconSide)
        ])
    }
}
