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
