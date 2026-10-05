//
//  WelcomeViewController.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

final class WelcomeViewController: BaseViewController {
    
    private let viewModel: WelcomeViewModel
    
    // MARK: - UI

    private let greetingBar = GreetingBarView()
    private let buttons: [WelcomeButtonImageView]
    private let stackView: UIStackView
    private let logoZoneGuide = UILayoutGuide()
    private let logoView = LogoView()
    
    // MARK: - Lifecycle
    

    init(viewModel: WelcomeViewModel) {
        self.viewModel = viewModel
        self.buttons = [
            WelcomeButtonImageView(command: .login),
            WelcomeButtonImageView(command: .registrate),
            WelcomeButtonImageView(command: .demo),
            WelcomeButtonImageView(command: .representers)
        ]
        self.stackView = UIStackView(arrangedSubviews: buttons)
        super.init(nibName: nil, bundle: nil)
        for button in buttons {
            button.delegate = self
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        greetingBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Если язык/тему могли менять на другом экране — синхронизируем иконки.
        greetingBar.refreshIcons()
        for button in self.buttons {
            button.refreshLocalization()
        }
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = Colors.App.background.color
        view.addSubview(greetingBar)
        stackView.axis = .vertical
        stackView.spacing = Layout.Welcome.buttonSpacing
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        view.addLayoutGuide(logoZoneGuide)
        view.addSubview(logoView)
    }
}

// MARK: - GreetingBarDelegate, WelcomeButtonDelegate

extension WelcomeViewController: GreetingBarDelegate, WelcomeButtonDelegate {

    func buttonTapped(command: WelcomeButtonCommand) {
        viewModel.buttonTapped(command: command)
    }

    func welcomeButtonsLock(isLocked: Bool) {
        self.buttons.forEach( { $0.isUserInteractionEnabled = !isLocked })
    }
    
    /// Переключение языка
    func changeLanguage() {
        LanguageManager.shared.switchLanguage()
        self.buttons.forEach( { $0.refreshLocalization() })
    }

    /// Переключение темы  светлую/тёмную.
    func changeColorTheme() {
        ThemeManager.shared.switchTheme()
    }
}

// MARK: - Layout

private extension WelcomeViewController {
    func setupConstraints() {
        [
            greetingBar,
            stackView,
            logoView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            greetingBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            greetingBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            greetingBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            greetingBar.heightAnchor.constraint(equalToConstant: Layout.navigationBarsHeight),

            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.Welcome.buttonSidePadding),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.Welcome.buttonSidePadding),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: Layout.Welcome.buttonsY),
            
            logoZoneGuide.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            logoZoneGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            logoView.centerYAnchor.constraint(equalTo: logoZoneGuide.centerYAnchor),
            logoView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoView.heightAnchor.constraint(equalToConstant: Layout.logoViewSize.height),
            logoView.widthAnchor.constraint(equalToConstant: Layout.logoViewSize.width)
        ])
        
        
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: Layout.Welcome.buttonHeight)
            ])
        }
    }
}
