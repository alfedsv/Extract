//
//  ThemeManager.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

// MARK: - ThemeManager

/// Менеджер темы оформления приложения.
///
/// Логика работы:
/// 1. Если пользователь ранее вручную выбирал тему — используется сохранённое значение из `UserDefaults`.
/// 2. Если сохранённого значения нет — применяется **системная** тема устройства.
/// 3. Вручную пользователь может переключаться только между `light` и `dark`.
///    Вернуться к «следовать за системой» после ручного выбора нельзя
///    (это by design: система — только стартовое значение).
final class ThemeManager {

    // MARK: - Singleton

    static let shared = ThemeManager()
    private init() {
        applyTheme()
    }

    // MARK: - Theme

    /// Внутреннее состояние темы.
    ///
    /// `.system` — не пользовательский выбор, а признак «пользователь ещё ничего не выбрал».
    /// Используется только на чтение из `UserDefaults`, когда там пусто.
    enum Theme: String {
        case system
        case light
        case dark

        var interfaceStyle: UIUserInterfaceStyle {
            switch self {
            case .system: return .unspecified
            case .light:  return .light
            case .dark:   return .dark
            }
        }
    }

    /// Тема, доступная пользователю для выбора вручную.
    enum UserTheme: String {
        case light
        case dark
    }

    // MARK: - Keys

    private let themeKey = "Theme"

    // MARK: - Current theme

    /// Текущее состояние темы (включая `.system`).
    ///
    /// - Get: сохранённая тема, если есть, иначе `.system`.
    /// - Set: сохраняет и применяет. Устанавливать можно любое значение,
    ///   но UI должен предлагать пользователю только `UserTheme`.
    var theme: Theme {
        get {
            if let saved = UserDefaults.standard.string(forKey: themeKey),
               let t = Theme(rawValue: saved) {
                return t
            }
            return .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: themeKey)
            applyTheme()
        }
    }

    /// Тема, выбранная пользователем вручную (или `nil`, если ещё не выбирал).
    var userTheme: UserTheme? {
        get {
            guard let saved = UserDefaults.standard.string(forKey: themeKey), let t = UserTheme(rawValue: saved) else { return nil }
            return t
        }
        set {
            guard let newValue = newValue else {
                // Сброс ручного выбора — снова следуем за системой.
                UserDefaults.standard.removeObject(forKey: themeKey)
                applyTheme()
                return
            }
            theme = Theme(rawValue: newValue.rawValue) ?? .system
        }
    }

    // MARK: - Switching

    /// Переключает тему между светлой и тёмной.
    ///
    /// Если сейчас тема системная — переключаемся на противоположную текущей системной
    /// (т.е. если система тёмная — уйдём в светлую, и наоборот).
    func switchTheme() {
        switch theme {
        case .light:
            theme = .dark
        case .dark:
            theme = .light
        case .system:
            // Система тёмная -> переключаем на светлую. Система светлая -> на тёмную.
            theme = isSystemDark() ? .light : .dark
        }
    }

    // MARK: - Apply

    /// Применяет текущую тему ко всем окнам приложения.
    func applyTheme() {
        let style = theme.interfaceStyle

        if #available(iOS 13.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                for window in windowScene.windows {
                    window.overrideUserInterfaceStyle = style
                }
            }
        }
        
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }

    // MARK: - Getters

    /// Возвращает текущую тему.
    func getCurrentTheme() -> Theme {
        return theme
    }

    /// `true`, если сейчас реально отображается тёмная тема.
    func isDarkMode() -> Bool {
        switch theme {
        case .dark:  return true
        case .light: return false
        case .system: return isSystemDark()
        }
    }

    // MARK: - Private

    /// Системная тема прямо сейчас (с учётом `UIUserInterfaceStyle` в окне).
    private func isSystemDark() -> Bool {
        if #available(iOS 13.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    return window.traitCollection.userInterfaceStyle == .dark
                }
            }
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
        return false
    }
}
