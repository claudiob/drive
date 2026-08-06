import UIKit

/// Address autocomplete, as the second screen of the New Contact sheet. The suggestions
/// come from Google, but through Rails: the key stays on the server, where it can be
/// rotated without shipping a build.
final class AddressSearchViewController: UITableViewController, UISearchBarDelegate {
    private let url: URL
    private let chose: (Place) -> Void
    private let search = UISearchBar()
    private var places: [Place] = []
    private var typing: Task<Void, Never>?

    init(url: URL, chose: @escaping (Place) -> Void) {
        self.url = url
        self.chose = chose

        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(url:chose:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Address"
        search.placeholder = "Search here"
        search.delegate = self
        search.searchBarStyle = .minimal
        search.autocapitalizationType = .words
        navigationItem.titleView = search

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "place")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        search.becomeFirstResponder()
    }

    func searchBar(_ bar: UISearchBar, textDidChange text: String) {
        // One request per pause, not per keystroke: the previous task is cancelled
        // before the next is given time to start.
        typing?.cancel()
        typing = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }

            await suggest(text)
        }
    }

    private func suggest(_ text: String) async {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        components.path = "/places.json"
        components.queryItems = [URLQueryItem(name: "q", value: text)]

        guard let target = components.url,
              let (data, _) = try? await URLSession.shared.data(from: target),
              let page = try? JSONDecoder().decode(Places.self, from: data)
        else { return }

        places = page.predictions
        tableView.reloadData()
    }

    override func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }

    override func tableView(_ table: UITableView,
                            cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "place", for: path)
        let place = places[path.row]

        var content = cell.defaultContentConfiguration()
        content.text = place.title
        content.secondaryText = place.detail
        content.image = UIImage(systemName: "mappin.circle.fill")
        content.imageProperties.tintColor = .secondaryLabel
        cell.contentConfiguration = content

        return cell
    }

    override func tableView(_ table: UITableView, didSelectRowAt path: IndexPath) {
        chose(places[path.row])
        navigationController?.popViewController(animated: true)
    }
}
