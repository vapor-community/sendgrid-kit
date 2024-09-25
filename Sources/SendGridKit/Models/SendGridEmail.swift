import Foundation

public struct SendGridEmail<DynamicTemplateData: Codable & Sendable>: Codable, Sendable {
    /// An array of messages and their metadata.
    ///
    /// Each object within `personalizations` can be thought of as an envelope -
    /// it defines who should receive an individual message and how that message should be handled.
    public var personalizations: [Personalization<DynamicTemplateData>]

    public var from: EmailAddress

    public var replyTo: EmailAddress?

    /// An array of recipients to whom replies will be sent.
    ///
    /// Each object in this array must contain a recipient's email address.
    /// Each object in the array may optionally contain a recipient's name.
    /// You can use either the `reply_to property` or `reply_to_list` property but not both.
    public var replyToList: [EmailAddress]?

    /// The global or _message level_ subject of your email.
    ///
    /// Subject lines set in personalizations objects will override this global subject line.
    /// See line length limits specified in RFC 2822 for guidance on subject line character limits.
    ///
    /// > Note: Min length: 1.
    public var subject: String?

    /// An array in which you may specify the content of your email.
    public var content: [EmailContent]?

    /// An array of objects in which you can specify any attachments you want to include.
    public var attachments: [EmailAttachment]?

    /// The ID of a template that you would like to use.
    ///
    /// > Note: If you use a template that contains a subject and content (either text or HTML),
    /// you do not need to specify those at the personalizations nor message level.
    public var templateID: String?

    /// An object containing key/value pairs of header names and the value to substitute for them.
    ///
    /// > Important: You must ensure these are properly encoded if they contain unicode characters.
    ///
    /// > Important: Must not be one of the reserved headers.
    public var headers: [String: String]?

    /// An array of category names for this message.
    ///
    /// > Important: Each category name may not exceed 255 characters.
    public var categories: [String]?

    /// Values that are specific to the entire send that will be carried along with the email and its activity data.
    public var customArgs: [String: String]?

    /// A UNIX timestamp allowing you to specify when you want your email to be delivered.
    ///
    /// > Note: This may be overridden by the `personalizations[x].send_at` parameter.
    ///
    /// > Important: You can't schedule more than 72 hours in advance.
    public var sendAt: Date?

    /// This ID represents a batch of emails to be sent at the same time.
    ///
    /// Including a `batch_id` in your request allows you include this email in that batch,
    /// and also enables you to cancel or pause the delivery of that batch.
    public var batchID: String?

    /// An object allowing you to specify how to handle unsubscribes.
    public var asm: AdvancedSuppressionManager?

    /// The IP Pool that you would like to send this email from.
    public var ipPoolName: String?

    /// A collection of different mail settings that you can use to specify how you would like this email to be handled.
    public var mailSettings: MailSettings?

    /// Settings to determine how you would like to track the metrics of how your recipients interact with your email.
    public var trackingSettings: TrackingSettings?

    public init(
        personalizations: [Personalization<DynamicTemplateData>],
        from: EmailAddress,
        replyTo: EmailAddress? = nil,
        replyToList: [EmailAddress]? = nil,
        subject: String? = nil,
        content: [EmailContent]? = nil,
        attachments: [EmailAttachment]? = nil,
        templateID: String? = nil,
        headers: [String: String]? = nil,
        categories: [String]? = nil,
        customArgs: [String: String]? = nil,
        sendAt: Date? = nil,
        batchID: String? = nil,
        asm: AdvancedSuppressionManager? = nil,
        ipPoolName: String? = nil,
        mailSettings: MailSettings? = nil,
        trackingSettings: TrackingSettings? = nil
    ) {
        self.personalizations = personalizations
        self.from = from
        self.replyTo = replyTo
        self.replyToList = replyToList
        self.subject = subject
        self.content = content
        self.attachments = attachments
        self.templateID = templateID
        self.headers = headers
        self.categories = categories
        self.customArgs = customArgs
        self.sendAt = sendAt
        self.batchID = batchID
        self.asm = asm
        self.ipPoolName = ipPoolName
        self.mailSettings = mailSettings
        self.trackingSettings = trackingSettings
    }

    private enum CodingKeys: String, CodingKey {
        case personalizations
        case from
        case replyTo = "reply_to"
        case replyToList = "reply_to_list"
        case subject
        case content
        case attachments
        case templateID = "template_id"
        case headers
        case categories
        case customArgs = "custom_args"
        case sendAt = "send_at"
        case batchID = "batch_id"
        case asm
        case ipPoolName = "ip_pool_name"
        case mailSettings = "mail_settings"
        case trackingSettings = "tracking_settings"
    }
}

extension SendGridEmail where DynamicTemplateData == [String: String] {
    public init(
        personalizations: [Personalization<[String: String]>],
        from: EmailAddress,
        replyTo: EmailAddress? = nil,
        replyToList: [EmailAddress]? = nil,
        subject: String? = nil,
        content: [EmailContent]? = nil,
        attachments: [EmailAttachment]? = nil,
        templateID: String? = nil,
        headers: [String: String]? = nil,
        categories: [String]? = nil,
        customArgs: [String: String]? = nil,
        sendAt: Date? = nil,
        batchID: String? = nil,
        asm: AdvancedSuppressionManager? = nil,
        ipPoolName: String? = nil,
        mailSettings: MailSettings? = nil,
        trackingSettings: TrackingSettings? = nil
    ) {
        self.personalizations = personalizations
        self.from = from
        self.replyTo = replyTo
        self.replyToList = replyToList
        self.subject = subject
        self.content = content
        self.attachments = attachments
        self.templateID = templateID
        self.headers = headers
        self.categories = categories
        self.customArgs = customArgs
        self.sendAt = sendAt
        self.batchID = batchID
        self.asm = asm
        self.ipPoolName = ipPoolName
        self.mailSettings = mailSettings
        self.trackingSettings = trackingSettings
    }
}
