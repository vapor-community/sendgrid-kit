import AsyncHTTPClient
import Foundation
import SendGridKit
import Testing

@Suite("Email Address Validation Tests")
struct EmailValidationTests {
    let client: SendGridEmailValidationClient
    // TODO: Replace with `false` when you have a valid API key
    let credentialsAreInvalid = true

    init() {
        // TODO: Replace with a valid API key to test
        client = SendGridEmailValidationClient(httpClient: .shared, apiKey: "YOUR-EMAIL-VALIDATION-API-KEY")
    }

    @Test("Email Validation")
    func validateEmail() async throws {
        let validationRequest = EmailValidationRequest(email: "test@example.com", source: "unit_test")

        try await withKnownIssue {
            let response = try await client.validateEmail(validationRequest)

            // Verify response properties exist
            #expect((0.0...1.0).contains(response.result?.score ?? -1))

            // Basic assertions
            if response.result?.verdict == .valid {
                #expect(response.result?.ipAddress != nil)
            } else {
                #expect(!(response.result?.checks?.domain?.hasMXOrARecord ?? true))
            }
        } when: {
            credentialsAreInvalid
        }
    }

    @Test("Get Bulk validation jobs")
    func getBulkValidationJobs() async throws {
        try await withKnownIssue {
            let response = try await client.getBulkEmailValidationJobs()
            #expect(!(response.result?.isEmpty ?? true))
        } when: {
            credentialsAreInvalid
        }
    }

    @Test("Get Bulk validation job status")
    func getBulkValidationJobStatus() async throws {
        try await withKnownIssue {
            let jobID = "12345"  // Replace with a valid job ID
            let jobsResponse = try await client.checkBulkEmailValidationJob(by: jobID)
            #expect(jobsResponse.errors?.isEmpty ?? false)
        } when: {
            credentialsAreInvalid
        }
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

        try await withKnownIssue {
            let fileUpload = try await client.uploadBulkEmailValidationFile(
                fileData: csvData,
                fileType: .csv
            )
            #expect(fileUpload.succeeded)
            #expect(!(fileUpload.jobID?.isEmpty ?? true))
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
        #expect(responseData.result?.score == 0.85021)
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
        let responseData = try JSONDecoder().decode(BulkEmailValidationJobsResponse.self, from: response.data(using: .utf8)!)
        #expect(responseData.result?.count == 1)
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
        let responseData = try JSONDecoder().decode(BulkEmailValidationJob.self, from: response.data(using: .utf8)!)
        #expect(responseData.response?.value?.result?.id == "01HV9ZZQAFEXW18KFEPTB9YD5E")
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

            // Step 1: Upload the CSV file to start the validation job (simulated in this test)
            let fileUpload = try await client.uploadBulkEmailValidationFile(
                fileData: csvData,
                fileType: .csv
            )

            #expect(fileUpload.succeeded)

            // Step 2: Check job status
            let jobStatusResponse = try await client.checkBulkEmailValidationJob(by: fileUpload.jobID ?? "")

            // Verify job status properties
            let result = jobStatusResponse
            #expect(!(result.id?.isEmpty ?? true))
            #expect(result.status == .processing)
            #expect(result.segmentsProcessed != nil)
            #expect(result.segments != nil)
        } when: {
            credentialsAreInvalid
        }
    }
}
