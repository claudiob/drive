import HotwireNative
import UIKit

/// The Jobs board: what needs looking at, then what the agent has claimed, under a
/// large title and a search field. Two inset-grouped list sections in a compositional
/// layout, which is the shape the App Store gives its own Search tab.
final class JobsViewController: UICollectionViewController, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "jobs" }

    /// Section titles, in the order they are shown.
    static let groups = ["Need your attention", "Claimed by you"]

    let url: URL
    weak var navigator: Navigator?
    var jobs: [[Job]] = [[], []]

    // Built here rather than declared inline: a registration must exist before the
    // callback that dequeues it, and UIKit aborts on one made lazily inside it.
    let cell: UICollectionView.CellRegistration<UICollectionViewListCell, Job>
    let header: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>

    init(url: URL, navigator: Navigator?) {
        self.url = url
        self.navigator = navigator
        cell = Self.makeCell()
        header = Self.makeHeader()

        var list = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        list.headerMode = .supplementary

        super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: list))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(url:navigator:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Jobs"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [weak self] _ in self?.route("/jobs/new") })

        let search = UISearchController(searchResultsController: nil)
        search.searchBar.placeholder = "Search"
        search.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false

        collectionView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction { [weak self] _ in self?.load() })

        load()
    }

    func route(_ path: String) {
        guard let target = NativeList.url(path, like: url) else { return }

        navigator?.route(target)
    }

    private func load() {
        Task { @MainActor in
            defer { collectionView.refreshControl?.endRefreshing() }

            guard let board: JobBoard = await NativeList.fetch(url) else { return }

            jobs = [board.attention, board.claimed]
            collectionView.reloadData()
        }
    }
}
