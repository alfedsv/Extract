//
//  UsernameViewController.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

final class UsernameViewController: BaseIdentityViewController {

    private let viewModel: UsernameViewModelProtocol
    private lazy var keyboardAccessory = KeyboardAccessoryView(showsNavigation: false)
    
    // MARK: - UI
    
    private let warningLabel = WarningHelperLabel(state: .warning)
    private let usernameTextView = IdentityTextView(textViewType: .username)
    private let logoView = LogoView()
    private let nextButton = LargeButtonView(title: L10n.Entrance.Identity.Button.username.localized, isActive: false)
    

    // MARK: - Lifecycle
    
    init(viewModel: UsernameViewModelProtocol) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        bindViewModel()
        setupUI()
        setupKeyboardAccessory()
        setupConstraints()
    }
    
    // MARK: - Setup UI

    private func setupUI() {
        view.addSubview(warningLabel)
        view.addSubview(usernameTextView)
        usernameTextView.delegate = self
        view.addSubview(logoView)
        view.addSubview(nextButton)
    }
    
    // MARK: - Binding
    
    private func bind() {
        navBar.onBack = { [weak self] in
            self?.viewModel.backTapped()
        }
        
        navBar.onChangeColorTheme = {
            ThemeManager.shared.switchTheme()
        }
        
        nextButton.onPressed = { [weak self] isActive in
            if isActive {
                guard let self = self else { return }
                self.viewModel.nextTapped(username: self.usernameTextView.text)
            }
        }
    }

    private func bindViewModel() {
        viewModel.onWarning = { [weak self] warning in
            if let warning = warning {
                self?.showWarning(text: warning.message)
                if warning.warning == .notUserExists {
                    self?.nextButton.isActive = false
                }
            } else {
                self?.showWarning(text: nil)
            }
        }
        
    }
    
    private func showWarning(text: String?) {
        warningLabel.text = text ?? ""
        usernameTextView.isError = (text != nil)
    }

    // MARK: - Keyboard
    
    private func setupKeyboardAccessory() {
        keyboardAccessory.onDone = { [weak self] in self?.view.endEditing(true) }
        usernameTextView.inputAccessoryView = keyboardAccessory
    }
}

// MARK: - UITextViewDelegate

extension UsernameViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        usernameTextView.setupAppearance()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        usernameTextView.setupAppearance()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let textView = textView as? IdentityTextView {
            let isValid = textView.shouldChange(in: range, replacementText: text)
            viewModel.setupWarning(warning: isValid ? nil : .init(warning: .usernameNotValid, textViewType: .username))
            return isValid
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? IdentityTextView {
            nextButton.isActive = viewModel.isValidLength(text: textView.text)
            textView.setupAppearance()
        }
    }
    
}

// MARK: - Layout

private extension UsernameViewController {
    func setupConstraints() {
        [
            warningLabel,
            usernameTextView,
            logoView,
            nextButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            warningLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.sideOutsetStandart),
            warningLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.sideOutsetStandart),
            warningLabel.bottomAnchor.constraint(equalTo: usernameTextView.topAnchor, constant: -5),
            
            usernameTextView.topAnchor.constraint(equalTo: contentTopAnchor, constant: Layout.Identity.loginTextViewTopOutset),
            usernameTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.sideOutsetStandart),
            usernameTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            logoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200),
            logoView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoView.heightAnchor.constraint(equalToConstant: Layout.logoViewSize.height),
            logoView.widthAnchor.constraint(equalToConstant: Layout.logoViewSize.width),
            
            nextButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.sideOutsetStandart),
            nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.sideOutsetStandart),
            nextButton.heightAnchor.constraint(equalToConstant: Layout.largeButtonHeight),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            
        ])

    }
}
