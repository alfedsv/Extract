//
//  AuthService.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated final class AuthService: AuthServiceProtocol {

    private let entranceAPI: EntranceAPIProtocol
    private let authAPI: AuthAPIProtocol
    private let sessionStore: SessionStoreProtocol
    private let userRepository: UserRepositoryProtocol
    private let logger: LoggerProtocol

    init(
        entranceAPI: EntranceAPIProtocol,
        authAPI: AuthAPIProtocol,
        sessionStore: SessionStoreProtocol,
        userRepository: UserRepositoryProtocol,
        logger: LoggerProtocol
    ) {
        self.entranceAPI = entranceAPI
        self.authAPI = authAPI
        self.sessionStore = sessionStore
        self.userRepository = userRepository
        self.logger = logger
    }

    var isAuthorized: Bool {
        sessionStore.isAuthorized
    }

    func login(username: String, password: String) async throws -> User {
        do {
            let result = try await entranceAPI.login(
                username: username,
                password: password
            )

            switch result {
            case .authorized(let auth):
                // Сохраняем сессию
                try await saveSession(from: auth)

                // Мапим DTO → Domain
                let user = UserMapper.toDomain(auth)

                // Кэшируем профиль
                userRepository.cacheCurrentUser(user)

                // 4. Возвращаем VM
                return user

            case .unauthorized(let unauth):
                throw AuthError.wrongPassword(attemptsLeft: unauth.attempts)
            }
        } catch let error as APIError {
            throw mapToAuthError(error)
        }
    }

    func logout() async {
        let userId = sessionStore.current?.userId ?? 0
        if userId > 0 {
            do {
                try await authAPI.revokeTokens(userId: userId)
            } catch {
                logger.warning("Revoke failed on logout: \(error.localizedDescription)")
            }
        }
        sessionStore.clear()
        userRepository.clearCache()
    }

    // MARK: - Private

    private func saveSession(from auth: EntranceDTO.LoginAuth) async throws {
        let now = Date()

        let temporarySession = Session(
            userId: 0,
            accessToken: auth.accessToken,
            refreshToken: auth.refreshToken,
            accessTokenBornAt: now,
            refreshTokenBornAt: now
        )
        try sessionStore.save(temporarySession)

        let userId: Int
        do {
            let response = try await entranceAPI.getUserId()
            userId = response.userId
        } catch {
            sessionStore.clear()
            logger.error(error, context: "getUserId after login")
            throw AuthError.server(message: "Не удалось завершить вход")
        }

        let finalSession = Session(
            userId: userId,
            accessToken: auth.accessToken,
            refreshToken: auth.refreshToken,
            accessTokenBornAt: now,
            refreshTokenBornAt: now
        )
        try sessionStore.save(finalSession)
    }

    private func mapToAuthError(_ error: APIError) -> Error {
        switch error {
        case .unauthorized:
            return AuthError.invalidCredentials
        case .server(_, let model):
            return AuthError.server(message: model?.message ?? "Ошибка сервера")
        default:
            return error
        }
    }
}
