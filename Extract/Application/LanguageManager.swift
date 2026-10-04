//
//  LanguageManager.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation


final class LanguageManager {

    // MARK: - Singleton

    static let shared = LanguageManager()

    private init() {
        Bundle.setLanguage(lang: language.rawValue)
    }

    // MARK: - Language

    enum Language: String, CaseIterable {
        case russian = "ru"
        case english = "en"
    }

    // MARK: - Keys

    private let languageKey = "Language"

    // MARK: - Current language

    var language: Language {
        get {
            if let saved = UserDefaults.standard.string(forKey: languageKey),
               let lang = Language(rawValue: saved) {
                return lang
            }
            return LanguageManager.systemLanguage()
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: languageKey)
            Bundle.setLanguage(lang: newValue.rawValue)
        }
    }

    // MARK: - System language

    static func systemLanguage() -> Language {
        let preferred = Locale.preferredLanguages.first ?? "en"
        let available = Bundle.main.localizations

        if preferred.hasPrefix("ru"), available.contains("ru") { return .russian }
        if preferred.hasPrefix("en"), available.contains("en") { return .english }
        return .english
    }

    // MARK: - Switching

    /// Переключает язык на противоположный (ru <-> en).
    func switchLanguage() {
        switch language {
        case .russian: language = .english
        case .english: language = .russian
        }
    }

    /// Устанавливает конкретный язык.
    func setLanguage(_ lang: Language) {
        language = lang
    }

    // MARK: - Getters

    func getCurrentLanguage() -> Language { language }

    func getLocaleIdentifier() -> String {
        switch language {
        case .russian: return "ru_RU"
        case .english: return "en_US"
        }
    }
}

// MARK: - Bundle + Localization

extension Bundle {

    /// Кэш бандла вместе с языком, для которого он получен.
    private static var cachedLanguage: String?
    private static var cachedBundle: Bundle?

    /// Возвращает бандл, соответствующий текущему языку приложения.
    static func localizedBundle() -> Bundle {
        let language = LanguageManager.shared.language.rawValue

        if cachedLanguage == language, let bundle = cachedBundle {
            return bundle
        }

        let bundle = makeBundle(for: language) ?? makeBundle(for: "en") ?? .main
        cachedLanguage = language
        cachedBundle = bundle
        return bundle
    }

    /// Устанавливает локализованный бандл для указанного языка.
    static func setLanguage(lang: String) {
        cachedLanguage = nil
        cachedBundle = nil

        if let bundle = makeBundle(for: lang) {
            cachedLanguage = lang
            cachedBundle = bundle
        }
    }

    // MARK: - Private

    private static func makeBundle(for language: String) -> Bundle? {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return nil
        }
        return bundle
    }
}

