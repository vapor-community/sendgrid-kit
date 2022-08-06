import Foundation

public struct EmailAddress: Codable {
    /// format: email
    public var email: String
    
    /// The name of the person to whom you are sending an email.
    public var name: String?
    
    public init(
        email: String,
        name: String? = nil
    ) {
        self.email = email
        self.name = name
    }
}
