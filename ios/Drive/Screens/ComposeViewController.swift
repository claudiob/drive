import HotwireNative
import UIKit

/// The New Message sheet: a "To:" field over a list of contacts that narrows as you
/// type, matching on either a name or a number. Nothing shows until you type, which is
/// how Messages behaves.
final class ComposeViewController: UITableViewController, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "compose" }

    let url: URL
    weak var navigator: Navigator?
    private var contacts: [ContactCard] = []
    var matches: [ContactCard] = []
    var messages: [Bubble] = []
    var recipient: ContactCard?
    let field = ComposeField()

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

        title = "New Message"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) }
        )

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "match")
        tableView.register(BubbleCell.self, forCellReuseIdentifier: "bubble")
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        field.onChange = { [weak self] query in self?.narrow(to: query) }
        field.onClear = { [weak self] in self?.release() }
        header()

        Task { @MainActor in
            guard let target = NativeList.url("/contacts", like: url),
                  let page: Contacts = await NativeList.fetch(target) else { return }

            contacts = page.sections.flatMap(\.contacts)

            #if DEBUG
                // Lets a screenshot show the narrowed list without typing into it.
                if let query = ProcessInfo.processInfo.environment["DRIVE_QUERY"] {
                    field.text = query
                    narrow(to: query)
                }
            #endif
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        _ = field.becomeFirstResponder()
    }

    private func header() {
        field.frame.size = field.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        tableView.tableHeaderView = field
    }

    /// Matches a name either way round, or a number however it was punctuated.
    private func narrow(to query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        let digits = trimmed.filter(\.isNumber)

        matches = trimmed.isEmpty ? [] : contacts.filter { contact in
            contact.name.localizedCaseInsensitiveContains(trimmed) ||
                (!digits.isEmpty && contact.phone.filter(\.isNumber).contains(digits))
        }

        tableView.reloadData()
    }
}
