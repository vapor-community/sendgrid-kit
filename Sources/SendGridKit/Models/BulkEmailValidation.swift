import struct Foundation.Date

/// A request to get an upload URL for bulk email validation.
public struct BulkEmailValidationUploadURLRequest: Encodable {
    /// The file type that will be uploaded.
    public let fileType: FileType

    /// Initialize a new `BulkEmailValidationUploadURLRequest`
    ///
    /// - Parameter fileType: The file type that will be uploaded (CSV or ZIP)
    public init(fileType: FileType) {
        self.fileType = fileType
    }

    /// The type of file that will be uploaded for bulk validation.
    public enum FileType: String, Codable, Sendable {
        /// A CSV file containing email addresses.
        case csv
        /// A ZIP file containing a CSV file with email addresses.
        case zip
    }

    /// CodingKeys for mapping JSON fields to struct properties
    private enum CodingKeys: String, CodingKey {
        case fileType = "file_type"
    }
}

/// The response containing upload details for bulk email validation.
struct BulkEmailValidationUploadURLResponse: Decodable, Sendable {
    /// The unique identifier for the validation job.
    let jobId: String

    /// The URI where the file should be uploaded.
    let uploadUri: String

    /// Headers that should be included in the upload request.
    let uploadHeaders: [UploadHeader]

    /// Header for the upload request.
    struct UploadHeader: Codable, Sendable {
        /// The name of the header.
        let header: String

        /// The value of the header.
        let value: String
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
    public let response: JobResponse

    public struct JobResponse: Decodable, Sendable {
        public let value: ValidationJobValue

        public struct ValidationJobValue: Decodable, Sendable {
            public let result: Result

            /// The status result of a bulk email validation job.
            public struct Result: Decodable, Sendable {
                /// The unique identifier for the validation job.
                public let id: String

                /// Status of the validation job (e.g., "Queued", "Processing", "Completed").
                public let status: BulkEmailValidationJobStatus

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
                public let errors: [BulkValidationError]?

                public struct BulkValidationError: Decodable, Sendable {
                    /// Description of the error encountered during execution of the Bulk Email Address Validation Job.
                    public let message: String
                }

                /// CodingKeys for mapping JSON fields to struct properties
                private enum CodingKeys: String, CodingKey {
                    case id, status, segments, errors
                    case segmentsProcessed = "segments_processed"
                    case isDownloadAvailable = "is_download_available"
                    case startedAt = "started_at"
                    case finishedAt = "finished_at"
                }
            }
        }
    }
}

/// BulkEmailValidationJobStatus
public enum BulkEmailValidationJobStatus: String, Codable, Sendable {
    case initiated = "Initiated"
    case queued = "Queued"
    case ready = "Ready"
    case processing = "Processing"
    case done = "Done"
    case error = "Error"
}

/// The result of a bulk email validation operation.
public struct BulkEmailValidationJobsResponse: Codable, Sendable {
    /// The response structure containing the validation results.
    public let result: [Result]

    /// Nested response structure containing the results value.
    public struct Result: Codable, Sendable {
        /// The unique ID of the Bulk Email Address Validation Job.
        public let id: String

        /// The status of the Bulk Email Address Validation Job.
        public let status: BulkEmailValidationJobStatus

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
