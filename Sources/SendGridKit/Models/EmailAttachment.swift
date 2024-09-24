import Foundation

public struct EmailAttachment: Codable, Sendable {
    /// The Base64 encoded content of the attachment.
    public var content: String

    /// The MIME type of the content you are attaching.
    ///
    /// For example, `image/jpeg`, `text/html` or `application/pdf`.
    public var type: String?

    /// The attachment's filename, including the file extension.
    public var filename: String

    /// The attachment's content-disposition specifies how you would like the attachment to be displayed.
    ///
    /// For example, inline results in the attached file being displayed automatically within the message
    /// while attachment results in the attached file requiring some action to be taken before it is displayed
    /// such as opening or downloading the file.
    public var disposition: Disposition?

    public enum Disposition: String, Codable, Sendable {
        case inline
        case attachment
    }

    /// The content ID for the attachment.
    ///
    /// This is used when the disposition is set to “inline” and the attachment is an image,
    /// allowing the file to be displayed within the body of your email.
    public var contentID: String?

    public init(
        content: String,
        type: String? = nil,
        filename: String,
        disposition: Disposition? = nil,
        contentID: String? = nil
    ) {
        self.content = content
        self.type = type
        self.filename = filename
        self.disposition = disposition
        self.contentID = contentID
    }

    private enum CodingKeys: String, CodingKey {
        case content
        case type
        case filename
        case disposition
        case contentID = "content_id"
    }
}
