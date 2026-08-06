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

    // Stored, not `static let`: a registration must exist before the callback that
    // dequeues it, and a `static let` is lazy — which UIKit aborts on.
    /// `subtitleCell`, not `valueCell`: the title always leads and the location always
    /// sits under it, muted. `valueCell` lifts the detail up beside a short title and
    /// only drops it below a long one, so rows of mixed lengths never line up.
    let cell = UICollectionView.CellRegistration<UICollectionViewListCell, Job> { cell, _, job in
        var content = UIListContentConfiguration.subtitleCell()
        content.text = job.title
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        content.secondaryText = job.city
        content.secondaryTextProperties.font = .preferredFont(forTextStyle: .subheadline)
        content.secondaryTextProperties.color = .secondaryLabel
        content.textToSecondaryTextVerticalPadding = 3

        // A reserved slot, so the hammer beside a short title and the one beside a
        // long title start in the same place; and room above and below, which is
        // what makes two lines read as one row rather than two.
        content.image = UIImage(
            systemName: "hammer.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 19)
        )
        content.imageProperties.reservedLayoutSize = CGSize(width: 32, height: 32)
        content.imageToTextPadding = 14
        content.directionalLayoutMargins = .init(top: 12, leading: 4, bottom: 12, trailing: 0)

        cell.contentConfiguration = content
        cell.accessories = [.disclosureIndicator()]
    }

    /// The extra-prominent header is the large bold one the App Store uses over each of
    /// its groups; the chevron rides in the text so it follows the words rather than
    /// sitting out at the trailing edge.
    let header = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
        elementKind: UICollectionView.elementKindSectionHeader
    ) { view, _, path in
        var content = UIListContentConfiguration.extraProminentInsetGroupedHeader()
        content.attributedText = titled(JobsViewController.groups[path.section])
        // The header configuration is the inset-grouped one, whose margins assume a
        // card; in a plain list it has to be told to line up with the rows instead.
        content.directionalLayoutMargins = .init(top: 18, leading: 20, bottom: 8, trailing: 20)
        view.contentConfiguration = content
    }

    init(url: URL, navigator: Navigator?) {
        self.url = url
        self.navigator = navigator

        // `.plain`, not `.insetGrouped`: the rows run the full width of the screen.
        var list = UICollectionLayoutListConfiguration(appearance: .plain)
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
