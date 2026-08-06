import HotwireNative
import UIKit

/// A conversation opened from the Messages tab: bubbles above, the message bar below.
/// Not a `UITableViewController`, because that owns the whole view and leaves nowhere
/// to pin the bar.
final class ConversationViewController: UIViewController, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "conversation" }

    private let url: URL
    private let table = UITableView(frame: .zero, style: .plain)
    private let bar = MessageBar()
    var rows: [ConversationRow] = []

    init(url: URL, navigator: Navigator?) {
        self.url = url

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(url:navigator:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "video"), primaryAction: UIAction { _ in })

        lay()
        load()
    }

    private func lay() {
        table.dataSource = self
        table.delegate = self
        table.register(BubbleCell.self, forCellReuseIdentifier: "bubble")
        table.register(TimeCell.self, forCellReuseIdentifier: "time")
        table.separatorStyle = .none
        table.allowsSelection = false
        table.keyboardDismissMode = .interactive

        for child in [table, bar] {
            child.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(child)
        }

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: bar.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // The keyboard guide sits at the safe area while the keyboard is down, so
            // one constraint covers both states.
            bar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }

    /// Seeing a conversation is reading it. Marked before the thread is fetched, so the
    /// count the back button shows already excludes this one.
    private func markRead() async {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        components.path = components.path.replacingOccurrences(of: "/messages", with: "/read")

        guard let target = components.url else { return }

        var request = URLRequest(url: target)
        request.httpMethod = "POST"
        _ = try? await URLSession.shared.data(for: request)
    }

    private func load() {
        Task { @MainActor in
            await markRead()

            guard let thread: Conversation = await NativeList.fetch(url) else { return }

            navigationItem.title = thread.title
            navigationItem.leftBarButtonItem = BackButton.item(
                unread: thread.unread,
                tint: view.tintColor,
                action: UIAction { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
            )

            rows = ConversationRow.rows(thread.messages)
            table.reloadData()
        }
    }
}
