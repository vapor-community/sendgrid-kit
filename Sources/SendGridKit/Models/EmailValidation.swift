import Foundation

/// A request to validate an email address using SendGrid's Email Validation API.
public struct EmailValidationRequest: Encodable {
    /// The email address to validate.
    public let email: String

    /// Optional source of the email address being validated.
    public let source: String?

    /// Initialize a new `EmailValidationRequest`
    ///
    /// - Parameters:
    ///   - email: The email address to validate
    ///   - source: Optional source of the email address being validated
    public init(email: String, source: String? = nil) {
        self.email = email
        self.source = source
    }
}

/// A request to get an upload URL for bulk email validation.
public struct BulkValidationUploadURLRequest: Encodable {
    /// The file type that will be uploaded.
    public let fileType: FileType

    /// Initialize a new `BulkValidationUploadURLRequest`
    ///
    /// - Parameter fileType: The file type that will be uploaded (CSV or ZIP)
    public init(fileType: FileType) {
        self.fileType = fileType
    }

    /// The type of file that will be uploaded for bulk validation.
    public enum FileType: String, Codable, Sendable {
        /// A CSV file containing email addresses.
        case csv = "csv"
        /// A ZIP file containing a CSV file with email addresses.
        case zip = "zip"
    }

    /// CodingKeys for mapping JSON fields to struct properties
    private enum CodingKeys: String, CodingKey {
        case fileType = "file_type"
    }
}

/// The response from SendGrid's Email Validation API.
public struct EmailValidationResponse: Decodable, Sendable {
    /// The overall verdict for the email address.
    public let result: ValidationResult

    /// The overall result of email validation.
    public struct ValidationResult: Decodable, Sendable {

        /// The email address that was validated.
        public let email: String

        /// The verdict on the email address.
        public let verdict: Verdict

        /// The score representing the quality of the email address (0.0 to 1.0).
        public let score: Double

        /// The local part of the email address.
        public let local: String

        /// The domain of the email address.
        public let host: String

        /// A suggested correction in the event of domain name typos (e.g., gmial.com)
        public let suggestion: String?

        /// Granular checks for email address validity.
        public let checks: ValidationChecks

        /// The IP address associated with this email.
        public let ipAddress: String?

        /// The source of the validation, as per the API request.
        public let source: String?

        public enum Verdict: String, Codable, Sendable {
            case valid = "Valid"
            case risky = "Risky"
            case invalid = "Invalid"
        }

        private enum CodingKeys: String, CodingKey {
            case email
            case verdict
            case score
            case local
            case host
            case suggestion
            case checks
            case source
            case ipAddress = "ip_address"
        }
    }
}

/// Various checks performed during email validation.
public struct ValidationChecks: Decodable, Sendable {

    /// Checks on the domain portion of the email address.
    public let domain: Domain

    /// Checks on the local part of the email address.
    public let localPart: LocalPartInfo

    /// Additional checks on the email address.
    public let additional: AdditionalInfo

    public struct AdditionalInfo: Decodable, Sendable {
        /// Whether email sent to this address from your account has bounced.
        public let hasKnownBounces: Bool
        /// Whether our model predicts that the email address might bounce.
        public let hasSuspectedBounces: Bool

        enum CodingKeys: String, CodingKey {
            case hasKnownBounces = "has_known_bounces"
            case hasSuspectedBounces = "has_suspected_bounces"
        }
    }

    public struct LocalPartInfo: Decodable, Sendable {
        /// Whether the local part of email appears to be a role or group (e.g., hr, admin)
        public let isSuspectedRoleAddress: Bool

        enum CodingKeys: String, CodingKey {
            case isSuspectedRoleAddress = "is_suspected_role_address"
        }
    }

    public struct Domain: Decodable, Sendable {
        /// Whether the email address syntax is valid.
        public let hasValidAddressSyntax: Bool
        /// Whether the email has appropriate DNS records to deliver a message.
        public let hasMXOrARecord: Bool
        /// Whether the domain appears to be from a disposable email address service.
        public let isSuspectedDisposableAddress: Bool

        enum CodingKeys: String, CodingKey {
            case hasValidAddressSyntax = "has_valid_address_syntax"
            case hasMXOrARecord = "has_mx_or_a_record"
            case isSuspectedDisposableAddress = "is_suspected_disposable_address"
        }
    }

    /// CodingKeys for mapping JSON fields to struct properties
    private enum CodingKeys: String, CodingKey {
        case domain
        case localPart = "local_part"
        case additional
    }
}

