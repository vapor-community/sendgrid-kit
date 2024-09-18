import Foundation

public struct SendGridError: Error, Decodable, Sendable {
    public var errors: [SendGridErrorResponse]?

    /// When applicable, this property value will be an error ID.
    public var ids: String?
}

public struct SendGridErrorResponse: Decodable, Sendable {
    /// An error message.
    public var message: String?

    /// When applicable, this property value will be the field that generated the error.
    public var field: String?

    /// When applicable, this property value will be helper text or a link to documentation to help you troubleshoot the error.
    public var help: String?
}
