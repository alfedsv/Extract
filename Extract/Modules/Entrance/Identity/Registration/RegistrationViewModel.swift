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
    var onDataChanged: ((Bool) -> Void)? { get set }
    var onWarning: (([IdentityWarning]) -> Void)? { get set }
    var onRegisterSuccess: (() -> Void)? { get set }
    var onUsernameCheckingOn: (() -> Void)? { get set }
    var onUsernameCheckingOff: ((Bool) -> Void)? { get set }

    // MARK: - Input

    func backTapped()
    func dataChanged(firstName: String, lastName: String, usernameAt: String, password: String, confirm: String, isAgreementAccepted: Bool)
    func signupTapped()
}

final class RegistrationViewModel: BaseViewModel, RegistrationViewModelProtocol {
    
    // MARK: - Output

    var onBack: (() -> Void)?
    var onDataChanged: ((Bool) -> Void)?
    var onWarning: (([IdentityWarning]) -> Void)?
    var onRegisterSuccess: (() -> Void)?
    var onUsernameCheckingOn: (() -> Void)?
    var onUsernameCheckingOff: ((Bool) -> Void)?

    // MARK: - Dependencies

    private let authService: AuthServiceProtocol
    private let entranceRepository: EntranceRepositoryProtocol
    private let logger: LoggerProtocol

    // MARK: - State

    /// Источник истины по данным формы. Ник хранится без префикса `@`.
    private var model = RegistrationModel()

    /// Подтверждён ли текущий ник бэкендом как свободный.
    private var isUsernameAvailable = false

    /// Кэш последнего результата `isSignupAvailable()`.
    private var signupAvailable = false
    
    // MARK: - Username availability check

    /// Идентификатор последней запрошенной проверки ника.
    /// Растёт при каждом изменении ника; асинхронный ответ применяется,
    /// только если его `id` совпадает с текущим — защита от устаревших ответов
    /// при быстром вводе (race condition).
    private var usernameCheckId = 0

    /// Ник, который надо проверить следующим. Храним только последний:
    /// если пользователь печатает быстро, промежуточные проверки не нужны.
    private var pendingUsername: String?

    /// Идёт ли сейчас сетевой запрос. Пока `true`, новый стартовать нельзя,
    /// но `pendingUsername` уже может быть заполнен — он подхватится в
    /// `startNextUsernameCheckIfNeeded` после завершения текущего.
    private var isUsernameCheckInProgress = false

    init(authService: AuthServiceProtocol, entranceRepository: EntranceRepositoryProtocol, logger: LoggerProtocol) {
        self.authService = authService
        self.entranceRepository = entranceRepository
        self.logger = logger
    }

    // MARK: - Input
    
    func dataChanged(firstName: String, lastName: String, usernameAt: String, password: String, confirm: String, isAgreementAccepted: Bool) {
        // `usernameAt` приходит с префиксом `@`, который рисует IdentityTextView.
        // В модель и на бэкенд уходит ник без `@`.
        let username = String(usernameAt.dropFirst())
        if model.username != username {
            isUsernameAvailable = false
            usernameChanged(username: username)
        }
        model.firstName = firstName
        model.lastName = lastName
        model.username = username
        model.password = password
        model.confirm = confirm
        model.isAgreementAccepted = isAgreementAccepted

        signupAvailable = isSignupAvailable()
        onDataChanged?(signupAvailable)
    }

    /// Вызывается при изменении ника. Если новый ник короче минимума —
    /// сбрасываем флаг доступности и уведомляем UI без сетевого запроса.
    /// Иначе ставим ник в очередь на проверку.
    private func usernameChanged(username: String) {
        usernameCheckId += 1

        guard username.count >= Settings.IdentityTextView.usernameClosedRange.lowerBound else {
            pendingUsername = nil
            isUsernameAvailable = false
            onUsernameCheckingOff?(false)
            onDataChanged?(isSignupAvailable())
            return
        }

        pendingUsername = username
        onUsernameCheckingOn?()

        startNextUsernameCheckIfNeeded()
    }

