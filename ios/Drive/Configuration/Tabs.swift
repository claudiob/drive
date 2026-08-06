import HotwireNative
import UIKit

extension HotwireTab {
    /// The four tabs, in the order the tab bar shows them. Each owns its own navigation
    /// stack, and each starts at a path the Rails app answers with a native template.
    static func all(baseURL: URL) -> [HotwireTab] {
        [
            tab("Jobs", symbol: "briefcase", path: "jobs", baseURL: baseURL),
            tab("Messages", symbol: "message", path: "messages", baseURL: baseURL),
            // The Contacts tab opens on the lists, the way Apple's Contacts does.
            tab("Contacts", symbol: "person.crop.circle", path: "lists", baseURL: baseURL),
            tab("Settings", symbol: "gearshape", path: "settings", baseURL: baseURL)
        ]
    }

    private static func tab(_ title: String,
                            symbol: String,
                            path: String,
                            baseURL: URL) -> HotwireTab {
        HotwireTab(
            title: title,
            image: UIImage(systemName: symbol)!,
            selectedImage: UIImage(systemName: "\(symbol).fill"),
            url: baseURL.appendingPathComponent(path)
        )
    }
}
