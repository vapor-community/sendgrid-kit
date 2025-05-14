import AsyncHTTPClient
import Foundation
import NIO
import NIOFoundationCompat
import NIOHTTP1

/// A client for sending emails using the SendGrid API.
public struct SendGridClient: Sendable {
    private let baseURL: String
    private let httpClient: HTTPClient
    private let apiKey: String
    private let emailValidationAPIKey: String?

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

    /// Initialize a new `SendGridClient`
    ///
    /// - Parameters:
    ///   - httpClient: The `HTTPClient` to use for sending requests
    ///   - apiKey: The SendGrid API key
    ///   - forEU: Whether to use the API endpoint for global users and subusers or for EU regional subusers
    public init(httpClient: HTTPClient, apiKey: String, forEU: Bool = false) {
        self.httpClient = httpClient
        self.apiKey = apiKey
        self.baseURL = forEU ? "https://api.eu.sendgrid.com/v3" : "https://api.sendgrid.com/v3"
        self.emailValidationAPIKey = nil
    }

    /// Initialize a new `SendGridClient`
    ///
    /// - Parameters:
    ///   - httpClient: The `HTTPClient` to use for sending requests
    ///   - apiKey: The SendGrid API key
    ///   - emailValidationAPIKey: The SendGrid Email validation API key
    ///   - forEU: Whether to use the API endpoint for global users and subusers or for EU regional subusers
    public init(httpClient: HTTPClient, apiKey: String, emailValidationAPIKey: String, forEU: Bool = false) {
        self.httpClient = httpClient
        self.apiKey = apiKey
        self.emailValidationAPIKey = emailValidationAPIKey
        self.baseURL = forEU ? "https://api.eu.sendgrid.com/v3" : "https://api.sendgrid.com/v3"
    }

    /// Send an email using the SendGrid API.
    ///
    /// - Parameter email: The ``SendGridEmail`` to send.
    public func send<DynamicTemplateData: Codable & Sendable>(email: SendGridEmail<DynamicTemplateData>) async throws {
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(self.apiKey)")
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "User-Agent", value: "Swift SendGridKit/3.0.0")

        var request = HTTPClientRequest(url: "\(self.baseURL)/mail/send")
        request.method = .POST
        request.headers = headers
        request.body = try HTTPClientRequest.Body.bytes(self.encoder.encode(email))

        let response = try await self.httpClient.execute(request, timeout: .seconds(30))

        // If the request was accepted, simply return
        if (200...299).contains(response.status.code) { return }

