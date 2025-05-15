import AsyncHTTPClient
import Foundation
import SendGridKit
import Testing

@Suite("SendGridKit Tests")
struct SendGridKitTests {
    var client: SendGridClient
    // TODO: Replace with `false` when you have a valid API key
    let credentialsAreInvalid = true

    let emailValidationClient: SendGridClient

    init() {
        // TODO: Replace with a valid API key to test
        client = SendGridClient(httpClient: HTTPClient.shared, apiKey: "YOUR-API-KEY")
        emailValidationClient = SendGridClient(
            httpClient: HTTPClient.shared, apiKey: "YOUR-API-KEY", emailValidationAPIKey: "YOUR-EMAIL-VALIDATION-API-KEY")
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
            let response = try await emailValidationClient.validateEmail(validationRequest: validationRequest)

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

    @Test("Request Upload URL for CSV")
    func requestUploadURL() async throws {
        try await withKnownIssue {
            let response = try await emailValidationClient.getBulkValidationUploadURL(fileType: .csv)
            #expect(response.uploadUri != "")
            #expect(response.jobId != "")
        } when: {
            credentialsAreInvalid
        }
    }

    @Test("Request Upload URL for Zip")
    func requestUploadURLForZipArchive() async throws {
        try await withKnownIssue {
            let response = try await emailValidationClient.getBulkValidationUploadURL(fileType: .zip)
            #expect(response.uploadUri != "")
            #expect(response.jobId != "")
        } when: {
            credentialsAreInvalid
        }
    }

    @Test("Get Bulk validation jobs")
    func getBulkValidationJobs() async throws {
        try await withKnownIssue {
            let response = try await emailValidationClient.getBulkEmailValidationJobs()
            #expect(response.result.count > 0)
        } when: {
            credentialsAreInvalid
        }
    }

    @Test("Get Bulk validation job status")
    func getBulkValidationJobStatus() async throws {
        try await withKnownIssue {
            let jobsResponse = try await emailValidationClient.checkBulkValidationStatus(jobId: "12345")
            let errors = jobsResponse.response.value.result.errors
            #expect(errors?.count == 0)
        } when: {
            credentialsAreInvalid
        }
    }

    @Test("Get Bulk validation job status should throw when email validation API key is missing")
    func getBulkValidationJobStatusShouldThrow() async throws {
        let error = await #expect(throws: SendGridError.self) {
            try await client.checkBulkValidationStatus(jobId: "12345")
        }

        #expect(error?.id?.isEmpty == false)
    }

    @Test("Get Bulk validation jobs should throw when email validation API key is missing")
    func getBulkValidationJobsShouldThrow() async throws {
        let error = await #expect(throws: SendGridError.self) {
            try await client.getBulkEmailValidationJobs()
        }

        #expect(error?.id?.isEmpty == false)
    }

    @Test("Validate email should throw when email validation API key is missing")
    func validateEmailShouldThrow() async throws {
        let error = await #expect(throws: SendGridError.self) {
            try await client.validateEmail(validationRequest: .init(email: "some@email.com"))
        }

        #expect(error?.id?.isEmpty == false)
    }

    @Test("Upload CSV File")
    func uploadCSVFile() async throws {
        let csvContent = """
            email
            test1@example.com
            test2@example.com
            test3@example.com
            """
        let csvData = csvContent.data(using: .utf8)!

        let response = """
            {
              "job_id": "01H793APATD899ESMY25ZNPNCF",
              "upload_uri": "https://example.com/",
              "upload_headers": [
                {
                  "header": "x-amz-server-side-encryption",
                  "value": "aws:kms"
                },
                {
                  "header": "content-type",
                  "value": "text/csv"
                }
              ]
            }
            """

        let responseData = try JSONDecoder().decode(BulkValidationUploadURLResponse.self, from: response.data(using: .utf8)!)

        try await withKnownIssue {
            let response = try await emailValidationClient.uploadBulkValidationFile(
                fileData: csvData,
                uploadResponse: responseData
            )
            #expect(response.0 == true)
        } when: {
            credentialsAreInvalid
        }
    }

    @Test("Decode validate email response")
    func decodeValidateEmailResponse() async throws {
        let response = """
            {
              "result": {
                "email": "cedric@fogowl.com",
                "verdict": "Valid",
                "score": 0.85021,
                "local": "cedric",
                "host": "fogowl.com",
                "checks": {
                  "domain": {
                    "has_valid_address_syntax": true,
                    "has_mx_or_a_record": true,
                    "is_suspected_disposable_address": false
                  },
                  "local_part": {
                    "is_suspected_role_address": false
                  },
                  "additional": {
                    "has_known_bounces": false,
                    "has_suspected_bounces": false
                  }
                },
                "ip_address": "192.168.1.1"
              }
            }
            """
        let responseData = try JSONDecoder().decode(EmailValidationResponse.self, from: response.data(using: .utf8)!)
        #expect(responseData.result.score == 0.85021)
    }

    @Test("Decode Get bulk Email Address")
    func decodeGetBulkEmailAddress() async throws {
        let response = """
            {
              "result": [
                {
                  "id": "01HV9ZZQAFEXW18KFEPTB9YD5E",
                  "status": "Queued",
                  "started_at": 1712954639,
                  "finished_at": 0
                }
              ]
            }
            """
        let responseData = try JSONDecoder().decode(BulkValidationJobResponse.self, from: response.data(using: .utf8)!)
        #expect(responseData.result.count == 1)
    }

    @Test("Decode Get validation Email Address Job")
    func decodeGetEmailAddressJob() async throws {
        let response = """
            {
              "response": {
                "value": {
                  "result": {
                    "id": "01HV9ZZQAFEXW18KFEPTB9YD5E",
                    "status": "Queued",
                    "segments": 0,
                    "segments_processed": 0,
                    "is_download_available": false,
                    "started_at": 1712954639,
                    "finished_at": 0,
                    "errors": []
                  }
                }
              }
            }
            """
        let responseData = try JSONDecoder().decode(ValidationJobResponse.self, from: response.data(using: .utf8)!)
        #expect(responseData.response.value.result.id == "01HV9ZZQAFEXW18KFEPTB9YD5E")
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
            let uploadURLResponse = try await emailValidationClient.getBulkValidationUploadURL(fileType: .csv)

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
            let result = jobStatusResponse.response.value.result
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
