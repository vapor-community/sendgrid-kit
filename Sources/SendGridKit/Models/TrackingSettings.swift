import Foundation

public struct TrackingSettings: Codable, Sendable {
    /// Allows you to track whether a recipient clicked a link in your email.
    public var clickTracking: ClickTracking?
    
    /// Allows you to track whether the email was opened or not,
    /// but including a single pixel image in the body of the content.
    /// 
    /// When the pixel is loaded, we can log that the email was opened.
    public var openTracking: OpenTracking?
    
    /// Allows you to insert a subscription management link at the bottom of the text and HTML bodies of your email.
    /// 
    /// > Tip: If you would like to specify the location of the link within your email, you may use the ``SubscriptionTracking/substitutionTag``.
    public var subscriptionTracking: SubscriptionTracking?
    
    /// Allows you to enable tracking provided by Google Analytics.
    public var ganalytics: GoogleAnalytics?
    
    public init(
        clickTracking: ClickTracking? = nil,
        openTracking: OpenTracking? = nil,
        subscriptionTracking: SubscriptionTracking? = nil,
        ganalytics: GoogleAnalytics? = nil
    ) {
        self.clickTracking = clickTracking
        self.openTracking = openTracking
        self.subscriptionTracking = subscriptionTracking
        self.ganalytics = ganalytics
    }
    
    private enum CodingKeys: String, CodingKey {
        case clickTracking = "click_tracking"
        case openTracking = "open_tracking"
        case subscriptionTracking = "subscription_tracking"
        case ganalytics
    }
}

public struct ClickTracking: Codable, Sendable {
    /// Indicates if this setting is enabled.
    public var enable: Bool
    
    /// Indicates if this setting should be included in the text/plain portion of your email.
    public var enableText: Bool
    
    private enum CodingKeys: String, CodingKey {
        case enable
        case enableText = "enable_text"
    }
}

public struct OpenTracking: Codable, Sendable {
    /// Indicates if this setting is enabled.
    public var enable: Bool
    
    /// Allows you to specify a substitution tag that you can insert in the body of your email at a location that you desire.
    /// 
    /// > Note: This tag will be replaced by the open tracking pixel.
    public var substitutionTag: String?
    
    public init(
        enable: Bool,
        substitutionTag: String? = nil
    ) {
        self.enable = enable
        self.substitutionTag = substitutionTag
    }
    
    private enum CodingKeys: String, CodingKey {
        case enable
        case substitutionTag = "substitution_tag"
    }
}

public struct SubscriptionTracking: Codable, Sendable {
    /// Indicates if this setting is enabled.
    public var enable: Bool
    
    /// Text to be appended to the email, with the subscription tracking link.
    /// 
    /// > Tip: You may control where the link is by using the tag `<% %>`.
    public var text: String?
    
    /// HTML to be appended to the email, with the subscription tracking link.
    /// 
    /// > Tip: You may control where the link is by using the tag `<% %>`.
    public var html: String?
    
    /// A tag that will be replaced with the unsubscribe URL.
    /// 
    /// For example: `[unsubscribe_url]`.
    /// 
    /// If this parameter is used, it will override both the ``SubscriptionTracking/text`` and ``SubscriptionTracking/html`` parameters.
    /// The URL of the link will be placed at the substitution tag’s location, with no additional formatting.
    public var substitutionTag: String?
    
    public init(
        enable: Bool,
        text: String? = nil,
        html: String? = nil,
        substitutionTag: String? = nil
    ) {
        self.enable = enable
        self.text = text
        self.html = html
        self.substitutionTag = substitutionTag
    }
    
    private enum CodingKeys: String, CodingKey {
        case enable
        case text
        case html
        case substitutionTag = "substitution_tag"
    }
}

public struct GoogleAnalytics: Codable, Sendable {
    /// Indicates if this setting is enabled.
    public var enable: Bool
    
    /// Name of the referrer source. (e.g. Google, SomeDomain.com, or Marketing Email)
    public var utmSource: String?
    
    /// Name of the marketing medium. (e.g. Email)
    public var utmMedium: String?
    
    /// Used to identify any paid keywords.
    public var utmTerm: String?
    
    /// Used to differentiate your campaign from advertisements.
    public var utmContent: String?
    
    /// The name of the campaign.
    public var utmCampaign: String?
    
    public init(
        enable: Bool,
        utmSource: String? = nil,
        utmMedium: String? = nil,
        utmTerm: String? = nil,
        utmContent: String? = nil,
        utmCampaign: String? = nil
    ) {
        self.enable = enable
        self.utmSource = utmSource
        self.utmMedium = utmMedium
        self.utmTerm = utmTerm
        self.utmContent = utmContent
        self.utmCampaign = utmCampaign
    }
    
    private enum CodingKeys: String, CodingKey {
        case enable
        case utmSource = "utm_source"
        case utmMedium = "utm_medium"
        case utmTerm = "utm_term"
        case utmContent = "utm_content"
        case utmCampaign = "utm_campaign"
    }
}
