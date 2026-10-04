//
//  ViewModelFactory.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation


protocol ViewModelFactory {
    // Splash
    func makeSplashViewModel() -> SplashViewModel

    // Entrance
    func makeWelcomeViewModel() -> WelcomeViewModel
    func makeLoginViewModel() -> LoginViewModel
    func makeRegistrationViewModel() -> RegistrationViewModel

    // Main
    func makeHomeViewModel() -> HomeViewModel
}

final class AppViewModelFactory: ViewModelFactory {

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Splash

    func makeSplashViewModel() -> SplashViewModel {
        SplashViewModel(authService: authService)
    }

    // MARK: - Entrance

    func makeWelcomeViewModel() -> WelcomeViewModel {
        WelcomeViewModel()   // без зависимостей — просто пробрасывает события
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authService: authService)
    }

    func makeRegistrationViewModel() -> RegistrationViewModel {
        RegistrationViewModel(authService: authService)
    }

    // MARK: - Home

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel()
    }

}
