import Foundation

/// A row on the Contacts tab's first screen.
struct SmartList: Decodable, Hashable {
    let title: String
    let count: Int?
    let dot: Bool?
    let path: String
}

/// What `/lists.json` answers.
struct Lists: Decodable {
    let all: SmartList
    let smart: [SmartList]
}

/// One contact in the alphabetical list.
struct ContactCard: Decodable, Hashable {
    let id: Int
    let name: String
    let initials: String
    /// Kept apart so the list can weight the given name and the family name
    /// differently, the way Contacts does.
    let first: String?
    let last: String?
    let phone: String
    let path: String
}

/// One letter's worth of contacts.
struct ContactSection: Decodable {
    let title: String
    let contacts: [ContactCard]
}

/// What `/contacts.json` answers.
struct Contacts: Decodable {
    let myCard: ContactCard?
    let sections: [ContactSection]
}

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
    let messages: [Bubble]
}
