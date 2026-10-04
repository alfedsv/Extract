//
//  HomeFlowCoordinator.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

/// Координатор основного сценария.
///
/// Собирает `HomeTabBarController` с тремя вкладками (Home/Profile/Settings),
/// каждая из которых — свой `UINavigationController` с системным баром скрытым.
final class HomeFlowCoordinator: Coordinator {

    // MARK: - Coordinator

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    // MARK: - Output

    /// Пользователь разлогинился — сообщаем наверх.
    var onLogout: (() -> Void)?

    // MARK: - Dependencies

    private let viewModelFactory: ViewModelFactory

    // MARK: - Init

    init(navigationController: UINavigationController, viewModelFactory: ViewModelFactory) {
        self.navigationController = navigationController
        self.viewModelFactory = viewModelFactory
    }

    // MARK: - Start

    func start() {
        /*let tabBarController = HomeTabBarController()
        tabBarController.viewControllers = [
            makeHomeTab(onLogout: tabBarController),
            makeProfileTab(onLogout: tabBarController),
            makeSettingsTab(onLogout: tabBarController)
        ]

        // Скрываем системный навбар — он нам не нужен нигде.
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([tabBarController], animated: true)*/
    }

    // MARK: - Tabs

    /*private func makeHomeTab(onLogout: HomeTabBarController) -> UINavigationController {
        let viewModel = viewModelFactory.makeHomeViewModel()
        let viewController = HomeViewController()
        viewController.viewModel = viewModel

        // VM публикует onLogout — координатор на него реагирует.
        viewModel.onLogout = { [weak self] in
            self?.onLogout?()
        }

        return makeNavigation(root: viewController)
    }

    private func makeProfileTab(onLogout: HomeTabBarController) -> UINavigationController {
        let viewModel = viewModelFactory.makeProfileViewModel()
        let viewController = ProfileViewController()
        viewController.viewModel = viewModel
        viewModel.onLogout = { [weak self] in self?.onLogout?() }
        return makeNavigation(root: viewController)
    }

    private func makeSettingsTab(onLogout: HomeTabBarController) -> UINavigationController {
        let viewModel = viewModelFactory.makeSettingsViewModel()
        let viewController = SettingsViewController()
        viewController.viewModel = viewModel
        viewModel.onLogout = { [weak self] in self?.onLogout?() }
        return makeNavigation(root: viewController)
    }*/

    // MARK: - Helpers

    /// Создать навигационный контроллер для вкладки.
    /// Системный бар скрыт — используем кастомный `CustomNavBar`.
    private func makeNavigation(root: UIViewController) -> UINavigationController {
        let navigation = UINavigationController(rootViewController: root)
        navigation.setNavigationBarHidden(true, animated: false)
        return navigation
    }
}
