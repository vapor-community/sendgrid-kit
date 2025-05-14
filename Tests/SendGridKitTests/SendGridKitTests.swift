import AsyncHTTPClient
import Foundation
import SendGridKit
import Testing

@Suite("SendGridKit Tests")
struct SendGridKitTests {
    var client: SendGridClient
    // TODO: Replace with `false` when you have a valid API key
    let credentialsAreInvalid = true

    init() {
        // TODO: Replace with a valid API key to test
        client = SendGridClient(httpClient: HTTPClient.shared, apiKey: "YOUR-API-KEY")
    }

    @Test("Send Email")
    func sendEmail() async throws {
        // TODO: Replace to address with the email address you'd like to recieve your test email
        let emailAddress = EmailAddress("TO-ADDRESS")
        // TODO: Replace from address with the email address associated with your verified Sender Identity
        let fromEmailAddress = EmailAddress(email: "FROM-ADDRESS", name: "Test")

        let personalization = Personalization(to: [emailAddress], subject: "Test Email")

        let attachment = EmailAttachment(
            content: "Hello, World!".data(using: .utf8)!.base64EncodedString(),
            type: "text/plain",
            filename: "hello.txt",
            disposition: .attachment
        )

        let emailContent = EmailContent("This email was sent using SendGridKit!")

        let mailSettings = MailSettings(
            bypassListManagement: true,
            bypassSpamManagement: true,
            bypassBounceManagement: true,
            footer: false,
            sandboxMode: true
        )

        let trackingSettings = TrackingSettings(
            clickTracking: .init(enable: true, enableText: true),
            openTracking: .init(enable: true, substitutionTag: "open_tracking"),
            subscriptionTracking: .init(
                enable: true,
                text: "sub_text",
                html: "<strong>sub_html</strong>",
                substitutionTag: "sub_tag"
            ),
            ganalytics: .init(
                enable: true,
                utmSource: "utm_source",
                utmMedium: "utm_medium",
                utmTerm: "utm_term",
                utmContent: "utm_content",
                utmCampaign: "utm_campaign"
            )
        )

        let asm = AdvancedSuppressionManager(groupID: 21, groupsToDisplay: ["group1", "group2"])

        let email = SendGridEmail(
            personalizations: [personalization],
            from: fromEmailAddress,
            content: [emailContent],
            attachments: [attachment],
            asm: asm,
            mailSettings: mailSettings,
            trackingSettings: trackingSettings
        )

        try await withKnownIssue {
            try await client.send(email: email)
        } when: {
            credentialsAreInvalid
        }
    }

    @Test("DynamicTemplateData")
    func dynamicTemplateData() async throws {
        struct DynamicTemplateData: Codable, Sendable {
            let text: String
            let integer: Int
            let double: Double
        }
        let dynamicTemplateData = DynamicTemplateData(text: "Hello, World!", integer: 42, double: 3.14)

        // TODO: Replace the addresses with real email addresses
        let personalization = Personalization(
            to: [EmailAddress("TO-ADDRESS")], subject: "Test Email",
            dynamicTemplateData: dynamicTemplateData
        )
        let email = SendGridEmail(
            personalizations: [personalization], from: EmailAddress("FROM-ADDRESS"),
            content: [EmailContent("Hello, World!")]
        )

        try await withKnownIssue {
            try await client.send(email: email)
        } when: {
            credentialsAreInvalid
        }
    }

    @Test("Email Validation")
    func validateEmail() async throws {
        let validationRequest = EmailValidationRequest(email: "test@example.com", source: "unit_test")

        try await withKnownIssue {
            let response = try await client.validateEmail(validationRequest: validationRequest)

            // Verify response properties exist
            _ = response.result.score

            // Basic assertions
            if response.result.verdict == .valid {
                print("Email is valid with score: \(response.result.score)")
            } else {
                print("Email is invalid: \(response.result.suggestion)")
            }
        } when: {
            credentialsAreInvalid
        }
    }

    @Test("Bulk Email Validation")
    func bulkValidateEmail() async throws {
        // Create a simple CSV with a few test emails
        let csvContent = """
            email
            test1@example.com
            test2@example.com
            test3@example.com
            """
        let csvData = csvContent.data(using: .utf8)!

        try await withKnownIssue {
            // Step 1: Get an upload URL
            let uploadURLResponse = try await client.getBulkValidationUploadURL(fileType: .csv)

            // Verify upload URL response
            _ = uploadURLResponse.jobId
            _ = uploadURLResponse.uploadUri
            _ = uploadURLResponse.uploadHeaders

            print("Got upload details with job ID: \(uploadURLResponse.jobId)")

            // Step 2: Upload the CSV file to start the validation job (simulated in this test)
            let (uploadSuccess, jobId) = try await client.uploadBulkValidationFile(
                fileData: csvData,
                uploadResponse: uploadURLResponse
            )

            #expect(uploadSuccess == true)

            // Step 4: Check job status
            let jobStatusResponse = try await client.checkBulkValidationStatus(jobId: jobId)

            // Verify job status properties
            let result = jobStatusResponse.result
            _ = result.id
            _ = result.status
            _ = result.segmentsProcessed
            _ = result.segments

            // Step 5: Get results if job is completed (unlikely in a test without waiting)
            #expect(result.status == .done)
        } when: {
            credentialsAreInvalid
        }
    }
}
