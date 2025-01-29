import Foundation

/// An error response from the SendGrid API.
public struct SendGridError: Error, Decodable, Sendable {
    /// The errors returned by the SendGrid API.
    public var errors: [Description]?

    /// When applicable, this property value will be an error ID.
    public var id: String?

    /// The description of the ``SendGridError``.
    public struct Description: Decodable, Sendable {
        /// An error message.
        public var message: String?

        /// When applicable, this property value will be the field that generated the error.
        public var field: String?

        /// When applicable, this property value will be helper text or a link to documentation to help you troubleshoot the error.
        public var help: String?
    }
}
