import AsyncHTTPClient
import Foundation
import NIO
import NIOFoundationCompat
import NIOHTTP1

/// A client for sending emails using the SendGrid API.
public struct SendGridClient: Sendable {
    private let apiURL: String
    private let httpClient: HTTPClient
    private let apiKey: String

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()

    /// Initialize a new `SendGridClient`
    ///
    /// - Parameters:
    ///   - httpClient: The `HTTPClient` to use for sending requests
    ///   - apiKey: The SendGrid API key
    ///   - forEU: Whether to use the API endpoint for global users and subusers or for EU regional subusers
    public init(httpClient: HTTPClient, apiKey: String, forEU: Bool = false) {
        self.httpClient = httpClient
        self.apiKey = apiKey
        self.apiURL = forEU ? "https://api.eu.sendgrid.com/v3/mail/send" : "https://api.sendgrid.com/v3/mail/send"
    }

    /// Send an email using the SendGrid API.
    ///
    /// - Parameter email: The ``SendGridEmail`` to send.
    public func send<DynamicTemplateData: Codable & Sendable>(email: SendGridEmail<DynamicTemplateData>) async throws {
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(self.apiKey)")
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "User-Agent", value: "Swift SendGridKit/3.0.0")

        var request = HTTPClientRequest(url: self.apiURL)
        request.method = .POST
        request.headers = headers
        request.body = try HTTPClientRequest.Body.bytes(self.encoder.encode(email))

        let response = try await self.httpClient.execute(request, timeout: .seconds(30))

        // If the request was accepted, simply return
        if (200...299).contains(response.status.code) { return }

        // `JSONDecoder` will handle empty body by throwing decoding error
        throw try await self.decoder.decode(SendGridError.self, from: response.body.collect(upTo: 1024 * 1024))
    }
}
