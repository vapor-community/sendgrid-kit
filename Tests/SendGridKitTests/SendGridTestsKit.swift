import Testing
import AsyncHTTPClient
@testable import SendGridKit

struct SendGridKitTests {
    var client: SendGridClient
    
    init() {
        // TODO: Replace with a valid API key to test
        client = SendGridClient(httpClient: HTTPClient.shared, apiKey: "YOUR-API-KEY")
    }
 
    @Test func sendEmail() async throws {
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
        
        await withKnownIssue {
            try await client.send(email: email)
        }
    }
}
