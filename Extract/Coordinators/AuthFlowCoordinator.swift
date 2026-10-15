//
//  AuthFlowCoordinator.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit


/// Координатор сценария авторизации.
///
/// Флоу: Welcome→ (Login | Register) → onFinish (успех).
///
/// Welcome — корень сценария. С него можно уйти только в login/register
/// или завершить сценарий (после успешного входа).
final class AuthCoordinator: Coordinator {

    // MARK: - Coordinator

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    // MARK: - Output

    /// Сценарий авторизации завершён (успешный вход/регистрация).
    var onFinish: (() -> Void)?

    // MARK: - Dependencies

    private let viewModelFactory: ViewModelFactory

    // MARK: - Init

    init(navigationController: UINavigationController, viewModelFactory: ViewModelFactory) {
        self.navigationController = navigationController
        self.viewModelFactory = viewModelFactory
    }

    // MARK: - Start

    func start() {
        showWelcome()
    }

    // MARK: - Welcome

    private func showWelcome() {
        let vm = viewModelFactory.makeWelcomeViewModel()
        let vc = WelcomeViewController(viewModel: vm)
        vm.onLoginTap    = { [weak self] in self?.showUsername() }
        vm.onRegisterTap = { [weak self] in self?.showRegister() }
        navigationController.setViewControllers([vc], animated: true)
    }

    // MARK: - Username

    private func showUsername() {
        let vm = viewModelFactory.makeUsernameViewModel()
        let vc = UsernameViewController(viewModel: vm)
        vm.onBack = { [weak self] in self?.navigationController.popViewController(animated: true) }
        vm.onNext = { [weak self] username in
            self?.showPassword(username: username)
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Password

    private func showPassword(username: String) {
        let vm = viewModelFactory.makePasswordViewModel(username: username)
        let vc = PasswordViewController(viewModel: vm)
        vm.onBack = { [weak self] in self?.navigationController.popViewController(animated: true) }
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Registration

    private func showRegister() {
        let vm = viewModelFactory.makeRegistrationViewModel()
        let vc = RegistrationViewController(viewModel: vm)
        vm.onRegisterSuccess = { [weak self] in self?.onFinish?() }
        vm.onBack = { [weak self] in self?.navigationController.popViewController(animated: true) }
        navigationController.pushViewController(vc, animated: true)
    }
}
