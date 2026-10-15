//
//  RegistrationViewController.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

final class RegistrationViewController: BaseIdentityViewController {

    private let viewModel: RegistrationViewModel
    private lazy var keyboardAccessory = KeyboardAccessoryView(showsNavigation: true)
    private var keyboardHeight: CGFloat = 0
    
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let firstNameTextView = IdentityTextView(textViewType: .firstName)
    private let lastNameTextView = IdentityTextView(textViewType: .lastName)
    private let usernameTextView = IdentityTextView(textViewType: .username)
    private let passwordTextView = IdentityTextView(textViewType: .password)
    private let confirmTextView = IdentityTextView(textViewType: .confirm)
    private let firstWarningLabel = WarningHelperLabel(state: .warning)
    private let lastWarningLabel = WarningHelperLabel(state: .warning)
    private let usernameWarningLabel = WarningHelperLabel(state: .warning)
    private let passwordWarningLabel = WarningHelperLabel(state: .warning)
    private let confirmWarningLabel = WarningHelperLabel(state: .warning)
    private let agreementWarningLabel = WarningHelperLabel(state: .warning)
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = Icons.Mark.checkmark.image
        return imageView
    }()
    private let eyePasswordImageView = EyeImageView()
    private let eyeConfirmImageView = EyeImageView()
    private let usernameIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = .medium
        return indicator
    }()
    private let usernameHelperLabel = WarningHelperLabel(state: .helper, text: L10n.Entrance.Identity.Helper.usernameValid.localized)
    private let passwordHelperLabel = WarningHelperLabel(state: .helper, text: L10n.Entrance.Identity.Helper.passwordValid.localized(Settings.IdentityTextView.passwordClosedRange.lowerBound))
    
    private let agreementSwitch = UISwitch()

    private let agreementLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = Colors.Text.common.color
        label.font = .systemFont(ofSize: 15)
        label.text = L10n.Entrance.Identity.RegistrationAgreement.agreement.localized
        return label
    }()

    private let logoView = LogoView()
    private let signupButton = LargeButtonView(title: L10n.Entrance.Identity.Button.registration.localized, isActive: false)

    // MARK: - Lifecycle
    
    init(viewModel: RegistrationViewModel) {
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
        eyePasswordImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSecureTextEntry(_:))))
        eyeConfirmImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSecureTextEntry(_:))))
        setupConstraints()
    }
    
    // MARK: - Setup UI

    private func setupUI() {

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(firstNameTextView)
        contentView.addSubview(lastNameTextView)
        contentView.addSubview(usernameTextView)
        contentView.addSubview(passwordTextView)
        contentView.addSubview(confirmTextView)

        contentView.addSubview(firstWarningLabel)
        contentView.addSubview(lastWarningLabel)
        contentView.addSubview(usernameWarningLabel)
        contentView.addSubview(passwordWarningLabel)
        contentView.addSubview(confirmWarningLabel)
        contentView.addSubview(agreementWarningLabel)
        contentView.addSubview(usernameHelperLabel)
        contentView.addSubview(passwordHelperLabel)
        
        contentView.addSubview(agreementSwitch)
        contentView.addSubview(agreementLabel)
        contentView.addSubview(signupButton)
        
        firstNameTextView.delegate = self
        lastNameTextView.delegate = self
        usernameTextView.delegate = self
        passwordTextView.delegate = self
        confirmTextView.delegate = self

        contentView.addSubview(checkmarkImageView)
        contentView.addSubview(usernameIndicator)
        contentView.addSubview(eyePasswordImageView)
        contentView.addSubview(eyeConfirmImageView)
        contentView.addSubview(logoView)
        
        agreementSwitch.addTarget(self, action: #selector(agreementValueDidChange), for: .valueChanged)
        agreementSwitch.isOn = false
        
    }
    
    // MARK: - Binding
    
    private func bind() {
        navBar.onBack = { [weak self] in
            self?.viewModel.backTapped()
        }
        
        navBar.onChangeColorTheme = {
            ThemeManager.shared.switchTheme()
        }
        
        signupButton.onPressed = { [weak self] isActive in
            guard let self = self else { return }
            viewModel.signupTapped(
                isActive: isActive,
                firstName: self.firstNameTextView.text,
                lastName: self.lastNameTextView.text,
                username: self.usernameTextView.text,
                password: self.passwordTextView.text,
                confirm: self.confirmTextView.text,
                isAgreementAccepted: agreementSwitch.isOn
            )
        }
    }

    private func bindViewModel() {
        viewModel.onWarning = { [weak self] warnings in
            guard let self = self else { return }
            self.showWarnings(warnings: warnings)
        }
        
        viewModel.onUsernameChecking = { [weak self] isActive in
            guard let self = self else { return }
            if isActive {
                self.usernameIndicator.startAnimating()
            } else {
                self.usernameIndicator.stopAnimating()
            }
        }
        
        viewModel.onUsernameChecked = { [weak self] isValid in
            guard let self = self else { return }
            self.checkmarkImageView.isHidden = !isValid
        }
    }
    
    
    @objc
    private func toggleSecureTextEntry(_ sender: UITapGestureRecognizer) {
        if sender.view == eyePasswordImageView {
            let isPasswordSecure = passwordTextView.toggleSecureTextEntry()
            eyePasswordImageView.image = isPasswordSecure ? Icons.Eye.closed.image : Icons.Eye.opened.image
            eyeHandler(textView: passwordTextView)
        } else if sender.view  == eyeConfirmImageView {
            let isConfirmSecure = confirmTextView.toggleSecureTextEntry()
            eyeConfirmImageView.image = isConfirmSecure ? Icons.Eye.closed.image : Icons.Eye.opened.image
            eyeHandler(textView: confirmTextView)
        }
    }
    
    @objc
    func agreementValueDidChange(sender: UISwitch) {
        agreementWarningLabel.text = ""
    }
    
    private func showWarnings(warnings: [IdentityWarning]) {
        for warning in warnings {
            if warning.textViewType == .firstName {
                firstWarningLabel.text = warning.message
                firstNameTextView.isError = true
            }
            if warning.textViewType == .lastName {
                lastWarningLabel.text = warning.message
                lastNameTextView.isError = true
            }
            if warning.textViewType == .username {
                usernameWarningLabel.text = warning.message
                usernameTextView.isError = true
            }
            if warning.textViewType == .password {
                passwordTextView.isError = true
                if case .tooShort = warning.warning {
                    passwordHelperLabel.setup(state: .warning)
                } else {
                    passwordWarningLabel.text = warning.message
                }
            }
            if warning.textViewType == .confirm {
                confirmWarningLabel.text = warning.message
                confirmTextView.isError = true
            }
            if warning.textViewType == nil {
                agreementWarningLabel.text = warning.message
            }
        }
    }
    
    // MARK: - Keyboard

    private func setupKeyboardAccessory() {
        keyboardAccessory.onPrevious = { [weak self] in self?.focusPrevious() }
        keyboardAccessory.onNext = { [weak self] in self?.focusNext() }
        keyboardAccessory.onDone = { [weak self] in self?.view.endEditing(true) }

        firstNameTextView.inputAccessoryView = keyboardAccessory
        lastNameTextView.inputAccessoryView = keyboardAccessory
        usernameTextView.inputAccessoryView = keyboardAccessory
        passwordTextView.inputAccessoryView = keyboardAccessory
        confirmTextView.inputAccessoryView = keyboardAccessory

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc
    private func keyboardUp(_ note: Notification) {
        guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let frameInView = view.convert(frame, from: nil)
        keyboardHeight = max(0, view.bounds.height - frameInView.minY)
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
        scrollToCurrentResponder()
    }

    @objc
    private func keyboardDown() {
        keyboardHeight = 0
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    private func scrollToCurrentResponder(animated: Bool = true) {
        guard let textView = currentResponder(), keyboardHeight > 0 else { return }

        let rect = textView.convert(textView.bounds, to: scrollView)
        let padding: CGFloat = 10

        // хотим: rect.maxY попал на (bounds.height - keyboardHeight - padding)
        // => contentOffset.y >= rect.maxY - bounds.height + keyboardHeight + padding
        let targetY = rect.maxY - scrollView.bounds.height + keyboardHeight + padding

        let maxY = max(0, scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.height)
        let clampedY = min(max(targetY, 0), maxY)

        scrollView.setContentOffset(CGPoint(x: 0, y: clampedY), animated: animated)
    }
    
    private func focusPrevious() {
        let allTextViews = [
            firstNameTextView,
            lastNameTextView,
            usernameTextView,
            passwordTextView,
            confirmTextView
        ]
        guard let current = currentResponder(), let idx = allTextViews.firstIndex(of: current) else { return }

        for i in stride(from: idx - 1, through: 0, by: -1) where allTextViews[i].isUserInteractionEnabled {
            _ = allTextViews[i].becomeFirstResponder()
            return
        }
    }

    private func focusNext() {
        let allTextViews = [
            firstNameTextView,
            lastNameTextView,
            usernameTextView,
            passwordTextView,
            confirmTextView
        ]
        guard let current = currentResponder(), let idx = allTextViews.firstIndex(of: current) else { return }

        for i in (idx + 1)..<allTextViews.count where allTextViews[i].isUserInteractionEnabled {
            _ = allTextViews[i].becomeFirstResponder()
            return
        }
    }

    private func currentResponder() -> IdentityTextView? {
        let allTextViews = [
            firstNameTextView,
            lastNameTextView,
            usernameTextView,
            passwordTextView,
            confirmTextView
        ]
        return allTextViews.first { $0.isFirstResponder }
    }
    
    private func updateAccessoryState() {
        let allTextViews = [
            firstNameTextView,
            lastNameTextView,
            usernameTextView,
            passwordTextView,
            confirmTextView
        ]
        guard let current = currentResponder(), let idx = allTextViews.firstIndex(of: current) else { return }

        let hasPrevious = allTextViews[..<idx].contains { $0.isUserInteractionEnabled }
        let hasNext = allTextViews[(idx + 1)...].contains { $0.isUserInteractionEnabled }

        keyboardAccessory.setNavigation(previous: hasPrevious, next: hasNext)
    }

}

// MARK: - UITextViewDelegate

extension RegistrationViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        setupAppearance()
        if let textView = textView as? IdentityTextView {
            clearWarning(type: textView.textViewType)
            eyeHandler(textView: textView)
        }
        updateAccessoryState()
        
        Task { @MainActor [weak self] in
            self?.scrollToCurrentResponder()
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        setupAppearance()
        updateAccessoryState()
        eyeHandler(textView: textView)
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
            clearWarning(type: textView.textViewType)
            eyeHandler(textView: textView)
            if textView.textViewType == .username {
                checkmarkImageView.isHidden = true
                viewModel.usernameChanged(username: textView.text)
            }
        }
    }
    
    private func setupAppearance() {
        let allTextViews = [
            firstNameTextView,
            lastNameTextView,
            usernameTextView,
            passwordTextView,
            confirmTextView
        ]
        allTextViews.forEach( { $0.setupAppearance() } )
    }
    
    private func eyeHandler(textView: UITextView) {
        guard let textView = textView as? IdentityTextView else { return }
        guard (textView.textViewType == .password || textView.textViewType == .confirm) else { return }
        if textView.isFirstResponder {
            if textView.textViewType == .password {
                eyePasswordImageView.isHidden = false
            } else if textView.textViewType == .confirm {
                eyeConfirmImageView.isHidden = false
            }
        } else {
            if textView.textViewType == .password {
                eyePasswordImageView.isHidden = passwordTextView.text.isEmpty
            } else if textView.textViewType == .confirm {
                eyeConfirmImageView.isHidden = confirmTextView.text.isEmpty
            }
        }
    }

    private func clearWarning(type: IdentityTextViewType) {
        switch type {
        case .firstName:
            firstWarningLabel.text = ""
            firstNameTextView.isError = false
        case .lastName:
            lastWarningLabel.text = ""
            lastNameTextView.isError = false
        case .username:
            usernameWarningLabel.text = ""
            usernameTextView.isError = false
        case .password:
            passwordHelperLabel.setup(state: .helper)
            passwordWarningLabel.text = ""
            confirmWarningLabel.text = ""
            passwordTextView.isError = false
            confirmTextView.isError = false
        case .confirm:
            confirmWarningLabel.text = ""
            confirmTextView.isError = false
        }
    }
}

