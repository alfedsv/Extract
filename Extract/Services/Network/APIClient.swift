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
    private let sessionStore: SessionStoreProtocol

    init(
        baseURL: URL,
        sessionStore: SessionStoreProtocol,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        logger: LoggerProtocol
    ) {
        self.baseURL = baseURL
        self.sessionStore = sessionStore
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
        #if DEBUG
        logRequest(request, endpoint: endpoint)
        #endif
        do {
            let (data, response) = try await session.data(for: request)
            try validate(response: response, data: data, endpoint: endpoint)
            logger.debug("✅ \(endpoint.path) — OK")
            return data
        } catch let apiError as APIError {
            throw apiError
        } catch {
            logger.error(error, context: "Transport for \(endpoint.path)")
            throw APIError.transport(error)
        }
    }

    #if DEBUG
    private func logRequest(_ request: URLRequest, endpoint: Endpoint) {
        var lines: [String] = []
        lines.append("➡️ \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            lines.append("Headers: \(headers)")
        }

        if let body = request.httpBody {
            if let pretty = prettyPrintedJSON(body) {
                lines.append("Body:\n\(pretty)")
            } else if let raw = String(data: body, encoding: .utf8) {
                lines.append("Body (raw): \(raw)")
            } else {
                lines.append("Body: \(body.count) bytes (не текстовый)")
            }
        } else {
            lines.append("Body: <empty>")
        }

        logger.debug(lines.joined(separator: "\n"))
    }

    private func prettyPrintedJSON(_ data: Data) -> String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let prettyData = try? JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted, .sortedKeys]
            ),
            let string = String(data: prettyData, encoding: .utf8)
        else {
            return nil
        }
        return string
    }
    #endif

    private func buildRequest(from endpoint: Endpoint) throws -> URLRequest {
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw APIError.invalidURL(endpoint.path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 15

        if let body = endpoint.body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("\(request.httpBody?.count ?? 0)", forHTTPHeaderField: "Content-Length")
        }

        if let token = token(for: endpoint.authorization) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func token(for type: AuthorizationType) -> String? {
        guard let session = sessionStore.current else { return nil }
        switch type {
        case .none:    return nil
        case .access:  return session.accessToken
        case .refresh: return session.refreshToken
        }
    }

    private func validate(response: URLResponse, data: Data, endpoint: Endpoint) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        let status = http.statusCode

        if (200..<300).contains(status) {
            return
        }

        // Особый случай: 401 разрешён для этого эндпоинта (при логине)
        if status == 401, endpoint.treats401AsSuccess {
            return
        }

        let model = try? decoder.decode(APIErrorModel.self, from: data)
        if status == 401 {
            logger.warning("⚠️ 401 unauthorized at \(endpoint.path)")
            throw APIError.unauthorized(model)
        }
        logger.error("❌ \(status) at \(endpoint.path): \(model?.message ?? "")")
        throw APIError.server(status: status, model: model)
    }

}
