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
    
    public func send(emails: [SendGridEmail], on eventLoop: EventLoop) throws -> EventLoopFuture<Void> {
        
        let futures = emails.map { email -> EventLoopFuture<Void> in
            do {
                return try send(email: email, on: eventLoop)
            } catch {
                return eventLoop.makeFailedFuture(error)
            }
        }
        
        return EventLoopFuture<Void>.andAllSucceed(futures, on: eventLoop)
    }
    
    public func send(email: SendGridEmail, on eventLoop: EventLoop) throws -> EventLoopFuture<Void> {
        
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        headers.add(name: "Content-Type", value: "application/json")
 
        let bodyData = try encoder.encode(email)
        
        let bodyString = String(decoding: bodyData, as: UTF8.self)
        
        let request = try HTTPClient.Request(
            url: apiURL,
            method: .POST,
            headers: headers,
            body: .string(bodyString)
        )
        
        return httpClient.execute(
            request: request,
            eventLoop: .delegate(on: eventLoop)
        )
        .flatMap { response in
            switch response.status {
            case .ok, .accepted:
                return eventLoop.makeSucceededFuture(())
            default:
                
                // JSONDecoder will handle empty body by throwing decoding error
                let byteBuffer = response.body ?? ByteBuffer(.init())
                let responseData = Data(byteBuffer.readableBytesView)
                
                do {
                    let error = try self.decoder.decode(SendGridError.self, from: responseData)
                    return eventLoop.makeFailedFuture(error)
                } catch  {
                    return eventLoop.makeFailedFuture(error)
                }
            }
        }
    }
}
