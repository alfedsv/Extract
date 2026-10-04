//
//  ThemeAwareVisualEffectView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit


/// `UIVisualEffectView`, который перерисовывает свой effect
/// при смене светлой/тёмной темы. Иначе UIKit оставляет старый
/// отрендеренный снимок до пересоздания вью.
final class ThemeAwareVisualEffectView: UIVisualEffectView {

    private var pendingEffectUpdate = false

    init() {
        super.init(effect: nil)
        applyEffectImmediately()
        observe()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyEffectImmediately()
        observe()
    }

    private func observe() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: .themeDidChange,
            object: nil
        )
    }

    @objc
    private func handleThemeChange() {
        scheduleEffectUpdate()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        scheduleEffectUpdate()
    }

    private func scheduleEffectUpdate() {
        guard !pendingEffectUpdate else { return }
        pendingEffectUpdate = true

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.pendingEffectUpdate = false
            self.applyEffectImmediately()
        }
    }

    private func applyEffectImmediately() {
        let newEffect: UIVisualEffect
        if #available(iOS 26.0, *) {
            newEffect = UIGlassEffect()
        } else {
            newEffect = UIBlurEffect(style: .systemChromeMaterial)
        }

        effect = nil
        effect = newEffect
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
