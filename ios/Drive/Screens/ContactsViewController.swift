import HotwireNative
import UIKit

/// The contacts list, as Apple's Contacts draws it: an inset-grouped `UITableView`
/// sectioned by letter, with the A–Z scrub index down the right edge and My Card
/// pinned above. The index and the search bar are table-view features — this is why
/// the screen is a table rather than a collection view.
final class ContactsViewController: UITableViewController, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "contacts" }

    let url: URL
    weak var navigator: Navigator?
    var sections: [ContactSection] = []
    var myCard: ContactCard?
    var query = ""

    init(url: URL, navigator: Navigator?) {
        self.url = url
        self.navigator = navigator

        // `.plain`, not inset cards: Contacts runs its rows edge to edge under sticky
        // letter headers.
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(url:navigator:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "contact")
        tableView.sectionIndexColor = view.tintColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [weak self] _ in self?.route("/contacts/new") }
        )
        refreshControl = UIRefreshControl(frame: .zero,
                                          primaryAction: UIAction { [weak self] _ in self?.load() })

        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false

        load()
    }

    // MARK: Data

    var listed: [ContactSection] {
        guard !query.isEmpty else { return sections }

        return sections.compactMap { section in
            let hits = section.contacts.filter {
                $0.name.localizedCaseInsensitiveContains(query)
            }
            return hits.isEmpty ? nil : ContactSection(title: section.title, contacts: hits)
        }
    }

    private func load() {
        Task { @MainActor in
            defer { refreshControl?.endRefreshing() }

            guard let page: Contacts = await NativeList.fetch(url) else { return }

            myCard = page.myCard
            sections = page.sections
            navigationItem.title = "Contacts"
            tableView.reloadData()
        }
    }

    func card(at path: IndexPath) -> ContactCard? {
        if myCard != nil, path.section == 0 { return myCard }

        let offset = myCard == nil ? 0 : 1
        return listed[path.section - offset].contacts[path.row]
    }

    /// Pushes a Rails path onto this tab's stack, through the navigator that proposed
    /// this screen — so the detail page is still a web view.
    func route(_ path: String) {
        guard let target = NativeList.url(path, like: url) else { return }

        navigator?.route(target)
    }
}
