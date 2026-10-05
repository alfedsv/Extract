//
//  RegistrationViewController.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

final class RegistrationViewController: BaseEntranceViewController {

    private let viewModel: RegistrationViewModel
    private lazy var keyboardAccessory = KeyboardAccessoryView()
    
    // MARK: - UI
    
    private let usernameTextView = IdentityTextView(textViewType: .username)
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
    

    // MARK: - Lifecycle
    
    init(viewModel: RegistrationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindNavBar()
        bindViewModel()
        setupUI()
        setupKeyboardAccessory()
        eyeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSecureTextEntry)))
        setupConstraints()
    }
    
    // MARK: - Setup UI

    private func setupUI() {
        view.addSubview(usernameTextView)
        view.addSubview(passwordTextView)
        usernameTextView.delegate = self
        passwordTextView.delegate = self
        view.addSubview(eyeImageView)
        view.addSubview(logoView)
    }
    
    // MARK: - Binding
    
    private func bindNavBar() {
        navBar.onBack = { [weak self] in
            self?.viewModel.backTapped()
        }
        
        navBar.onChangeColorTheme = {
            ThemeManager.shared.switchTheme()
        }
    }

    private func bindViewModel() {
        viewModel.onError = { [weak self] message in
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        viewModel.onLoading = { [weak self] isLoading in
            /*isLoading ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
            self?.loginButton.isEnabled = !isLoading*/
        }
    }
    
    
    @objc
    private func toggleSecureTextEntry() {
        let isPasswordSecure = passwordTextView.toggleSecureTextEntry()
        eyeImageView.image = isPasswordSecure ? Icons.Eye.closed.image : Icons.Eye.opened.image
        eyeHandler()
    }

    /*@objc private func loginTapped() {
        viewModel.loginTapped(
            username: usernameField.text ?? "",
            password: passwordField.text ?? ""
        )
    }*/
    
    // MARK: - Keyboard
    
    private func setupKeyboardAccessory() {
        keyboardAccessory.onPrevious = { [weak self] in self?.focusPrevious() }
        keyboardAccessory.onNext = { [weak self] in self?.focusNext() }
        keyboardAccessory.onDone = { [weak self] in self?.view.endEditing(true) }

        usernameTextView.inputAccessoryView = keyboardAccessory
        passwordTextView.inputAccessoryView = keyboardAccessory
    }
    
    private func focusPrevious() {
        let allTextViews = [usernameTextView, passwordTextView]
        guard let current = currentResponder(), let idx = allTextViews.firstIndex(of: current) else { return }

        for i in stride(from: idx - 1, through: 0, by: -1) where allTextViews[i].isUserInteractionEnabled {
            _ = allTextViews[i].becomeFirstResponder()
            return
        }
    }

    private func focusNext() {
        let allTextViews = [usernameTextView, passwordTextView]
        guard let current = currentResponder(), let idx = allTextViews.firstIndex(of: current) else { return }

        for i in (idx + 1)..<allTextViews.count where allTextViews[i].isUserInteractionEnabled {
            _ = allTextViews[i].becomeFirstResponder()
            return
        }
    }

    private func currentResponder() -> IdentityTextView? {
        let allTextViews = [usernameTextView, passwordTextView]
        return allTextViews.first { $0.isFirstResponder }
    }
    
    private func updateAccessoryState() {
        let allTextViews = [usernameTextView, passwordTextView]
        guard let current = currentResponder(), let idx = allTextViews.firstIndex(of: current) else { return }

        let hasPrevious = allTextViews[..<idx].contains { $0.isUserInteractionEnabled }
        let hasNext = allTextViews[(idx + 1)...].contains { $0.isUserInteractionEnabled }

        keyboardAccessory.setNavigation(previous: hasPrevious, next: hasNext)
    }
    
}

// MARK: - UITextViewDelegate

extension RegistrationViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        usernameTextView.setupAppearance()
        passwordTextView.setupAppearance()
        updateAccessoryState()
        eyeHandler()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        usernameTextView.setupAppearance()
        passwordTextView.setupAppearance()
        updateAccessoryState()
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
            textView.setupAppearance()
            eyeHandler()
        }
        if textView === usernameTextView {
            updatePasswordAvailability()
        }
    }
    
    private func updatePasswordAvailability() {
        let username = usernameTextView.text ?? ""
        let hasLogin = username.count > Settings.IdentityTextView.usernameClosedRange.lowerBound
        passwordTextView.isUserInteractionEnabled = hasLogin
        updateAccessoryState()
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

private extension RegistrationViewController {
    func setupConstraints() {
        [
            usernameTextView,
            passwordTextView,
            eyeImageView,
            logoView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            usernameTextView.topAnchor.constraint(equalTo: contentTopAnchor, constant: 150),
            usernameTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.sideOutsetStandart),
            usernameTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            passwordTextView.topAnchor.constraint(equalTo: usernameTextView.bottomAnchor, constant: 35),
            passwordTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.sideOutsetStandart),
            passwordTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.sideOutsetStandart),

            eyeImageView.centerYAnchor.constraint(equalTo: passwordTextView.centerYAnchor),
            eyeImageView.trailingAnchor.constraint(equalTo: passwordTextView.trailingAnchor, constant: -15),
            eyeImageView.heightAnchor.constraint(equalToConstant: Layout.Identity.textViewEyeSide),
            eyeImageView.widthAnchor.constraint(equalToConstant: Layout.Identity.textViewEyeSide),
            
            logoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200),
            logoView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoView.heightAnchor.constraint(equalToConstant: Layout.logoViewSize.height),
            logoView.widthAnchor.constraint(equalToConstant: Layout.logoViewSize.width)
        ])

    }
}

