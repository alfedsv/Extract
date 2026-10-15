//
//  PasswordViewController.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

final class PasswordViewController: BaseIdentityViewController {

    private let viewModel: PasswordViewModelProtocol
    private lazy var keyboardAccessory = KeyboardAccessoryView(showsNavigation: false)
    
    // MARK: - UI
    
    private let warningLabel = WarningHelperLabel(state: .warning)
    private let passwordTextView = IdentityTextView(textViewType: .password)
    private let eyeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = Icons.Eye.closed.image
        return imageView
    }()
    private let logoView = LogoView()
    private let nextButton = LargeButtonView(title: L10n.Entrance.Identity.Button.password.localized, isActive: false)
    

    // MARK: - Lifecycle
    
    init(viewModel: PasswordViewModelProtocol) {
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
        eyeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSecureTextEntry)))
        setupConstraints()
    }
    
    // MARK: - Setup UI

    private func setupUI() {
        view.addSubview(warningLabel)
        view.addSubview(passwordTextView)
        passwordTextView.delegate = self
        view.addSubview(eyeImageView)
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
            guard let self = self else { return }
            if isActive {
                self.viewModel.loginTapped(password: self.passwordTextView.text)
            }
        }
    }

    private func bindViewModel() {
        viewModel.onWarning = { [weak self] warning in
            if let warning = warning {
                self?.showWarning(text: warning.message)
                self?.nextButton.isActive = false
            } else {
                self?.showWarning(text: nil)
            }
        }
    }
    
    private func showWarning(text: String?) {
        warningLabel.text = text
        warningLabel.text = text ?? ""
        passwordTextView.isError = (text != nil)
    }
    
    @objc
    private func toggleSecureTextEntry() {
        let isPasswordSecure = passwordTextView.toggleSecureTextEntry()
        eyeImageView.image = isPasswordSecure ? Icons.Eye.closed.image : Icons.Eye.opened.image
        eyeHandler()
    }
    
    // MARK: - Keyboard
    
    private func setupKeyboardAccessory() {
        keyboardAccessory.onDone = { [weak self] in self?.view.endEditing(true) }
        passwordTextView.inputAccessoryView = keyboardAccessory
    }
}

// MARK: - UITextViewDelegate

extension PasswordViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        passwordTextView.setupAppearance()
        eyeHandler()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        passwordTextView.setupAppearance()
        eyeHandler()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let textView = textView as? IdentityTextView {
            return textView.shouldChange(in: range, replacementText: text)
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? IdentityTextView {
            nextButton.isActive = viewModel.isValidLength(text: textView.text)
            textView.setupAppearance()
        }
    }
    
    private func eyeHandler() {
        if passwordTextView.isFirstResponder {
            eyeImageView.isHidden = false
        } else {
            eyeImageView.isHidden = passwordTextView.text.isEmpty
        }
    }
    
}

// MARK: - Layout

private extension PasswordViewController {
    func setupConstraints() {
        [
            warningLabel,
            passwordTextView,
            eyeImageView,
            logoView,
            nextButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            warningLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.sideOutsetStandart),
            warningLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.sideOutsetStandart),
            warningLabel.bottomAnchor.constraint(equalTo: passwordTextView.topAnchor, constant: -5),
            
            passwordTextView.topAnchor.constraint(equalTo: contentTopAnchor, constant: Layout.Identity.loginTextViewTopOutset),
            passwordTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.sideOutsetStandart),
            passwordTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.sideOutsetStandart),

            eyeImageView.centerYAnchor.constraint(equalTo: passwordTextView.centerYAnchor),
            eyeImageView.trailingAnchor.constraint(equalTo: passwordTextView.trailingAnchor, constant: -15),
            eyeImageView.heightAnchor.constraint(equalToConstant: Layout.Identity.textViewIconSide),
            eyeImageView.widthAnchor.constraint(equalToConstant: Layout.Identity.textViewIconSide),
            
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
