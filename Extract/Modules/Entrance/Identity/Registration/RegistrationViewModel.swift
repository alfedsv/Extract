//
//  RegistrationViewModel.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation


protocol RegistrationViewModelProtocol: BaseViewModelProtocol {
    
    // MARK: - Output
    var onBack: (() -> Void)? { get set }
    var onWarning: (([IdentityWarning]) -> Void)? { get set }
    var onRegisterSuccess: (() -> Void)? { get set }
    var onUsernameChecking: ((Bool) -> Void)? { get set }
    var onUsernameChecked: ((Bool) -> Void)? { get set }

    // MARK: - Input

    func backTapped()
    func usernameChanged(username: String)
    func signupTapped(isActive: Bool, firstName: String, lastName: String, username: String, password: String, confirm: String, isAgreementAccepted: Bool)
}

final class RegistrationViewModel: BaseViewModel, RegistrationViewModelProtocol {
    
    // MARK: - Output
    var onBack: (() -> Void)?
    var onWarning: (([IdentityWarning]) -> Void)?
    var onRegisterSuccess: (() -> Void)?
    var onUsernameChecking: ((Bool) -> Void)?
    var onUsernameChecked: ((Bool) -> Void)?

    // MARK: - Dependencies

    private let authService: AuthServiceProtocol
    private let entranceRepository: EntranceRepositoryProtocol
    private let logger: LoggerProtocol
    
    private var isUsernameCheckInProgress = false
    private var pendingUsername: String?
    private var usernameCheckId = 0

    init(authService: AuthServiceProtocol, entranceRepository: EntranceRepositoryProtocol, logger: LoggerProtocol) {
        self.authService = authService
        self.entranceRepository = entranceRepository
        self.logger = logger
    }

    // MARK: - Input

    func usernameChanged(username: String) {
        usernameCheckId += 1

        guard username.count > Settings.IdentityTextView.usernameClosedRange.lowerBound else {
            pendingUsername = nil
            resetUsernameCheckUI()
            return
        }

        pendingUsername = username
        onUsernameChecking?(true)

        startNextUsernameCheckIfNeeded()
    }

    private func startNextUsernameCheckIfNeeded() {
        guard !isUsernameCheckInProgress, let username = pendingUsername else {
            return
        }

        pendingUsername = nil
        isUsernameCheckInProgress = true
        let id = usernameCheckId

        Task { [weak self] in
            guard let self else { return }

            do {
                let exists = try await self.entranceRepository.isUserExists(username: String(username.dropFirst()))

                self.isUsernameCheckInProgress = false

                if id == self.usernameCheckId {
                    if exists {
                        self.onUsernameChecking?(false)
                        self.onUsernameChecked?(true)
                    } else {
                        self.onWarning?([IdentityWarning(warning: .usernameTaken, textViewType: .username)])
                        self.resetUsernameCheckUI()
                    }
                }

                self.startNextUsernameCheckIfNeeded()
            } catch let error as APIError {
                self.isUsernameCheckInProgress = false

                if id == self.usernameCheckId {
                    self.resetUsernameCheckUI()
                    self.logger.logAPI(error, endpoint: "isUserExists")
                    self.onError?(error.localizedDescription)
                }

                self.startNextUsernameCheckIfNeeded()
            } catch {
                self.isUsernameCheckInProgress = false

                if id == self.usernameCheckId {
                    self.resetUsernameCheckUI()
                    self.logger.error(error, context: "isUserExists")
                    self.onError?(error.localizedDescription)
                }

                self.startNextUsernameCheckIfNeeded()
            }
        }
    }
    
    private func resetUsernameCheckUI() {
        onUsernameChecking?(false)
        onUsernameChecked?(false)
    }
    
    func signupTapped(
        isActive: Bool,
        firstName: String,
        lastName: String,
        username: String,
        password: String,
        confirm: String,
        isAgreementAccepted: Bool
    ) {
        if isActive {
            signupActiveTapped(
                firstName: firstName,
                lastName: lastName,
                username: username,
                password: password,
                confirm: confirm,
                isAgreementAccepted: isAgreementAccepted
            )
        } else {
            signupInactiveTapped(
                firstName: firstName,
                lastName: lastName,
                username: username,
                password: password,
                confirm: confirm,
                isAgreementAccepted: isAgreementAccepted
            )
        }
    }
    
    private func signupActiveTapped(firstName: String, lastName: String, username: String, password: String, confirm: String, isAgreementAccepted: Bool) {
        super.onSetLoading?(true)
        let errors = validate(firstName: firstName, lastName: lastName,username: username,password: password, confirm: confirm, isAgreementAccepted: isAgreementAccepted)
        if !errors.isEmpty {
            var messageError = ""
            for validationError in errors {
                logger.crashOnValidation(validationError, in: "RegistrationViewModel.signupActiveTapped")
                messageError += validationError.userFacingMessage + "\n"
            }
            self.onSetLoading?(false)
            onError?(messageError)
            return
        }
        
        Task { @MainActor in
            /*defer { self.onLoading?(false) }
            do {
                try await authService.register(username: username, password: password)
                onRegisterSuccess?()
            } catch {
                onError?(error.localizedDescription)
            }*/
            self.onSetLoading?(false)
        }
    }
    
