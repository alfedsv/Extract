//
//  PasswordViewModel.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 06.10.2026.
//

import Foundation

protocol PasswordViewModelProtocol: BaseViewModelProtocol {
    // MARK: - Output
    var onBack: (() -> Void)? { get set }
    var onWarning: ((IdentityWarning?) -> Void)? { get set }

    // MARK: - Input
    func backTapped()
    func setupWarning(warning: IdentityWarning?)
    func loginTapped(password: String)
    
    func isValidLength(text: String) -> Bool
}

final class PasswordViewModel: BaseViewModel, PasswordViewModelProtocol {

    // MARK: - Output

    var onBack: (() -> Void)?
    var onWarning: ((IdentityWarning?) -> Void)?
    var onLoginSuccess: ((User) -> Void)?

    // MARK: - Dependencies
    
    private let authService: AuthServiceProtocol
    private let logger: LoggerProtocol
    
    private let username: String

    init(authService: AuthServiceProtocol, logger: LoggerProtocol, username: String) {
        self.authService = authService
        self.username = username
        self.logger = logger
    }

    // MARK: - Input
    
    func backTapped() {
        onBack?()
    }
    
    func setupWarning(warning: IdentityWarning?) {
        onWarning?(warning)
    }
    
    func loginTapped(password: String) {
        if let validationError = validate(password) {
            logger.crashOnValidation(validationError, in: "\(type(of: self)).\(#function)")
            onError?(validationError.userFacingMessage)
            return
        }
        super.onSetLoading?(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                let user = try await authService.login(username: username, password: password)
                print(user)
                self.onSetLoading?(false)
                self.onLoginSuccess?(user)
            } catch let error as APIError {
                self.onSetLoading?(false)
                logger.logAPI(error, endpoint: "login")
                onError?(error.localizedDescription)
            } catch {
                self.onSetLoading?(false)
                logger.error(error, context: "login")
                onError?(error.localizedDescription)
            }
        }
    }
    
    func isValidLength(text: String) -> Bool {
        Settings.IdentityTextView.passwordClosedRange.contains(text.count)
    }
}
private extension PasswordViewModel {
    func validate(_ password: String) -> ValidationError? {
        let range = Settings.IdentityTextView.passwordClosedRange
        if password.isEmpty {
            return ValidationError(source: .password, reason: .empty)
        }
        if password.count < range.lowerBound {
            return ValidationError(
                source: .password,
                reason: .tooShort(actual: password.count, min: range.lowerBound)
            )
        }
        if password.count > range.upperBound {
            return ValidationError(
                source: .password,
                reason: .tooLong(actual: password.count, max: range.upperBound)
            )
        }
        return nil
    }
}
