import XCTest
import AsyncHTTPClient

@testable import SendGridKit

class SendGridKitTests: XCTestCase {

    
    private var httpClient: HTTPClient!
    private var client: SendGridClient!
    
    override func setUp() {
        httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        
        // TODO: Replace with your API key to test!
        client = SendGridClient(httpClient: httpClient, apiKey: "YOUR-API-KEY")
    }
    
    override func tearDown() async throws {
        try await httpClient.shutdown()
    }
 
    func test_sendEmail() async throws {
        
        // TODO: Replace to address with the email address you'd like to recieve your test email!
        let personalization = Personalization(to: ["TO-ADDRESS"])

        // TODO: Replace from address with the email address associated with your verified Sender Identity!
        let email = SendGridEmail(
            personalizations: [personalization],
            from: "FROM-ADDRESS",
            subject: "Test Email",
            content: ["This email was sent using SendGridKit!"]
        )
        
        try await client.send(email: email)
        
    }
}
