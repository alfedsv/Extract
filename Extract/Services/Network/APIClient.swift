//
//  APIClient.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 05.10.2026.
//

import Foundation

nonisolated final class APIClient: APIClientProtocol, Sendable {

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger: LoggerProtocol
    private let tokenStorage: TokenStorageProtocol

    init(
        baseURL: URL,
        tokenStorage: TokenStorageProtocol,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        logger: LoggerProtocol
    ) {
        self.baseURL = baseURL
        self.tokenStorage = tokenStorage
        self.session = session
        self.decoder = decoder
        self.logger = logger
    }

    // MARK: - Public

    func request<T: Decodable & Sendable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        let data = try await perform(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error(error, context: "Decoding \(T.self) for \(endpoint.path)")
            throw APIError.decoding(error)
        }
    }

    func request(_ endpoint: Endpoint) async throws {
        _ = try await perform(endpoint)
    }

    // MARK: - Private

    private func perform(_ endpoint: Endpoint) async throws -> Data {
        let request = try buildRequest(from: endpoint)
        do {
            let (data, response) = try await session.data(for: request)
            try validate(response: response, data: data, path: endpoint.path)
            logger.debug("✅ \(endpoint.path) — OK")
            return data
        } catch let apiError as APIError {
            throw apiError
        } catch {
            logger.error(error, context: "Transport for \(endpoint.path)")
            throw APIError.transport(error)
        }
    }

    private func buildRequest(from endpoint: Endpoint) throws -> URLRequest {
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw APIError.invalidURL(endpoint.path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 15

        if let parameters = endpoint.parameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("\(request.httpBody?.count ?? 0)", forHTTPHeaderField: "Content-Length")
        }

        if let token = token(for: endpoint.authorization) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func token(for type: AuthorizationType) -> String? {
        switch type {
        case .none:    return nil
        case .access:  return tokenStorage.accessToken
        case .refresh: return tokenStorage.refreshToken
        }
    }

    private func validate(response: URLResponse, data: Data, path: String) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch http.statusCode {
        case 200..<300:
            return
        case 401:
            let model = try? decoder.decode(APIErrorModel.self, from: data)
            logger.warning("⚠️ 401 unauthorized at \(path)")
            throw APIError.unauthorized(model)
        default:
            let model = try? decoder.decode(APIErrorModel.self, from: data)
            logger.error("❌ \(http.statusCode) at \(path): \(model?.message ?? "")")
            throw APIError.server(status: http.statusCode, model: model)
        }
    }
}
