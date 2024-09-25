import AsyncHTTPClient
import SendGridKit
import Testing

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
            disposition: .attachment
        )

        let emailContent = EmailContent("This email was sent using SendGridKit!")

        let setting = Setting(enable: true)
        let mailSettings = MailSettings(
            bypassListManagement: setting,
            bypassSpamManagement: setting,
            bypassBounceManagement: setting,
            footer: Footer(enable: true, text: "footer", html: "<strong>footer</strong>"),
            sandboxMode: setting
        )

        let trackingSettings = TrackingSettings(
            clickTracking: ClickTracking(enable: true, enableText: true),
            openTracking: OpenTracking(enable: true, substitutionTag: "open_tracking"),
            subscriptionTracking: SubscriptionTracking(
                enable: true,
                text: "sub_text",
                html: "<strong>sub_html</strong>",
                substitutionTag: "sub_tag"
            ),
            ganalytics: GoogleAnalytics(
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
            // TODO: Replace with `false` when you have a valid API key
            true
        }
    }

    @Test func dynamicTemplateData() async throws {
        struct DynamicTemplateData: Codable, Sendable {
            let text: String
            let integer: Int
            let double: Double
        }
        let dynamicTemplateData = DynamicTemplateData(
            text: "Hello, World!", integer: 42, double: 3.14)

        // TODO: Replace the addresses with real email addresses
        let personalization = Personalization(
            to: [EmailAddress("TO-ADDRESS")], subject: "Test Email",
            dynamicTemplateData: dynamicTemplateData)
        let email = SendGridEmail(
            personalizations: [personalization], from: EmailAddress("FROM-ADDRESS"),
            content: [EmailContent("Hello, World!")])

        try await withKnownIssue {
            try await client.send(email: email)
        } when: {
            // TODO: Replace with `false` when you have a valid API key
            true
        }
    }
}
