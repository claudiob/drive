import UIKit

/// What each tab wants the agent to know about without opening it. Fetched once at
/// launch and hung on the tab bar items in the order the tabs were loaded.
enum Badges {
    private struct Counts: Decodable {
        let jobs: Int
        let messages: Int
        let contacts: Int
    }

    static func apply(to tabs: UITabBarController, from baseURL: URL) {
        Task { @MainActor in
            let url = baseURL.appendingPathComponent("badges.json")

            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let counts = try? JSONDecoder().decode(Counts.self, from: data)
            else { return }

            for (index, count) in [counts.jobs, counts.messages, counts.contacts].enumerated() {
                tabs.tabBar.items?[index].badgeValue = count > 0 ? String(count) : nil
            }
        }
    }
}
