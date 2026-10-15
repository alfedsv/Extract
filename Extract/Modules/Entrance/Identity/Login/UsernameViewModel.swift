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
    func nextTapped(username: String)
    
    func isValidLength(text: String) -> Bool
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

    func nextTapped(username: String) {
        if let validationError = validate(username) {
            logger.crashOnValidation(validationError, in: "UsernameViewModel.nextTapped")
            onError?(validationError.userFacingMessage)
            return
        }
        super.onSetLoading?(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                // на вермя отключеного сервера
                /*let exists = try await entranceRepository.isUserExists(username: String(username.dropFirst()))
                guard exists else {
                    onWarning?(.notUserExists)
                    self.onSetLoading?(false)
                    return
                }*/
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
    
    func isValidLength(text: String) -> Bool {
        Settings.IdentityTextView.usernameClosedRange.contains(text.count)
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
