//
//  SplashViewModel.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation

/// VM экрана загрузки.
///
/// Показывается первым.
/// Наружу отдаёт один результат: авторизован или нет.
final class SplashViewModel {

    // MARK: - Output

    /// `true` — авторизован, `false` — нет.
    var onResult: ((Bool) -> Void)?

    // MARK: - Dependencies

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Input

    /// Запустить проверку.
    func check() {
        Task { @MainActor in
            // Небольшая задержка.
            // В реальном проекте здесь могла бы быть валидация токена у сервера.
            try? await Task.sleep(nanoseconds: 700_000_000)

            onResult?(authService.isAuthorized)
        }
    }
}
