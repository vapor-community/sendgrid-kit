//
//  EmailAttachment.swift
//  Sendgrid
//
//  Created by Andrew Edwards on 3/29/18.
//

import Foundation

public struct EmailAttachment: Encodable {
    
    /// The Base64 encoded content of the attachment.
    public var content: String?
    
    /// The mime type of the content you are attaching. For example, “text/plain” or “text/html”.
    public var type: String?
    
    /// The filename of the attachment.
    public var filename: String?
    
    /// The content-disposition of the attachment specifying how you would like the attachment to be displayed.
    public var disposition: String?
    
    /// The content id for the attachment. This is used when the disposition is set to “inline” and the attachment is an image, allowing the file to be displayed within the body of your email.
    public var contentId: String?
    
    public init(content: String? = nil,
                type: String? = nil,
                filename: String? = nil,
                disposition: String? = nil,
                contentId: String? = nil) {
        self.content = content
        self.type = type
        self.filename = filename
        self.disposition = disposition
        self.contentId = contentId
    }
    
    private enum CodingKeys: String, CodingKey {
        case content
        case type
        case filename
        case disposition
        case contentId = "content_id"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(content, forKey: .content)
        try container.encode(type, forKey: .type)
        try container.encode(filename, forKey: .filename)
        try container.encode(disposition, forKey: .disposition)
        try container.encode(contentId, forKey: .contentId)
    }
}
