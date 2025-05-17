/// A request to validate an email address using SendGrid's Real Time Email Address Validation API.
public struct EmailValidationRequest: Codable {
    /// The email address that you want to validate.
    public let email: String

    /// A one-word classifier for where this validation originated.
    public let source: String?

    /// Initialize a new ``EmailValidationRequest``.
    ///
    /// - Parameters:
    ///   - email: The email address that you want to validate.
    ///   - source: A one-word classifier for where this validation originated.
    public init(email: String, source: String? = nil) {
        self.email = email
        self.source = source
    }
}

/// The response from SendGrid's Real Time Email Address Validation API.
public struct EmailValidationResponse: Codable, Sendable {
    /// The overall verdict for the email address.
    public let result: Result?

    /// The overall result of email validation.
    public struct Result: Codable, Sendable {
        /// The email being validated
        public let email: String?

        /// A generic classification of whether or not the email address is valid.
        public let verdict: Verdict?

        /// A numeric representation of the email validity (0.0 to 1.0).
        public let score: Double?

        /// The local part of the email address.
        public let local: String?

        /// The domain of the email address.
        public let host: String?

        /// A suggested correction in the event of domain name typos (e.g., gmial.com)
        public let suggestion: String?

        /// Granular checks for email address validity.
        public let checks: Checks?

        /// The IP address associated with this email.
        public let ipAddress: String?

        /// The source of the validation, as per the API request.
        public let source: String?

        /// A generic classification of whether or not the email address is valid.
        public enum Verdict: String, Codable, Sendable {
            case valid = "Valid"
            case risky = "Risky"
            case invalid = "Invalid"
        }

        /// Granular checks for email address validity.
        public struct Checks: Codable, Sendable {
            /// Checks on the domain portion of the email address.
            public let domain: Domain?

            /// Checks on the local part of the email address.
            public let localPart: LocalPart?

            /// Additional checks on the email address.
            public let additional: Additional?

            /// Additional checks on the email address.
            public struct Additional: Codable, Sendable {
                /// Whether email sent to this address from your account has bounced.
                public let hasKnownBounces: Bool?

                /// Whether our model predicts that the email address might bounce.
                public let hasSuspectedBounces: Bool?

                private enum CodingKeys: String, CodingKey {
                    case hasKnownBounces = "has_known_bounces"
                    case hasSuspectedBounces = "has_suspected_bounces"
                }
            }

            /// Checks on the local part of the email address.
            public struct LocalPart: Codable, Sendable {
                /// Whether the local part of email appears to be a role or group (e.g., hr, admin)
                public let isSuspectedRoleAddress: Bool?

                private enum CodingKeys: String, CodingKey {
                    case isSuspectedRoleAddress = "is_suspected_role_address"
                }
            }

            /// Checks on the domain portion of the email address.
            public struct Domain: Codable, Sendable {
                /// Whether the email address syntax is valid.
                public let hasValidAddressSyntax: Bool?

                /// Whether the email has appropriate DNS records to deliver a message.
                public let hasMXOrARecord: Bool?

                /// Whether the domain appears to be from a disposable email address service.
                public let isSuspectedDisposableAddress: Bool?

                private enum CodingKeys: String, CodingKey {
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
