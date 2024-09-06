import Foundation

public struct SendGridError: Error, Decodable {
    public var errors: [SendGridErrorResponse]?
}

public struct SendGridErrorResponse: Decodable, Sendable {
    public var message: String?
    public var field: String?
    public var help: String?
}
