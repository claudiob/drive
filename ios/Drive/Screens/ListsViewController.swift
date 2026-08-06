import HotwireNative
import UIKit

/// The Contacts tab's first screen: All Contacts on its own card, then the smart lists
/// under a header. An inset-grouped table, which is what the same screen is in Contacts.
final class ListsViewController: UITableViewController, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "lists" }

    private let url: URL
    private weak var navigator: Navigator?
    private var lists: Lists?

    init(url: URL, navigator: Navigator?) {
        self.url = url
        self.navigator = navigator

        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(url:navigator:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // `navigationItem.title`, not `title`: the latter renames the tab too, and
        // the tab is Contacts.
        navigationItem.title = "Lists"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "list")

        Task { @MainActor in
            lists = await NativeList.fetch(url)
            tableView.reloadData()
        }
    }

    private func row(at path: IndexPath) -> SmartList? {
        guard let lists else { return nil }

        return path.section == 0 ? lists.all : lists.smart[path.row]
    }

    // MARK: Table

    override func numberOfSections(in table: UITableView) -> Int {
        lists == nil ? 0 : 2
    }

    override func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : lists?.smart.count ?? 0
    }

    override func tableView(_ table: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 ? "Smart lists" : nil
    }

    override func tableView(_ table: UITableView,
                            cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "list", for: path)
        guard let row = row(at: path) else { return cell }

        var content = cell.defaultContentConfiguration()
        content.text = row.title
        // Only the All Contacts row carries an icon; the dot on "Unread messages" takes
        // the same slot, which is what lines the two up.
        content.image = if path.section == 0 {
            Glyphs.leading("person.2.fill")
        } else if row.dot == true {
            Glyphs.dot
        } else {
            Glyphs.leading(nil)
        }
        cell.contentConfiguration = content

        if let count = row.count {
            cell.accessoryView = NativeList.detail(String(count))
        } else {
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    override func tableView(_ table: UITableView, didSelectRowAt path: IndexPath) {
        table.deselectRow(at: path, animated: true)

        guard let row = row(at: path),
              let target = NativeList.url(row.path, like: url) else { return }

        navigator?.route(target)
    }
}
