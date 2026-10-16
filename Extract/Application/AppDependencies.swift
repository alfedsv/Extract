//
//  AppDependencies.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation


nonisolated final class AppDependencies {

    // MARK: - Infrastructure
    let logger: LoggerProtocol
    let keychainStorage: KeychainStorageProtocol
    let sessionStore: SessionStoreProtocol
    let baseClient: APIClientProtocol
    let authorizedClient: APIClientProtocol

    // MARK: - APIs
    let authAPI: AuthAPIProtocol
    let entranceAPI: EntranceAPIProtocol

    // MARK: - Repositories
    let entranceRepository: EntranceRepositoryProtocol   // ← новое
    let userRepository: UserRepositoryProtocol   // ← новое

    // MARK: - Services
    let authService: AuthServiceProtocol

    // MARK: - Factory
    let viewModelFactory: AppViewModelFactory

    init() {
        // Инфраструктура
        let logger: LoggerProtocol = {
            #if DEBUG
            return PrintLogger()
            #else
            return OSLogger()
            #endif
        }()

        let keychainStorage = KeychainStorage()
        let sessionStore = SessionStore(keychain: keychainStorage)

        // Клиенты
        let baseClient = APIClient(
            //baseURL: URL(string: "https://extract.moscow:8080/")!, // на время отключеного сервера
            baseURL: URL(string: "https://alfedsv.lightboxapi.ru/")!,
            sessionStore: sessionStore,
            logger: logger
        )

        let refresher = TokenRefresher(
            client: baseClient,
            sessionStore: sessionStore
        )

        let authorizedClient = AuthorizedAPIClient(
            client: baseClient,
            refresher: refresher
        )

        // Доменные API
        let authAPI = AuthAPI(client: authorizedClient)
        let entranceAPI = EntranceAPI(client: baseClient)

        // Репозитории
        let entranceRepository = EntranceRepository(entranceAPI: entranceAPI)
        let userRepository = UserRepository()

        // Сервисы
        let authService = AuthService(
            entranceAPI: entranceAPI,
            authAPI: authAPI,
            sessionStore: sessionStore,
            userRepository: userRepository,
            logger: logger
        )

        // Фабрика VM
        let viewModelFactory = AppViewModelFactory(
            authService: authService,
            entranceRepository: entranceRepository,
            logger: logger
        )

        // Присваиваем
        self.logger = logger
        self.keychainStorage = keychainStorage
        self.sessionStore = sessionStore
        self.baseClient = baseClient
        self.authorizedClient = authorizedClient
        self.authAPI = authAPI
        self.entranceAPI = entranceAPI
        self.entranceRepository = entranceRepository
        self.userRepository = userRepository
        self.authService = authService
        self.viewModelFactory = viewModelFactory
    }
}
