import struct Foundation.Date

/// A request to get an upload URL for bulk email validation.
public struct BulkEmailValidationUploadURLRequest: Codable {
    /// The format of the file you wish to upload.
    public let fileType: FileType

    /// Initialize a new ``BulkEmailValidationUploadURLRequest``
    ///
    /// - Parameter fileType: The file type that will be uploaded (CSV or ZIP)
    public init(fileType: FileType) {
        self.fileType = fileType
    }

    /// The format of the file you wish to upload.
    public enum FileType: String, Codable, Sendable {
        /// A CSV file containing email addresses.
        case csv
        /// A ZIP file containing a CSV file with email addresses.
        case zip
    }

    private enum CodingKeys: String, CodingKey {
        case fileType = "file_type"
    }
}

/// The response containing upload details for bulk email validation.
struct BulkEmailValidationUploadURLResponse: Codable, Sendable {
    /// The unique ID of the Bulk Email Address Validation Job.
    let jobID: String?

    /// The URI to use for the request to upload your list of email addresses.
    let uploadURI: String?

    /// Array containing headers and header values.
    let uploadHeaders: [UploadHeader]?

    /// Header for the upload request.
    struct UploadHeader: Codable, Sendable {
        /// The name of the header that must be included in the upload request.
        let header: String?

        /// The value of the header that must be included in the upload request.
        let value: String?
    }

    private enum CodingKeys: String, CodingKey {
        case jobID = "job_id"
        case uploadURI = "upload_uri"
        case uploadHeaders = "upload_headers"
    }
}

/// A response that returns a specific Bulk Email Validation Job.
///
/// You can use this endpoint to check on the progress of a Job.
public struct BulkEmailValidationJob: Codable, Sendable {
    /// A response that returns a specific Bulk Email Validation Job.
    public let response: Response?

    /// A response that returns a specific Bulk Email Validation Job.
    public struct Response: Codable, Sendable {
        public let value: Value?

        public struct Value: Codable, Sendable {
            /// The status of a specific Bulk Email Validation Job.
            public let result: Result?

            /// The status of a specific Bulk Email Validation Job.
            public struct Result: Codable, Sendable {
                /// The unique ID of the Bulk Email Address Validation Job.
                public let id: String?

                /// The status of the Bulk Email Address Validation Job.
                public let status: BulkEmailValidationJobStatus?

                /// The total number of segments in the Bulk Email Address Validation Job.
                ///
                /// There are 1,500 email addresses per segment.
                /// The value is 0 until the Job status is ``BulkEmailValidationJobStatus/processing``.
                public let segments: Int?

                /// The number of segments processed at the time of the request.
                ///
                /// 100 segments process in parallel at a time.
                public let segmentsProcessed: Int?

                /// Boolean indicating whether the results CSV file is available for download.
                public let isDownloadAvailable: Bool?

                /// The date when the Job was created.
                ///
                /// This is the time at which the upload request was sent to the `upload_uri`.
                public let startedAt: Date?

                /// The date when the Job was finished.
                public let finishedAt: Date?

                /// Array containing error messages related to the Bulk Email Address Validation Job.
                ///
                /// Array is empty if no errors ocurred.
                public let errors: [BulkValidationError]?

                /// Error message related to the Bulk Email Address Validation Job.
                public struct BulkValidationError: Codable, Sendable {
                    /// Description of the error encountered during execution of the Bulk Email Address Validation Job.
                    public let message: String?
                }

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

/// The status of the Bulk Email Address Validation Job.
public enum BulkEmailValidationJobStatus: String, Codable, Sendable {
    case initiated = "Initiated"
    case queued = "Queued"
    case ready = "Ready"
    case processing = "Processing"
    case done = "Done"
    case error = "Error"
}

/// A response containing a list of all of a user's Bulk Email Validation Jobs.
public struct BulkEmailValidationJobsResponse: Codable, Sendable {
    /// The result of the response, containing an array of all of the user's Bulk Email Validation Jobs.
    public let result: [Result]?

    /// A user's Bulk Email Validation Job.
    public struct Result: Codable, Sendable {
        /// The unique ID of the Bulk Email Address Validation Job.
        public let id: String?

        /// The status of the Bulk Email Address Validation Job.
        public let status: BulkEmailValidationJobStatus?

        /// The date when the Job was created. This is the time at which the upload request was sent to the `upload_uri`.
        public let startedAt: Date?

        /// The date when the Job was finished.
        public let finishedAt: Date?

        private enum CodingKeys: String, CodingKey {
            case id, status
            case startedAt = "started_at"
            case finishedAt = "finished_at"
        }
    }
}