    /// Запускает проверку `pendingUsername`, если она ещё не идёт.
    /// Вызывается и после `usernameChanged`, и по завершении предыдущего
    /// запроса — так выстраивается цепочка «одна проверка за раз».
    private func startNextUsernameCheckIfNeeded() {
        guard !isUsernameCheckInProgress, let username = pendingUsername else {
            return
        }

        pendingUsername = nil
        isUsernameCheckInProgress = true
        let id = usernameCheckId

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                // true  — пользователь с таким ником уже зарегистрирован (занят)
                // false — ник свободен
                let exists = try await self.entranceRepository.isUserExists(username: username)

                self.isUsernameCheckInProgress = false

                if id == self.usernameCheckId {
                    if exists {
                        self.onWarning?([IdentityWarning(warning: .usernameTaken, textViewType: .username)])
                        self.onUsernameCheckingOff?(false)
                        self.isUsernameAvailable = false
                    } else {
                        self.onUsernameCheckingOff?(true)
                        self.isUsernameAvailable = true
                    }
                    self.onDataChanged?(isSignupAvailable())
                }

                self.startNextUsernameCheckIfNeeded()
            } catch let error as APIError {
                self.isUsernameCheckInProgress = false
                self.isUsernameAvailable = false
                
                if id == self.usernameCheckId {
                    self.onUsernameCheckingOff?(false)
                    self.onDataChanged?(isSignupAvailable())
                    self.logger.logAPI(error, endpoint: "isUserExists")
                    self.onError?(error.localizedDescription)
                }

                self.startNextUsernameCheckIfNeeded()
            } catch {
                self.isUsernameCheckInProgress = false
                self.isUsernameAvailable = false
                
                if id == self.usernameCheckId {
                    self.onUsernameCheckingOff?(false)
                    self.onDataChanged?(isSignupAvailable())
                    self.logger.error(error, context: "isUserExists")
                    self.onError?(error.localizedDescription)
                }

                self.startNextUsernameCheckIfNeeded()
            }
        }
    }
    
    /// Сводная проверка готовности формы для UI (цвет кнопки).
    ///
    /// Намеренно проверяет только НИЖНИЕ границы полей: верхние (tooLong)
    /// не учитываются, чтобы не блокировать кнопку при вставке длинного
    /// текста — реальный `validate(...)` прогонится при отправке.
    ///
    /// ВАЖНО: при изменении набора правил синхронизировать с `validate(...)`.
    private func isSignupAvailable() -> Bool {
        return (
            isUsernameAvailable &&
            model.firstName.count >= Settings.IdentityTextView.nameClosedRange.lowerBound &&
            model.lastName.count >= Settings.IdentityTextView.nameClosedRange.lowerBound &&
            model.username.count >= Settings.IdentityTextView.usernameClosedRange.lowerBound &&
            model.password.count >= Settings.IdentityTextView.passwordClosedRange.lowerBound &&
            model.password == model.confirm &&
            model.isAgreementAccepted
        )
    }
    
    /// Кнопка «Зарегистрироваться» тапабельна в обоих состояниях.
    /// - active:   валидация + отправка формы (`signupActiveTapped`)
    /// - inactive: форма не отправляется, но пользователю подсвечиваются
    ///             все незаполненные/невалидные поля (`signupInactiveTapped`).
    ///
    /// Ветвление идёт по `signupAvailable` и пересчитывается прямо здесь.
    func signupTapped() {
        // свежий расчёт — кэш мог устареть (программное изменение свитча, autofill, гонка с проверкой ника)
        signupAvailable = isSignupAvailable()
        signupAvailable ? signupActiveTapped() : signupInactiveTapped()
    }
    
    /// Ветка «active»: `isSignupAvailable` уже гарантирует длины/совпадение/
    /// согласие, но прогоняем `validate` повторно — на случай:
    /// - гонок с autofill/программным изменением полей;
    /// - расширения правил (например, `tooLong`), которые UI-кэш не учитывает.
    private func signupActiveTapped() {
        super.onSetLoading?(true)
        let errors = validate()
        if !errors.isEmpty {
            var messageError = ""
            for validationError in errors {
                logger.crashOnValidation(validationError, in: "\(type(of: self)).\(#function)")
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
    
    /// Ветка «inactive»: собираем варнинги по ВСЕМ полям сразу,
    /// чтобы пользователь видел полный список того, что нужно дозаполнить.
    private func signupInactiveTapped() {
        var warnings: [IdentityWarning] = []
        if model.firstName.isEmpty {
            warnings.append(IdentityWarning(warning: .empty, textViewType: .firstName))
        } else if model.firstName.count < Settings.IdentityTextView.nameClosedRange.lowerBound {
            warnings.append(IdentityWarning(warning: .tooShort(val: Settings.IdentityTextView.nameClosedRange.lowerBound), textViewType: .firstName) )
        }
    
        if model.lastName.isEmpty {
            warnings.append(IdentityWarning(warning: .empty, textViewType: .lastName))
        } else if model.lastName.count < Settings.IdentityTextView.nameClosedRange.lowerBound {
            warnings.append(IdentityWarning(warning: .tooShort(val: Settings.IdentityTextView.nameClosedRange.lowerBound), textViewType: .lastName))
        }
        
        if model.username.isEmpty {
            warnings.append(IdentityWarning(warning: .empty, textViewType: .username))
        } else if model.username.count < Settings.IdentityTextView.usernameClosedRange.lowerBound {
            warnings.append(IdentityWarning(warning: .tooShort(val: Settings.IdentityTextView.usernameClosedRange.lowerBound), textViewType: .username))
        }
        
        if model.password.isEmpty {
            warnings.append(IdentityWarning(warning: .empty, textViewType: .password))
        } else if model.password.count < Settings.IdentityTextView.passwordClosedRange.lowerBound {
            warnings.append(IdentityWarning(warning: .tooShort(val: Settings.IdentityTextView.passwordClosedRange.lowerBound), textViewType: .password))
        } else if model.password != model.confirm {
            warnings.append(IdentityWarning(warning: .confirmNotMatch, textViewType: .confirm))
        }
        
        if model.confirm.isEmpty {
            warnings.append(IdentityWarning(warning: .empty, textViewType: .confirm))
        }
        
        if !model.isAgreementAccepted {
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

    private func validate() -> [ValidationError] {
        var errors: [ValidationError] = []
        if let error = validate(range: Settings.IdentityTextView.nameClosedRange, source: .firstName, text: model.firstName) {
            errors.append(error)
        }
        if let error = validate(range: Settings.IdentityTextView.nameClosedRange, source: .lastName, text: model.lastName) {
            errors.append(error)
        }
        if let error = validate(range: Settings.IdentityTextView.usernameClosedRange, source: .username, text: model.username) {
            errors.append(error)
        }
        if let error = validate(range: Settings.IdentityTextView.passwordClosedRange, source: .password, text: model.password) {
            errors.append(error)
        }
        if let error = validate(range: Settings.IdentityTextView.passwordClosedRange, source: .confirm, text: model.confirm) {
            errors.append(error)
        }
        if model.password != model.confirm {
            errors.append(
                ValidationError(
                    source: .confirm,
                    reason: .mismatch
                )
            )
        }
        if !model.isAgreementAccepted {
            errors.append(
                ValidationError(
                    source: .switchAgreement,
                    reason: .invalidValue(str: String(model.isAgreementAccepted))
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
