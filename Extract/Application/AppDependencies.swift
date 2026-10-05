//
//  AppDependencies.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

final class AppDependencies {

    // MARK: - Infrastructure

    private let logger: LoggerProtocol = {
        #if DEBUG
        return PrintLogger()
        #else
        return OSLogger()
        #endif
    }()

    private let baseURL = URL(string: "https://extract.moscow:8080/")!

    // MARK: - Auth

    lazy var tokenStorage: TokenStorageProtocol = TokenStorage(
        keychain: KeychainStorage()
    )

    private lazy var baseClient: APIClientProtocol = APIClient(
        baseURL: baseURL,
        tokenStorage: tokenStorage,
        logger: logger
    )

    private lazy var refresher: TokenRefresherProtocol = TokenRefresher(
        client: baseClient,
        tokenStorage: tokenStorage
    )

    private lazy var authorizedClient: APIClientProtocol = AuthorizedAPIClient(
        client: baseClient,
        tokenStorage: tokenStorage,
        refresher: refresher
    )

    // MARK: - Domain APIs

    lazy var auth: AuthAPIProtocol = AuthAPI(client: authorizedClient)

    lazy var entrance: EntranceAPIProtocol = EntranceAPI(client: baseClient)


    // MARK: - Services

    lazy var authService: AuthServiceProtocol = AuthService(
        entranceAPI: entrance,
        authAPI: auth,
        tokenStorage: tokenStorage,
        logger: logger
    )

    // MARK: - Factories

    lazy var viewModelFactory: AppViewModelFactory = AppViewModelFactory(
        authService: authService
    )
}
