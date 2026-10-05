//
//  LoginViewController.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

final class LoginViewController: BaseEntranceViewController {

    private let viewModel: AuthViewModel
    private lazy var keyboardAccessory = KeyboardAccessoryView()
    
    // MARK: - UI
    
    private let usernameTextView = IdentityTextView(textViewType: .username)
    private let logoView = LogoView()
    private let nextButton = LargeButtonView(title: "234234", isActive: false)
    

    // MARK: - Lifecycle
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
        
        nextButton.onPressed = {
            print("123234 dfgf jkl 546")
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

    // MARK: - Keyboard
    
    private func setupKeyboardAccessory() {
        keyboardAccessory.onDone = { [weak self] in self?.view.endEditing(true) }
        usernameTextView.inputAccessoryView = keyboardAccessory
    }
}

// MARK: - UITextViewDelegate

extension LoginViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        usernameTextView.setupAppearance()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        usernameTextView.setupAppearance()
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
        }
    }
    
}

// MARK: - Layout

private extension LoginViewController {
    func setupConstraints() {
        [
            usernameTextView,
            logoView,
            nextButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            usernameTextView.topAnchor.constraint(equalTo: contentTopAnchor, constant: 150),
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
