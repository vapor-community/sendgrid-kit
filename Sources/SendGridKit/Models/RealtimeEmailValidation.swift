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