/// Information about the SMTP check.
public struct SMTPCheck: Codable, Sendable {
    /// Whether the SMTP check was successful.
    public let success: Bool

    /// The reason for the SMTP check result.
    public let reason: String?
}

/// Additional information about the email validation.
public struct AdditionalInfo: Decodable, Sendable {
    /// The IP address used for validation.
    public let ipAddress: String?

    /// The source of the validation request.
    public let source: String?

    /// CodingKeys for mapping JSON fields to struct properties
    private enum CodingKeys: String, CodingKey {
        case ipAddress = "ip_address"
        case source
    }
}

/// The response containing upload details for bulk email validation.
public struct BulkValidationUploadURLResponse: Decodable, Sendable {
    /// The unique identifier for the validation job.
    public let jobId: String

    /// The URI where the file should be uploaded.
    public let uploadUri: String

    /// Headers that should be included in the upload request.
    public let uploadHeaders: [UploadHeader]

    /// Header for the upload request.
    public struct UploadHeader: Codable, Sendable {
        /// The name of the header.
        public let header: String

        /// The value of the header.
        public let value: String
    }

    /// CodingKeys for mapping JSON fields to struct properties
    private enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case uploadUri = "upload_uri"
        case uploadHeaders = "upload_headers"
    }
}

/// The response from initiating a bulk email validation job after upload.
public struct ValidationJobResponse: Decodable, Sendable {
    /// The response structure containing the job creation status.
    public let response: ValidationJobResponse

    public struct ValidationJobResponse: Decodable, Sendable {
        public let value: ValidationJobValue
    }

    public struct ValidationJobValue: Decodable, Sendable {
        public let result: ValidationJobResult
    }
}

/// The response from initiating a bulk email validation job after upload.
public struct BulkValidationJobResponse: Decodable, Sendable {
    /// The response structure containing the job creation status.
    public let result: [ValidationJobResult]
}

/// The status result of a bulk email validation job.
public struct ValidationJobResult: Decodable, Sendable {
    /// The unique identifier for the validation job.
    public let id: String

    /// Status of the validation job (e.g., "Queued", "Processing", "Completed").
    public let status: BuildEmailValidationStatus

    /// The total number of segments in the Bulk Email Address Validation Job.
    /// There are 1,500 email addresses per segment. The value is 0 until the Job status is Processing.
    public let segments: Int?

    /// The number of segments processed at the time of the request.
    /// 100 segments process in parallel at a time.
    public let segmentsProcessed: Int?

    /// Boolean indicating whether the results CSV file is available for download.
    public let isDownloadAvailable: Bool?

    /// The ISO8601 timestamp when the Job was created.
    /// This is the time at which the upload request was sent to the upload_uri.
    public let startedAt: Date

    /// The ISO8601 timestamp when the Job was finished.
    public let finishedAt: Date?

    /// Array containing error messages related to the Bulk Email Address Validation Job.
    /// Array is empty if no errors ocurred.
    public let errors: [SendGridError.Description]?

    /// CodingKeys for mapping JSON fields to struct properties
    private enum CodingKeys: String, CodingKey {
        case id, status, segments, errors
        case segmentsProcessed = "segments_processed"
        case isDownloadAvailable = "is_download_available"
        case startedAt = "started_at"
        case finishedAt = "finished_at"
    }
}

public enum BuildEmailValidationStatus: String, Codable, Sendable {
    case initiated = "Initiated"
    case queued = "Queued"
    case ready = "Ready"
    case processing = "Processing"
    case done = "Done"
    case error = "Error"
}

/// The result of a bulk email validation operation.
public struct BulkEmailValidationJobResponse: Codable, Sendable {
    /// The response structure containing the validation results.
    public let result: [BulkValidationJobResponse]

    /// Nested response structure containing the results value.
    public struct BulkValidationJobResponse: Codable, Sendable {
        /// The unique ID of the Bulk Email Address Validation Job.
        public let id: String

        /// The status of the Bulk Email Address Validation Job.
        public let status: BuildEmailValidationStatus

        /// The ISO8601 timestamp when the Job was created. This is the time at which the upload request was sent to the upload_uri.
        public let startedAt: Date

        /// The ISO8601 timestamp when the Job was finished.
        public let finishedAt: Date?

        private enum CodingKeys: String, CodingKey {
            case id, status
            case startedAt = "started_at"
            case finishedAt = "finished_at"
        }
    }
}
