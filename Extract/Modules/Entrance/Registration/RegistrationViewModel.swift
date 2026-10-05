//
//  RegistrationViewModel.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation


final class RegistrationViewModel {

    // MARK: - Output

    /// Регистрация успешна.
    var onRegisterSuccess: (() -> Void)?

    /// Пользователь нажал «назад».
    var onBack: (() -> Void)?

    /// Ошибка — показать сообщение.
    var onError: ((String) -> Void)?

    /// Состояние загрузки — показать/скрыть спиннер, заблокировать кнопку.
    var onLoading: ((Bool) -> Void)?

    // MARK: - Dependencies

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Input

    /// Пользователь нажал «Зарегистрироваться».
    func registerTapped(username: String,
                        password: String,
                        confirmPassword: String) {

        // 1. Локальная валидация до сети.
        if let error = validate(username: username,
                                password: password,
                                confirmPassword: confirmPassword) {
            onError?(error)
            return
        }

        // 2. Запрос.
        onLoading?(true)
        Task { @MainActor in
            /*defer { self.onLoading?(false) }
            do {
                try await authService.register(username: username, password: password)
                onRegisterSuccess?()
            } catch {
                onError?(error.localizedDescription)
            }*/
        }
    }

    /// Пользователь нажал «назад».
    func backTapped() {
        onBack?()
    }

    // MARK: - Validation

    /// Проверка ввода. Возвращает текст ошибки или `nil`, если всё ок.
    private func validate(username: String,
                          password: String,
                          confirmPassword: String) -> String? {
        if username.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            return "Заполните все поля"
        }
        if password.count < 6 {
            return "Пароль должен содержать минимум 6 символов"
        }
        if password != confirmPassword {
            return "Пароли не совпадают"
        }
        return nil
    }
}
