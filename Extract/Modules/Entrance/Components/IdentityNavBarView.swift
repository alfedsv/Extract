//
//  IdentityNavBarView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit


final class IdentityNavBarView: UIView {

    var onBack: (() -> Void)?
    var onChangeColorTheme: (() -> Void)?

    private let backView: UIView = UIView()
    private let themeView: UIView = UIView()
    private let backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = Icons.Bars.Navigation.back.image
        return imageView
    }()

    private let themeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    init() {
        super.init(frame: .zero)
        setupUI()
        setupGestures()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(backView)
        addSubview(themeView)
        backView.addSubview(backImageView)
        themeView.addSubview(themeImageView)
        updateThemeIcon()
    }
    
    private func setupGestures() {
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backTapped)))
        themeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeThemeTapped)))
    }
    
    private func updateThemeIcon() {
        if ThemeManager.shared.isDarkMode() {
            themeImageView.image = Icons.Bars.Entrance.dark.image
        } else {
            themeImageView.image = Icons.Bars.Entrance.light.image
        }
    }

    @objc
    private func backTapped() { onBack?() }
    
    @objc
    private func changeThemeTapped() {
        animateTap(on: themeImageView, disablingInteractionOn: themeView) { [weak self] in
            self?.onChangeColorTheme?()
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

private extension IdentityNavBarView {

    func setupConstraints() {
        [
            backView,
            themeView,
            backImageView,
            themeImageView
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: topAnchor),
            backView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            backView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            themeView.topAnchor.constraint(equalTo: topAnchor),
            themeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            themeView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            themeView.trailingAnchor.constraint(equalTo: trailingAnchor),

            backImageView.centerYAnchor.constraint(equalTo: backView.centerYAnchor),
            backImageView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 25),
            
            backImageView.widthAnchor.constraint(equalToConstant: Layout.navigationBarIconSide),
            backImageView.heightAnchor.constraint(equalToConstant: Layout.navigationBarIconSide),

            themeImageView.centerYAnchor.constraint(equalTo: themeView.centerYAnchor),
            themeImageView.trailingAnchor.constraint(equalTo: themeView.trailingAnchor, constant: -25),
            
            themeImageView.widthAnchor.constraint(equalToConstant: Layout.navigationBarIconSide),
            themeImageView.heightAnchor.constraint(equalToConstant: Layout.navigationBarIconSide)
        ])
    }
}
