import Foundation

public struct EmailContent: Encodable {
    public let type: String
    public let value: String

    public init(type: String, value: String) {
        self.type = type
        self.value = value
    }
}

extension EmailContent: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(type: "text/plain", value: value)
    }
}
