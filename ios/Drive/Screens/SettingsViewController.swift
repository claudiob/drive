import HotwireNative
import UIKit

/// The Settings tab, shaped like iOS Settings: an account row, then grouped cards whose
/// rows each carry a glyph in a coloured rounded square.
final class SettingsViewController: UITableViewController, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "settings" }

    /// The tints Rails names, as the system colours rather than hexes of our own.
    private static let tints: [String: UIColor] = [
        "blue": .systemBlue, "green": .systemGreen, "gray": .systemGray,
        "indigo": .systemIndigo, "orange": .systemOrange, "red": .systemRed,
    ]

    private let url: URL
    private var page: SettingsPage?

    init(url: URL, navigator: Navigator?) {
        self.url = url

        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(url:navigator:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "setting")

        Task { @MainActor in
            page = await NativeList.fetch(url)
            tableView.reloadData()
        }
    }

    private var account: SettingsPage.Account? { page?.account }

    // MARK: Table

    override func numberOfSections(in table: UITableView) -> Int {
        guard let page else { return 0 }

        return page.groups.count + (account == nil ? 0 : 1)
    }

    override func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let page else { return 0 }
        if account != nil, section == 0 { return 1 }

        return page.groups[section - (account == nil ? 0 : 1)].rows.count
    }

    override func tableView(_ table: UITableView,
                            cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "setting", for: path)
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = nil

        if let account, path.section == 0 {
            var content = cell.defaultContentConfiguration()
            content.text = account.name
            content.secondaryText = account.detail
            content.image = Glyphs.avatar(account.initials, diameter: 60)
            cell.contentConfiguration = content

            return cell
        }

        return configure(cell, with: row(at: path))
    }

    private func row(at path: IndexPath) -> SettingsRow {
        page!.groups[path.section - (account == nil ? 0 : 1)].rows[path.row]
    }

    private func configure(_ cell: UITableViewCell, with row: SettingsRow) -> UITableViewCell {
        var content = cell.defaultContentConfiguration()
        content.text = row.title
        content.image = Glyphs.badge(row.symbol, tint: Self.tints[row.tint] ?? .systemGray)
        cell.contentConfiguration = content

        if let detail = row.detail {
            cell.accessoryView = NativeList.detail(detail)
        }

        return cell
    }
}
