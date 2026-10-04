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
        let vc = WelcomeViewController()
        vc.viewModel = vm

        vm.onLoginTap    = { [weak self] in self?.showLogin() }
        vm.onRegisterTap = { [weak self] in self?.showRegister() }

        // Welcome — корень. Кладём его одним экраном в стек.
        navigationController.setViewControllers([vc], animated: true)
    }

    // MARK: - Login

    private func showLogin() {
        let vm = viewModelFactory.makeLoginViewModel()
        let vc = LoginViewController()
        vc.viewModel = vm
        vm.onLoginSuccess = { [weak self] in self?.onFinish?() }
        // Кнопка «назад» на логине ведёт обратно на welcome.
        vm.onBack = { [weak self] in self?.navigationController.popViewController(animated: true) }
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Registration

    private func showRegister() {
        let vm = viewModelFactory.makeRegistrationViewModel()
        let vc = RegistrationViewController()
        vc.viewModel = vm
        vm.onRegisterSuccess = { [weak self] in self?.onFinish?() }
        vm.onBack = { [weak self] in self?.navigationController.popViewController(animated: true) }
        navigationController.pushViewController(vc, animated: true)
    }
}
