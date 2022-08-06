import Foundation

public struct MailSettings: Codable {
    
    /// Allows you to bypass all unsubscribe groups and suppressions to ensure that the email is delivered to every single recipient. This should only be used in emergencies when it is absolutely necessary that every recipient receives your email.
    public var bypassListManagement: Setting?
    
    
    /// Allows you to bypass the spam report list to ensure that the email is delivered to recipients. Bounce and unsubscribe lists will still be checked; addresses on these other lists will not receive the message.
    public var bypassSpamManagement: Setting?

    /// Allows you to bypass the bounce list to ensure that the email is delivered to recipients. Spam report and unsubscribe lists will still be checked; addresses on these other lists will not receive the message.
    public var bypassBounceManagement: Setting?

    /// The default footer that you would like included on every email.
    public var footer: Footer?
    
    /// This allows you to send a test email to ensure that your request body is valid and formatted correctly.
    public var sandboxMode: Setting?
    
    public init(
        bypassListManagement: Setting? = nil,
        bypassSpamManagement: Setting? = nil,
        bypassBounceManagement: Setting? = nil,
        footer: Footer? = nil,
        sandboxMode: Setting? = nil
    ) {
        self.bypassListManagement = bypassListManagement
        self.bypassSpamManagement = bypassSpamManagement
        self.bypassBounceManagement = bypassBounceManagement
        self.footer = footer
        self.sandboxMode = sandboxMode
    }
    
    private enum CodingKeys: String, CodingKey {
        case bypassListManagement = "bypass_list_management"
        case bypassSpamManagement = "bypass_spam_management"
        case bypassBounceManagement = "bypass_bounce_management"
        case footer
        case sandboxMode = "sandbox_mode"
    }
}

public struct Setting: Codable {
    /// Indicates if this setting is enabled.
    public var enable: Bool
    
}

public struct Footer: Codable {
    /// Indicates if this setting is enabled.
    public var enable: Bool
    
    /// The plain text content of your footer.
    public var text: String?
    
    /// The HTML content of your footer.
    public var html: String?
    
    public init(
        enable: Bool,
        text: String? = nil,
        html: String? = nil
    ) {
        self.enable = enable
        self.text = text
        self.html = html
    }
}
