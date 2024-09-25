import Foundation

public struct AdvancedSuppressionManager: Codable, Sendable {
    /// The unsubscribe group to associate with this email.
    ///
    /// See the Suppressions API to manage unsubscribe group IDs.
    public var groupID: Int

    /// An array containing the unsubscribe groups that you would like to be displayed on the unsubscribe preferences page.
    ///
    /// This page is displayed in the recipient's browser when they click the unsubscribe link in your message.
    public var groupsToDisplay: [String]?

    public init(
        groupID: Int,
        groupsToDisplay: [String]? = nil
    ) {
        self.groupID = groupID
        self.groupsToDisplay = groupsToDisplay
    }

    private enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case groupsToDisplay = "groups_to_display"
    }
}
