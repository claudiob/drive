import Foundation

/// One conversation on the Messages tab.
struct Thread: Decodable, Hashable {
    let id: Int
    let author: String
    let initials: String
    let preview: String
    let date: String
    let unread: Bool
    let path: String
    let readPath: String
}

/// One row of the Settings screen.
struct SettingsRow: Decodable, Hashable {
    let title: String
    let symbol: String
    let tint: String
    let detail: String?
}

/// What `/settings.json` answers.
struct SettingsPage: Decodable {
    struct Account: Decodable {
        let name: String
        let detail: String
        let initials: String
    }

    struct Group: Decodable {
        let rows: [SettingsRow]
    }

    let account: Account?
    let groups: [Group]
}

/// One message in a conversation.
struct Bubble: Decodable, Hashable {
    let id: Int
    let body: String
    let inbound: Bool
    let time: String
}

/// What `/contacts/:id/messages.json` answers.
struct Conversation: Decodable {
    let title: String
    let unread: Int
    let messages: [Bubble]
}

/// One address suggestion.
struct Place: Decodable, Hashable {
    let id: String
    let title: String
    let detail: String?
}

/// What `/places.json` answers.
struct Places: Decodable {
    let predictions: [Place]
}
