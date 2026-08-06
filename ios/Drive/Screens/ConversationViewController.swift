import HotwireNative
import UIKit

/// A conversation opened from the Messages tab: the same bubbles the compose sheet
/// shows, on a screen of their own with the contact's name in the bar.
final class ConversationViewController: UITableViewController, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "conversation" }

    private let url: URL

    init(url: URL, navigator: Navigator?) {
        self.url = url

        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(url:navigator:) instead.")
    }

    private var messages: [Bubble] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(BubbleCell.self, forCellReuseIdentifier: "bubble")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false

        Task { @MainActor in
            guard let thread: Conversation = await NativeList.fetch(url) else { return }

            navigationItem.title = thread.title
            messages = thread.messages
            tableView.reloadData()
        }
    }

    override func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    override func tableView(_ table: UITableView,
                            cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "bubble", for: path)
        (cell as? BubbleCell)?.show(messages[path.row])

        return cell
    }
}