// MARK: - Layout

private extension RegistrationViewController {
    func setupConstraints() {
        [
            scrollView,
            contentView,
            firstNameTextView,
            lastNameTextView,
            usernameTextView,
            passwordTextView,
            confirmTextView,
            firstWarningLabel,
            lastWarningLabel,
            usernameWarningLabel,
            passwordWarningLabel,
            confirmWarningLabel,
            agreementWarningLabel,
            usernameHelperLabel,
            passwordHelperLabel,
            checkmarkImageView,
            usernameIndicator,
            eyePasswordImageView,
            eyeConfirmImageView,
            logoView,
            agreementSwitch,
            agreementLabel,
            signupButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentTopAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),

            firstWarningLabel.bottomAnchor.constraint(equalTo: firstNameTextView.topAnchor, constant: -1),
            firstWarningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            firstWarningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            firstNameTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            firstNameTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            firstNameTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            lastWarningLabel.bottomAnchor.constraint(equalTo: lastNameTextView.topAnchor, constant: -1),
            lastWarningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            lastWarningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            lastNameTextView.topAnchor.constraint(equalTo: firstNameTextView.bottomAnchor, constant: 25),
            lastNameTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            lastNameTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            usernameWarningLabel.bottomAnchor.constraint(equalTo: usernameHelperLabel.topAnchor, constant: -1),
            usernameWarningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            usernameWarningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            usernameHelperLabel.bottomAnchor.constraint(equalTo: usernameTextView.topAnchor, constant: -1),
            usernameHelperLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            usernameHelperLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            usernameTextView.topAnchor.constraint(equalTo: lastNameTextView.bottomAnchor, constant: 50),
            usernameTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            usernameTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            usernameIndicator.centerYAnchor.constraint(equalTo: usernameTextView.centerYAnchor),
            usernameIndicator.trailingAnchor.constraint(equalTo: usernameTextView.trailingAnchor, constant: -15),
            
            checkmarkImageView.centerYAnchor.constraint(equalTo: usernameTextView.centerYAnchor),
            checkmarkImageView.trailingAnchor.constraint(equalTo: usernameTextView.trailingAnchor, constant: -8),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: Layout.Identity.textViewIconSide),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: Layout.Identity.textViewIconSide),
            
            passwordWarningLabel.bottomAnchor.constraint(equalTo: passwordHelperLabel.topAnchor, constant: -1),
            passwordWarningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            passwordWarningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            passwordHelperLabel.bottomAnchor.constraint(equalTo: passwordTextView.topAnchor, constant: -1),
            passwordHelperLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            passwordHelperLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            passwordTextView.topAnchor.constraint(equalTo: usernameTextView.bottomAnchor, constant: 90),
            passwordTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            passwordTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            confirmWarningLabel.bottomAnchor.constraint(equalTo: confirmTextView.topAnchor, constant: -1),
            confirmWarningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            confirmWarningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            confirmTextView.topAnchor.constraint(equalTo: passwordTextView.bottomAnchor, constant: 30),
            confirmTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            confirmTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),

            eyePasswordImageView.centerYAnchor.constraint(equalTo: passwordTextView.centerYAnchor),
            eyePasswordImageView.trailingAnchor.constraint(equalTo: passwordTextView.trailingAnchor, constant: -15),
            eyePasswordImageView.heightAnchor.constraint(equalToConstant: Layout.Identity.textViewIconSide),
            eyePasswordImageView.widthAnchor.constraint(equalToConstant: Layout.Identity.textViewIconSide),
            
            eyeConfirmImageView.centerYAnchor.constraint(equalTo: confirmTextView.centerYAnchor),
            eyeConfirmImageView.trailingAnchor.constraint(equalTo: confirmTextView.trailingAnchor, constant: -15),
            eyeConfirmImageView.heightAnchor.constraint(equalToConstant: Layout.Identity.textViewIconSide),
            eyeConfirmImageView.widthAnchor.constraint(equalToConstant: Layout.Identity.textViewIconSide),

            logoView.topAnchor.constraint(equalTo: confirmTextView.bottomAnchor, constant: 100),
            logoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoView.heightAnchor.constraint(equalToConstant: Layout.logoViewSize.height),
            logoView.widthAnchor.constraint(equalToConstant: Layout.logoViewSize.width),

            agreementSwitch.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            agreementSwitch.centerYAnchor.constraint(equalTo: agreementLabel.centerYAnchor),
            
            agreementWarningLabel.bottomAnchor.constraint(equalTo: agreementLabel.topAnchor, constant: -5),
            agreementWarningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            agreementWarningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),
            
            agreementLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 100),
            agreementLabel.leadingAnchor.constraint(equalTo: agreementSwitch.trailingAnchor, constant: 15),
            agreementLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),

            signupButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideOutsetStandart),
            signupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideOutsetStandart),
            signupButton.heightAnchor.constraint(equalToConstant: Layout.largeButtonHeight),
            signupButton.topAnchor.constraint(equalTo: agreementLabel.bottomAnchor, constant: 35),
            signupButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])

    }
}

