//
//  AuthService.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

import Foundation

final class AuthService: AuthServiceProtocol {

    private let entranceAPI: EntranceAPIProtocol
    private let authAPI: AuthAPIProtocol
    private let tokenStorage: TokenStorageProtocol
    private let logger: LoggerProtocol

    init(
        entranceAPI: EntranceAPIProtocol,
        authAPI: AuthAPIProtocol,
        tokenStorage: TokenStorageProtocol,
        logger: LoggerProtocol
    ) {
        self.entranceAPI = entranceAPI
        self.authAPI = authAPI
        self.tokenStorage = tokenStorage
        self.logger = logger
    }

    // MARK: - AuthServiceProtocol

    var isAuthorized: Bool {
        guard let refresh = tokenStorage.refreshToken, !refresh.isEmpty else {
            return false
        }
        return !tokenStorage.isRefreshTokenExpired()
    }

    func login(username: String, password: String) async throws {
        do {
            let response = try await entranceAPI.loginByName(
                username: username,
                password: password
            )
            applyLogin(response)
        } catch let error as APIError {
            throw mapToAuthError(error)
        }
    }

    

    /*func register(_ model: [String: Any]) async throws { // TODO: - [String: Any] вместо RegistratonModel пока для сборки
        do {
            let response: EntranceDTO.UserRegistrate
            response = try await entranceAPI.register(
                parameters: model
            )
            //tokenStorage.accessToken = response.accessToken
            //tokenStorage.refreshToken = response.refreshToken
            //saveCurrentUserId(response.userId)
        } catch let error as APIError {
            throw mapToAuthError(error)
        }
    }*/

    func logout() async {
        let userId = currentUserId()
        if userId > 0 {
            do {
                try await authAPI.revokeTokens(userId: userId)
            } catch {
                logger.warning("Revoke failed on logout: \(error.localizedDescription)")
            }
        }
        tokenStorage.clear()
        clearCurrentUserId()
    }

    // MARK: - Private

    private func applyLogin(_ response: EntranceDTO.LoginAuth) {
        tokenStorage.accessToken = response.accessToken
        tokenStorage.refreshToken = response.refreshToken
        //saveCurrentUserId(response.userId)
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

    // MARK: - Current user id

    // TODO: вынести в SessionStore, когда появится.
    // Сейчас — минимальный вариант, чтобы работал revoke.

    private static let userIdKey = "CurrentUserId"

    private func currentUserId() -> Int {
        UserDefaults.standard.integer(forKey: Self.userIdKey)
    }

    private func saveCurrentUserId(_ id: Int) {
        UserDefaults.standard.set(id, forKey: Self.userIdKey)
    }

    private func clearCurrentUserId() {
        UserDefaults.standard.removeObject(forKey: Self.userIdKey)
    }
}
