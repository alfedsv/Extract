//
//  AppCoordinator.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit


/// Корневой координатор.
///
/// Флоу запуска:
///   Splash → (авторизован? → Home : Auth)
/// Auth-флоу:
///   Welcome → Login/Register → Home
final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    private let viewModelFactory: ViewModelFactory

    init(navigationController: UINavigationController,
         viewModelFactory: ViewModelFactory) {
        self.navigationController = navigationController
        self.viewModelFactory = viewModelFactory
    }

    func start() {
        showSplash()
    }

    // MARK: - Splash

    private func showSplash() {
        let vm = viewModelFactory.makeSplashViewModel()
        let vc = SplashViewController()
        vc.viewModel = vm

        // Подписываемся ДО того, как VC вызовет check() в viewDidAppear.
        vm.onResult = { [weak self] isAuthorized in
            guard let self else { return }
            isAuthorized ? self.showMain() : self.showAuth()
        }

        navigationController.setViewControllers([vc], animated: false)
    }

    // MARK: - Main

    private func showMain() {
        let coordinator = HomeFlowCoordinator(
            navigationController: navigationController,
            viewModelFactory: viewModelFactory
        )

        coordinator.onLogout = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.removeChild(coordinator)
            self.showAuth()
        }

        addChild(coordinator)
        coordinator.start()
    }

    // MARK: - Auth

    private func showAuth() {
        let coordinator = AuthCoordinator(navigationController: navigationController, viewModelFactory: viewModelFactory)

        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.removeChild(coordinator)
            self.showMain()
        }

        addChild(coordinator)
        coordinator.start()
    }
}
