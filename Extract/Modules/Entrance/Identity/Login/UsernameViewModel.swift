//
//  UsernameViewModel.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 06.10.2026.
//

import Foundation

protocol UsernameViewModelProtocol: BaseViewModelProtocol {
    // MARK: - Output
    var onBack: (() -> Void)? { get set }
    var onWarning: ((IdentityWarning?) -> Void)? { get set }

    // MARK: - Input
    func backTapped()
    func setupWarning(warning: IdentityWarning?)
    func nextTapped(usernameAt: String)
    
    func isValidLength(usernameAt: String) -> Bool
}

final class UsernameViewModel: BaseViewModel, UsernameViewModelProtocol {

    // MARK: - Output

    var onBack: (() -> Void)?
    var onWarning: ((IdentityWarning?) -> Void)?
    var onNext: ((String) -> Void)?

    // MARK: - Dependencies
    
    private let entranceRepository: EntranceRepositoryProtocol
    private let logger: LoggerProtocol

    init(entranceRepository: EntranceRepositoryProtocol, logger: LoggerProtocol) {
        self.entranceRepository = entranceRepository
        self.logger = logger
    }

    // MARK: - Input
    
    func backTapped() {
        onBack?()
    }
    
    func setupWarning(warning: IdentityWarning?) {
        onWarning?(warning)
    }

    func nextTapped(usernameAt: String) {
        let username = String(usernameAt.dropFirst())
        if let validationError = validate(username) {
            logger.crashOnValidation(validationError, in: "\(type(of: self)).\(#function)")
            onError?(validationError.userFacingMessage)
            return
        }
        super.onSetLoading?(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                let exists = try await entranceRepository.isUserExists(username: String(username.dropFirst()))
                guard exists else {
                    onWarning?(IdentityWarning(warning: .notUserExists, textViewType: .username))
                    self.onSetLoading?(false)
                    return
                }
                self.onSetLoading?(false)
                self.onNext?(String(username.dropFirst()))
            } catch let error as APIError {
                self.onSetLoading?(false)
                logger.logAPI(error, endpoint: "isUserExists")
                onError?(error.localizedDescription)
            } catch {
                self.onSetLoading?(false)
                logger.error(error, context: "isUserExists")
                onError?(error.localizedDescription)
            }
        }
            
    }
    
    func isValidLength(usernameAt: String) -> Bool {
        let username = String(usernameAt.dropFirst())
        return Settings.IdentityTextView.usernameClosedRange.contains(username.count)
    }

}
private extension UsernameViewModel {
    func validate(_ username: String) -> ValidationError? {
        let range = Settings.IdentityTextView.usernameClosedRange
        if username.isEmpty {
            return ValidationError(source: .username, reason: .empty)
        }
        if username.count < range.lowerBound {
            return ValidationError(
                source: .username,
                reason: .tooShort(actual: username.count, min: range.lowerBound)
            )
        }
        if username.count > range.upperBound {
            return ValidationError(
                source: .username,
                reason: .tooLong(actual: username.count, max: range.upperBound)
            )
        }
        return nil
    }
}
