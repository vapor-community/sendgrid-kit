import Foundation
import NIO
import AsyncHTTPClient
import NIOHTTP1
import NIOFoundationCompat

public struct SendGridClient: Sendable {
    let apiURL: String
    let httpClient: HTTPClient
    let apiKey: String
    
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
    
    public func send(email: SendGridEmail) async throws {
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        headers.add(name: "Content-Type", value: "application/json")

        var request = HTTPClientRequest(url: apiURL)
        request.method = .POST
        request.headers = headers
        request.body = try HTTPClientRequest.Body.bytes(encoder.encode(email))
        
        let response = try await httpClient.execute(request, timeout: .seconds(30))
        
        // If the request was accepted, simply return
        if (200...299).contains(response.status.code) { return }
        
        // JSONDecoder will handle empty body by throwing decoding error                
        throw try await decoder.decode(SendGridError.self, from: response.body.collect(upTo: 1024 * 1024))
    }
}