        // `JSONDecoder` will handle empty body by throwing decoding error
        throw try await self.decoder.decode(SendGridError.self, from: response.body.collect(upTo: 1024 * 1024))
    }

    /// Validate an email address using the SendGrid Email Validation API.
    ///
    /// - Parameter validationRequest: The ``EmailValidationRequest`` containing the email to validate.
    /// - Returns: An ``EmailValidationResponse`` with validation details.
    public func validateEmail(validationRequest: EmailValidationRequest) async throws -> EmailValidationResponse {
        guard let apiKey = self.emailValidationAPIKey else {
            throw SendGridError(id: "Email Validation API key not set")
        }
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "User-Agent", value: "Swift SendGridKit/3.0.0")

        var request = HTTPClientRequest(url: "\(self.baseURL)/validations/email")
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
    public func getBulkValidationUploadURL(fileType: BulkValidationUploadURLRequest.FileType) async throws
        -> BulkValidationUploadURLResponse
    {
        guard let apiKey = self.emailValidationAPIKey else {
            throw SendGridError(id: "Email Validation API key not set")
        }
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "User-Agent", value: "Swift SendGridKit/3.0.0")

        var request = HTTPClientRequest(url: "\(self.baseURL)/validations/email/jobs")
        request.method = .POST
        request.headers = headers

        let uploadRequest = BulkValidationUploadURLRequest(fileType: fileType)
        request.body = try HTTPClientRequest.Body.bytes(self.encoder.encode(uploadRequest))

        let response = try await self.httpClient.execute(request, timeout: .seconds(30))

        // If the request is successful, decode the response
        if (200...299).contains(response.status.code) {
            let body = try await response.body.collect(upTo: 1024 * 1024)
            return try self.decoder.decode(BulkValidationUploadURLResponse.self, from: body)
        }

        // Otherwise, decode the error
        throw try await self.decoder.decode(SendGridError.self, from: response.body.collect(upTo: 1024 * 1024))
    }

    /// Upload a file to the provided URL for bulk email validation.
    ///
    /// - Parameters:
    ///   - fileData: The data of the file to upload (CSV or ZIP).
    ///   - uploadResponse: The ``BulkValidationUploadURLResponse`` containing upload details.
    /// - Returns: `true` if the upload was successful, and the job ID.
    public func uploadBulkValidationFile(fileData: Data, uploadResponse: BulkValidationUploadURLResponse) async throws -> (Bool, String) {
        // Create a request to the upload URL
        var request = HTTPClientRequest(url: uploadResponse.uploadUri)
        request.method = .PUT  // Default to PUT method for S3 uploads

        // Set the headers from the upload response
        var headers = HTTPHeaders()
        for headerData in uploadResponse.uploadHeaders {
            headers.add(name: headerData.header, value: headerData.value)
        }
        request.headers = headers

        // Add the file data as the request body
        request.body = .bytes(fileData)

        // Execute the request
        let response = try await self.httpClient.execute(request, timeout: .seconds(180))

        // Check if the upload was successful and return the job ID
        return ((200...299).contains(response.status.code), uploadResponse.jobId)
    }

    /// Check the status of a bulk email validation job.
    ///
    /// - Parameter jobId: The ID of the bulk validation job.
    /// - Returns: A ``BulkValidationJobResponse`` with information about the job status.
    public func checkBulkValidationStatus(jobId: String) async throws -> BulkValidationJobResponse {
        guard let apiKey = self.emailValidationAPIKey else {
            throw SendGridError(id: "Email Validation API key not set")
        }
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        headers.add(name: "User-Agent", value: "Swift SendGridKit/3.0.0")

        var request = HTTPClientRequest(url: "\(self.baseURL)/validations/email/batch/\(jobId)")
        request.method = .GET
        request.headers = headers

        let response = try await self.httpClient.execute(request, timeout: .seconds(30))

        // If the request is successful, decode the response
        if (200...299).contains(response.status.code) {
            let body = try await response.body.collect(upTo: 1024 * 1024)
            return try self.decoder.decode(BulkValidationJobResponse.self, from: body)
        }

        // Otherwise, decode the error
        throw try await self.decoder.decode(SendGridError.self, from: response.body.collect(upTo: 1024 * 1024))
    }

    /// Get the results of a completed bulk email validation job.
    ///
    /// - Parameter jobId: The ID of the completed bulk validation job.
    /// - Returns: A ``BulkEmailValidationJobResponse`` containing the validation results for each email.
    public func getBulkEmailValidationJobs() async throws -> BulkEmailValidationJobResponse {
        guard let apiKey = self.emailValidationAPIKey else {
            throw SendGridError(id: "Email Validation API key not set")
        }
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        headers.add(name: "User-Agent", value: "Swift SendGridKit/3.0.0")

        var request = HTTPClientRequest(url: "\(self.baseURL)/validations/email/jobs")
        request.method = .GET
        request.headers = headers

        let response = try await self.httpClient.execute(request, timeout: .seconds(60))

        // If the request is successful, decode the response
        if (200...299).contains(response.status.code) {
            let body = try await response.body.collect(upTo: 1024 * 1024)
            return try self.decoder.decode(BulkEmailValidationJobResponse.self, from: body)
        }

        // Otherwise, decode the error
        throw try await self.decoder.decode(SendGridError.self, from: response.body.collect(upTo: 1024 * 1024))
    }
}
