import UIKit

/// What every native screen here shares: where its data comes from, and how initials
/// are drawn when a contact has no picture.
enum NativeList {
    /// The screen is routed at a path; the data for it is that path with `.json` on the
    /// end. Built through components so a query string like `?list=claimed` survives.
    static func source(_ url: URL) -> URL {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path += ".json"

        return components.url!
    }

    /// A path from the Rails app resolved against the screen it came from. Relative
    /// resolution, so `/contacts?list=unread` keeps its query and drops the old one.
    static func url(_ path: String, like url: URL) -> URL? {
        URL(string: path, relativeTo: url)?.absoluteURL
    }

    /// `+1 (585) 384-2934`, which is how iOS writes a number. The web writes
    /// `585-384-2934` and keeps its own rule; this formatting is the app's alone.
    static func phone(_ text: String) -> String {
        let digits = text.filter(\.isNumber)
        guard digits.count == 10 else { return text }

        let area = digits.prefix(3)
        let exchange = digits.dropFirst(3).prefix(3)
        let line = digits.suffix(4)

        return "+1 (\(area)) \(exchange)-\(line)"
    }

    /// Trailing text followed by a chevron. A cell draws `accessoryView` or
    /// `accessoryType`, never both, so rows that need each supply the pair themselves.
    static func detail(_ text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .tertiaryLabel

        let stack = UIStackView(arrangedSubviews: [label, chevron])
        stack.spacing = 6
        stack.alignment = .center
        stack.frame.size = stack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        return stack
    }

    static func fetch<T: Decodable>(_ url: URL) async -> T? {
        guard let (data, _) = try? await URLSession.shared.data(from: source(url)) else {
            return nil
        }

        return try? JSONDecoder().decode(T.self, from: data)
    }

}
