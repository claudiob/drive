import UIKit

/// What a conversation is made of once it is laid out: blocks of messages from the same
/// side, each under the time the block began.
enum ConversationRow {
    case time(NSAttributedString)
    /// `reports` marks the last message we sent, which is the only one Messages says
    /// Sent or Delivered under: the ones above it are answered by the fact of it.
    case bubble(Bubble, reports: Bool)

    private static let clock = format("h:mm a")
    private static let weekday = format("EEEE")
    private static let day = format("MMM d, yyyy")
    private static let iso = ISO8601DateFormatter()

    /// Groups consecutive messages from the same side and heads each block with when it
    /// started — which is what Messages shows, rather than a time against every line.
    static func rows(_ messages: [Bubble]) -> [ConversationRow] {
        var rows: [ConversationRow] = []
        var previous: Bubble?
        let reporting = messages.lastIndex { !$0.inbound }

        for (index, message) in messages.enumerated() {
            if previous == nil || previous?.inbound != message.inbound {
                rows.append(.time(heading(message)))
            }

            rows.append(.bubble(message, reports: index == reporting))
            previous = message
        }

        return rows
    }

    // MARK: Private

    private static func format(_ template: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate(template)

        return formatter
    }

    /// "Today 7:45 PM", the day in semibold and the time after it — Messages' own shape.
    private static func heading(_ message: Bubble) -> NSAttributedString {
        guard let sent = iso.date(from: message.sentAt) else { return NSAttributedString() }

        let caption = UIFont.preferredFont(forTextStyle: .caption1)
        let text = NSMutableAttributedString(
            string: named(sent),
            attributes: [.font: UIFont.systemFont(ofSize: caption.pointSize, weight: .semibold),
                         .foregroundColor: UIColor.secondaryLabel]
        )
        text.append(NSAttributedString(
            string: " " + clock.string(from: sent),
            attributes: [.font: caption, .foregroundColor: UIColor.secondaryLabel]
        ))

        return text
    }

    private static func named(_ sent: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(sent) { return "Today" }
        if calendar.isDateInYesterday(sent) { return "Yesterday" }

        let week = calendar.date(byAdding: .day, value: -6, to: .now) ?? .now

        return sent > week ? weekday.string(from: sent) : day.string(from: sent)
    }
}