    func signupInactiveTapped(firstName: String, lastName: String, username: String, password: String, confirm: String, isAgreementAccepted: Bool) {
        var warnings: [IdentityWarning] = []
        if firstName.isEmpty {
            warnings.append(IdentityWarning(warning: .empty, textViewType: .firstName))
        } else if firstName.count < Settings.IdentityTextView.nameClosedRange.lowerBound {
            warnings.append(IdentityWarning(warning: .tooShort(val: Settings.IdentityTextView.nameClosedRange.lowerBound), textViewType: .firstName) )
        }
    
        if lastName.isEmpty {
            warnings.append(IdentityWarning(warning: .empty, textViewType: .lastName))
        } else if lastName.count < Settings.IdentityTextView.nameClosedRange.lowerBound {
            warnings.append(IdentityWarning(warning: .tooShort(val: Settings.IdentityTextView.nameClosedRange.lowerBound), textViewType: .lastName))
        }
        
        if username.isEmpty {
            warnings.append(IdentityWarning(warning: .empty, textViewType: .username))
        } else if username.count < Settings.IdentityTextView.usernameClosedRange.lowerBound {
            warnings.append(IdentityWarning(warning: .tooShort(val: Settings.IdentityTextView.usernameClosedRange.lowerBound), textViewType: .username))
        }
        
        if password.isEmpty {
            warnings.append(IdentityWarning(warning: .empty, textViewType: .password))
        } else if password.count < Settings.IdentityTextView.passwordClosedRange.lowerBound {
            warnings.append(IdentityWarning(warning: .tooShort(val: Settings.IdentityTextView.passwordClosedRange.lowerBound), textViewType: .password))
        } else if password != confirm {
            warnings.append(IdentityWarning(warning: .confirmNotMatch, textViewType: .confirm))
        }
        
        if confirm.isEmpty {
            warnings.append(IdentityWarning(warning: .empty, textViewType: .confirm))
        }
        
        if !isAgreementAccepted {
            warnings.append(IdentityWarning(warning: .agreementNotSigned, textViewType: nil))
        }
        
        onWarning?(warnings)
    }

    /// Пользователь нажал «назад».
    func backTapped() {
        onBack?()
    }
    
    
    // тут прикручу согласие
    /*var userTheme: UserTheme? {
        get {
            guard let saved = UserDefaults.standard.string(forKey: themeKey), let t = UserTheme(rawValue: saved) else { return nil }
            return t
        }
        set {
            guard let newValue = newValue else {
                // Сброс ручного выбора — снова следуем за системой.
                UserDefaults.standard.removeObject(forKey: themeKey)
                applyTheme()
                return
            }
            theme = Theme(rawValue: newValue.rawValue) ?? .system
        }
    }*/

    // MARK: - Validation

    private func validate(
        firstName: String,
        lastName: String,
        username: String,
        password: String,
        confirm: String,
        isAgreementAccepted: Bool
    ) -> [ValidationError] {
        var errors: [ValidationError] = []
        if let error = validate(range: Settings.IdentityTextView.nameClosedRange, source: .firstName, text: firstName) {
            errors.append(error)
        }
        if let error = validate(range: Settings.IdentityTextView.nameClosedRange, source: .lastName, text: lastName) {
            errors.append(error)
        }
        if let error = validate(range: Settings.IdentityTextView.usernameClosedRange, source: .username, text: username) {
            errors.append(error)
        }
        if let error = validate(range: Settings.IdentityTextView.passwordClosedRange, source: .password, text: password) {
            errors.append(error)
        }
        if let error = validate(range: Settings.IdentityTextView.passwordClosedRange, source: .confirm, text: confirm) {
            errors.append(error)
        }
        if password != confirm {
            errors.append(
                ValidationError(
                    source: .confirm,
                    reason: .mismatch
                )
            )
        }
        if !isAgreementAccepted {
            errors.append(
                ValidationError(
                    source: .switchAgreement,
                    reason: .invalidValue(str: String(isAgreementAccepted))
                )
            )
        }
        return errors
    }
    
    private func validate(range: ClosedRange<Int>, source: ValidationError.Source, text: String) -> ValidationError? {
        if text.isEmpty {
            return ValidationError(source: source, reason: .empty)
        }
        if text.count < range.lowerBound {
            return ValidationError(
                source: source,
                reason: .tooShort(actual: text.count, min: range.lowerBound)
            )
        }
        if text.count > range.upperBound {
            return ValidationError(
                source: source,
                reason: .tooLong(actual: text.count, max: range.upperBound)
            )
        }
        return nil
    }
}
