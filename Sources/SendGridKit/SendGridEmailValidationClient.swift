import AsyncHTTPClient
import Foundation
import NIO
import NIOFoundationCompat
import NIOHTTP1

/// A client for validating email addresses using the SendGrid Email Address Validation API.
public struct SendGridEmailValidationClient: Sendable {
    private let baseURL: String
    private let httpClient: HTTPClient
    private let apiKey: String

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

    /// Initialize a new ``SendGridEmailValidationClient``
    ///
    /// - Parameters:
    ///   - httpClient: The `HTTPClient` to use for sending requests
    ///   - apiKey: The Email Validation API key
    ///   - forEU: Whether to use the API endpoint for global users and subusers or for EU regional subusers
    public init(httpClient: HTTPClient, apiKey: String, forEU: Bool = false) {
        self.httpClient = httpClient
        self.apiKey = apiKey
        self.baseURL = forEU ? "https://api.eu.sendgrid.com/v3/validations/email" : "https://api.sendgrid.com/v3/validations/email"
    }

    /// Validate an email address.
    ///
    /// - Parameter validationRequest: The ``EmailValidationRequest`` containing the email to validate.
    /// - Returns: An ``EmailValidationResponse`` with validation details.
    public func validateEmail(_ validationRequest: EmailValidationRequest) async throws -> EmailValidationResponse {
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "User-Agent", value: "Swift SendGridKit/3.0.0")

        var request = HTTPClientRequest(url: self.baseURL)
        request.method = .POST
        request.headers = headers
        request.body = try HTTPClientRequest.Body.bytes(self.encoder.encode(validationRequest))

        let response = try await self.httpClient.execute(request, timeout: .seconds(30))

        // If the request is successful, decode the response
        if (200...299).contains(response.status.code) {
            let body = try await response.body.collect(upTo: 1024 * 1024)
            return try self.decoder.decode(EmailValidationResponse.self, from: body)
        }

        // Otherwise, decode the error
        throw try await self.decoder.decode(SendGridError.self, from: response.body.collect(upTo: 1024 * 1024))
    }

    /// Request an upload URL for bulk email validation using the SendGrid Email Validation API.
    ///
    /// - Parameter fileType: The type of file to be uploaded (CSV or ZIP).
    /// - Returns: A ``BulkValidationUploadURLResponse`` with the upload URL and details.
    private func getBulkEmailValidationUploadURL(
        for fileType: BulkEmailValidationUploadURLRequest.FileType
    ) async throws -> BulkEmailValidationUploadURLResponse {
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "User-Agent", value: "Swift SendGridKit/3.0.0")

        var request = HTTPClientRequest(url: "\(self.baseURL)/jobs")
        request.method = .POST
        request.headers = headers

        let uploadRequest = BulkEmailValidationUploadURLRequest(fileType: fileType)
        request.body = try HTTPClientRequest.Body.bytes(self.encoder.encode(uploadRequest))

        let response = try await self.httpClient.execute(request, timeout: .seconds(30))

        // If the request is successful, decode the response
        if (200...299).contains(response.status.code) {
            let body = try await response.body.collect(upTo: 1024 * 1024)
            return try self.decoder.decode(BulkEmailValidationUploadURLResponse.self, from: body)
        }

        // Otherwise, decode the error
        throw try await self.decoder.decode(SendGridError.self, from: response.body.collect(upTo: 1024 * 1024))
    }

    public typealias UploadBulkEmailValidationFileResult = (succeeded: Bool, jobID: String?)

    /// Upload a list of email addresses for verification.
    ///
    /// - Parameters:
    ///   - fileData: The data of the file to upload (CSV or ZIP).
    ///   - fileType: The type of file being uploaded (CSV or ZIP).
    /// - Returns: `true` if the upload was successful, and the job ID.
    public func uploadBulkEmailValidationFile(
        fileData: Data,
        fileType: BulkEmailValidationUploadURLRequest.FileType
    ) async throws -> UploadBulkEmailValidationFileResult {
        // Request upload file URL
        let uploadResponse = try await getBulkEmailValidationUploadURL(for: fileType)

        guard
            let uploadURI = uploadResponse.uploadURI,
            let uploadHeaders = uploadResponse.uploadHeaders
        else {
            return (false, nil)
        }

        // Create a request to the upload URL
        var request = HTTPClientRequest(url: uploadURI)
        request.method = .PUT  // Default to PUT method for S3 uploads

        // Set the headers from the upload response
        var headers = HTTPHeaders()
        for headerData in uploadHeaders {
            if let header = headerData.header, let value = headerData.value {
                headers.add(name: header, value: value)
            }
        }
        request.headers = headers

        // Add the file data as the request body
        request.body = .bytes(fileData)

        // Execute the request
        let response = try await self.httpClient.execute(request, timeout: .seconds(180))

        // Check if the upload was successful and return the job ID
        return ((200...299).contains(response.status.code), uploadResponse.jobID)
    }

    /// Check the progress of a Bulk Email Address Validation Job.
    ///
    /// - Parameter jobID: The ID of the Bulk Email Address Validation Job you wish to retrieve.
    /// - Returns: A ``BulkEmailValidationJob/Response/Value/Result`` with information about the job status.
    public func checkBulkEmailValidationJob(by jobID: String) async throws -> BulkEmailValidationJob.Response.Value.Result {
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        headers.add(name: "User-Agent", value: "Swift SendGridKit/3.0.0")

        var request = HTTPClientRequest(url: "\(self.baseURL)/jobs/\(jobID)")
        request.method = .GET
        request.headers = headers

        let response = try await self.httpClient.execute(request, timeout: .seconds(30))

        // If the request is successful, decode the response
        if (200...299).contains(response.status.code) {
            let body = try await response.body.collect(upTo: 1024 * 1024)
            let data = try self.decoder.decode(BulkEmailValidationJob.self, from: body)
            if let result = data.response?.value?.result {
                return result
            }
        }

        // Otherwise, decode the error
        throw try await self.decoder.decode(SendGridError.self, from: response.body.collect(upTo: 1024 * 1024))
    }

    /// Get a list of all of a user's Bulk Email Validation Jobs.
    ///
    /// - Returns: A ``BulkEmailValidationJobsResponse`` containing a list of all of your Bulk Email Validation Jobs.
    public func getBulkEmailValidationJobs() async throws -> BulkEmailValidationJobsResponse {
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        headers.add(name: "User-Agent", value: "Swift SendGridKit/3.0.0")

        var request = HTTPClientRequest(url: "\(self.baseURL)/jobs")
        request.method = .GET
        request.headers = headers

        let response = try await self.httpClient.execute(request, timeout: .seconds(60))

        // If the request is successful, decode the response
        if (200...299).contains(response.status.code) {
            let body = try await response.body.collect(upTo: 1024 * 1024)
            return try self.decoder.decode(BulkEmailValidationJobsResponse.self, from: body)
        }

        // Otherwise, decode the error
        throw try await self.decoder.decode(SendGridError.self, from: response.body.collect(upTo: 1024 * 1024))
    }
}
