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
    func makeUsernameViewModel() -> UsernameViewModel
    func makePasswordViewModel(username: String) -> PasswordViewModel
    func makeRegistrationViewModel() -> RegistrationViewModel

    // Main
    func makeHomeViewModel() -> HomeViewModel
}

final class AppViewModelFactory: ViewModelFactory {

    private nonisolated let authService: AuthServiceProtocol
    private nonisolated let entranceRepository: EntranceRepositoryProtocol
    private nonisolated let logger: LoggerProtocol

    nonisolated init(
        authService: AuthServiceProtocol,
        entranceRepository: EntranceRepositoryProtocol,
        logger: LoggerProtocol
    ) {
        self.authService = authService
        self.entranceRepository = entranceRepository
        self.logger = logger
    }

    // MARK: - Splash

    func makeSplashViewModel() -> SplashViewModel {
        SplashViewModel(authService: authService)
    }

    // MARK: - Entrance

    func makeWelcomeViewModel() -> WelcomeViewModel {
        WelcomeViewModel()   // без зависимостей — просто пробрасывает события
    }

    func makeUsernameViewModel() -> UsernameViewModel {
        UsernameViewModel(
            entranceRepository: entranceRepository,
            logger: logger
        )
    }
    
    func makePasswordViewModel(username: String) -> PasswordViewModel {
        PasswordViewModel(
            authService: authService,
            logger: logger,
            username: username)
    }

    func makeRegistrationViewModel() -> RegistrationViewModel {
        RegistrationViewModel(
            authService: authService,
            entranceRepository: entranceRepository,
            logger: logger)
    }

    // MARK: - Home

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel()
    }

}
