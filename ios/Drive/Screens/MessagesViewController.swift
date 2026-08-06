import HotwireNative
import UIKit

/// The conversation list, as Apple's Messages draws it: avatar, author, a two-line
/// preview, the date, and a blue dot while unread. Swiping a row toggles read — a real
/// `UISwipeActionsConfiguration`, so the rubber-band and the snap are the system's.
final class MessagesViewController: UITableViewController, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "messages" }

    let url: URL
    weak var navigator: Navigator?
    var threads: [Thread] = []

    init(url: URL, navigator: Navigator?) {
        self.url = url
        self.navigator = navigator

        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(url:navigator:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Messages"
        // The big title under the bar, with Edit and the compose glyph beside it —
        // which is how Messages is laid out on this version of iOS.
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            primaryAction: UIAction { [weak self] _ in self?.compose() }
        )

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "thread")
        refreshControl = UIRefreshControl(frame: .zero,
                                          primaryAction: UIAction { [weak self] _ in self?.load() })
        load()
    }

    private func compose() {
        guard let target = NativeList.url("/messages/new", like: url) else { return }

        navigator?.route(target)
    }

    func load() {
        Task { @MainActor in
            defer { refreshControl?.endRefreshing() }

            guard let threads: [Thread] = await NativeList.fetch(url) else { return }

            self.threads = threads
            tableView.reloadData()
        }
    }

    // MARK: Table

    override func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        threads.count
    }

    override func tableView(_ table: UITableView,
                            cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "thread", for: path)
        let thread = threads[path.item]

        var content = cell.defaultContentConfiguration()
        content.text = thread.author
        content.secondaryText = thread.preview
        content.secondaryTextProperties.numberOfLines = 2
        content.secondaryTextProperties.color = .secondaryLabel
        content.image = Glyphs.avatar(thread.initials, diameter: 52, unread: thread.unread)
        cell.contentConfiguration = content

        // A custom accessory, because Messages shows the date *and* a chevron and a
        // cell will draw one or the other, never both.
        cell.accessoryView = NativeList.detail(thread.date)

        return cell
    }

    override func tableView(_ table: UITableView, didSelectRowAt path: IndexPath) {
        table.deselectRow(at: path, animated: true)

        guard let target = NativeList.url(threads[path.item].path, like: url) else { return }

        navigator?.route(target)
    }
}
