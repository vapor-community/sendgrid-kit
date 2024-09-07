import XCTest
import AsyncHTTPClient
@testable import SendGridKit

class SendGridKitTests: XCTestCase {
    private var httpClient: HTTPClient!
    private var client: SendGridClient!
    
    override func setUp() {
        httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        // TODO: Replace with your API key to test!
        client = SendGridClient(httpClient: httpClient, apiKey: "YOUR-API-KEY")
    }
    
    override func tearDown() async throws {
        try await httpClient.shutdown()
    }
 
    func testSendEmail() async throws {
        // TODO: Replace to address with the email address you'd like to recieve your test email
        let emailAddress = EmailAddress("TO-ADDRESS")
        // TODO: Replace from address with the email address associated with your verified Sender Identity
        let fromEmailAddress = EmailAddress(email: "FROM-ADDRESS", name: "Test")

        let personalization = Personalization(to: [emailAddress], subject: "Test Email")

        let attachment = EmailAttachment(
            content: "Hello, World!".data(using: .utf8)!.base64EncodedString(),
            type: "text/plain",
            filename: "hello.txt",
            disposition: "attachment"
        )

        let emailContent = EmailContent("This email was sent using SendGridKit!")

        let email = SendGridEmail(
            personalizations: [personalization],
            from: fromEmailAddress,
            content: [emailContent],
            attachments: [attachment]
        )
        
        do {
            try await client.send(email: email)
        } catch {}
    }
}
