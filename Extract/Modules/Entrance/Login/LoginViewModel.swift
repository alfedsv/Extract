//
//  LoginViewModel.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation


final class LoginViewModel {

    // MARK: - Output

    var onLoginSuccess: (() -> Void)?
    var onBack: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?

    // MARK: - Dependencies

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Input

    func loginTapped(username: String, password: String) {
        guard !username.isEmpty, !password.isEmpty else {
            onError?("Заполните все поля")
            return
        }

        onLoading?(true)
        Task { @MainActor in
            defer { self.onLoading?(false) }
            do {
                try await authService.login(username: username, password: password)
                onLoginSuccess?()
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }

    func backTapped() {
        onBack?()
    }
}
