import Foundation

/// One row of `/jobs.json`. The native list asks Rails for the data rather than the
/// markup, so the screen can be drawn with UIKit's own components.
struct Job: Decodable, Hashable {
    let id: Int
    let title: String
    let status: String
    let city: String
    let path: String
    /// Named by the model, in SF Symbols, so the app holds no list of its own.
    let icon: String
}

/// What `/jobs.json` answers: the two groups the board shows.
struct JobBoard: Decodable {
    let attention: [Job]
    let claimed: [Job]
}
