import Foundation
import NIO
import AsyncHTTPClient
import NIOHTTP1

public struct SendGridClient {
    let apiURL = "https://api.sendgrid.com/v3/mail/send"
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

    public init(httpClient: HTTPClient, apiKey: String) {
        self.httpClient = httpClient
        self.apiKey = apiKey
    }
    
    public func send(email: SendGridEmail) async throws {
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        headers.add(name: "Content-Type", value: "application/json")
        
        let response = try await httpClient.execute(
            request: .init(
                url: apiURL,
                method: .POST,
                headers: headers,
                body: .data(encoder.encode(email))
            )
        ).get()
        
        // If the request was accepted, simply return
        guard response.status != .ok && response.status != .accepted else { return }
        
        // JSONDecoder will handle empty body by throwing decoding error
        let byteBuffer = response.body ?? ByteBuffer(.init())
                
        throw try decoder.decode(SendGridError.self, from: byteBuffer)
    }
}
