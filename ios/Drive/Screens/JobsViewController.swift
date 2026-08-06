import HotwireNative
import UIKit

/// The Jobs list, drawn with the same UIKit components Apple's Contacts list uses: an
/// inset-grouped `UICollectionView` list layout and `UIListContentConfiguration`. No
/// HTML imitating them, so the cells, separators, insets, highlight and swipe physics
/// are the system's own.
final class JobsViewController: UICollectionViewController, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "jobs" }

    private let url: URL
    private weak var navigator: Navigator?
    private var jobs: [Job] = []

    init(url: URL, navigator: Navigator?) {
        self.url = url
        self.navigator = navigator

        var list = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        list.showsSeparators = true

        super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: list))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(url:navigator:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Jobs"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [weak self] _ in self?.route("jobs/new") }
        )

        collectionView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction { [weak self] _ in self?.load() }
        )

        load()
    }

    // MARK: Data

    // Eager, not lazy: a lazy one would be built the first time a cell is asked for,
    // which is inside `cellForItemAt`, and UIKit rejects that outright — a registration
    // made per cell would defeat reuse.
    private let registration = UICollectionView.CellRegistration<UICollectionViewListCell, Job> {
        cell, _, job in
        // `valueCell` is the title-left, detail-right style the Settings and Contacts
        // lists use; the disclosure accessory is the system chevron, not a glyph.
        var content = UIListContentConfiguration.valueCell()
        content.text = job.title
        content.secondaryText = job.city
        content.image = UIImage(systemName: "hammer.fill")
        cell.contentConfiguration = content
        cell.accessories = [.disclosureIndicator()]
    }

    private func load() {
        Task { @MainActor in
            defer { collectionView.refreshControl?.endRefreshing() }

            // The screen is routed at /jobs; the data for it is /jobs.json.
            let source = url.appendingPathExtension("json")

            guard let (data, _) = try? await URLSession.shared.data(from: source),
                  let jobs = try? JSONDecoder().decode([Job].self, from: data)
            else { return }

            self.jobs = jobs
            collectionView.reloadData()
        }
    }

    private func route(_ path: String) {
        navigator?.route(url.deletingLastPathComponent().appendingPathComponent(path))
    }

    // MARK: UICollectionView

    override func collectionView(_ view: UICollectionView, numberOfItemsInSection: Int) -> Int {
        jobs.count
    }

    override func collectionView(_ view: UICollectionView,
                                 cellForItemAt path: IndexPath) -> UICollectionViewCell {
        view.dequeueConfiguredReusableCell(using: registration, for: path, item: jobs[path.item])
    }

    override func collectionView(_ view: UICollectionView, didSelectItemAt path: IndexPath) {
        view.deselectItem(at: path, animated: true)
        route(String(jobs[path.item].path.dropFirst()))
    }
}
