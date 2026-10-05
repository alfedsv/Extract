//
//  AuthServiceProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

protocol AuthServiceProtocol {
    /// Есть ли валидный refresh-токен.
    /// Access может быть просрочен — его обновит `TokenRefresher` при следующем запросе.
    var isAuthorized: Bool { get }

    /// Логин по логину и паролю.
    func login(username: String, password: String) async throws

    /// Регистрация.
    //func register(_ model: [String: Any]) async throws // TODO: - [String: Any] вместо RegistratonModel пока для сборки

    /// Выход. Отзывает токены на сервере (best effort), затем чистит локально.
    func logout() async
}
