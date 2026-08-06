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

    /// `valueCell` is the title-left, detail-right style the system lists use, and the
    /// disclosure accessory is the real chevron rather than a glyph of our own.
    let cell = UICollectionView.CellRegistration<UICollectionViewListCell, Job> {
        cell, _, job in
        var content = UIListContentConfiguration.valueCell()
        content.text = job.title
        content.secondaryText = job.city
        content.image = UIImage(systemName: "hammer.fill")
        cell.contentConfiguration = content
        cell.accessories = [.disclosureIndicator()]
    }

    /// The extra-prominent header is the large bold one the App Store uses over each of
    /// its groups; the chevron rides in the text so it follows the words rather than
    /// sitting out at the trailing edge.
    let header = UICollectionView
        .SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { view, _, path in
            var content = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            content.attributedText = JobsViewController.titled(JobsViewController.groups[path.section])
            view.contentConfiguration = content
        }

    init(url: URL, navigator: Navigator?) {
        self.url = url
        self.navigator = navigator

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
