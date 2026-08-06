import HotwireNative
import UIKit

/// The New Message sheet: a "To:" field over a list of contacts that narrows as you
/// type, matching on either a name or a number. Nothing shows until you type, which is
/// how Messages behaves.
///
/// A plain view controller rather than a `UITableViewController`, because that class
/// owns its whole view and leaves nowhere to put the message bar underneath.
final class ComposeViewController: UIViewController, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "compose" }

    let url: URL
    weak var navigator: Navigator?
    var contacts: [ContactCard] = []
    var matches: [ContactCard] = []
    var rows: [ConversationRow] = []
    var recipient: ContactCard?
    let field = ComposeField()
    let table = UITableView(frame: .zero, style: .plain)
    let bar = MessageBar()

    init(url: URL, navigator: Navigator?) {
        self.url = url
        self.navigator = navigator

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(url:navigator:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "New Message"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) }
        )

        field.onChange = { [weak self] query in self?.narrow(to: query) }
        field.onClear = { [weak self] in self?.release() }
        field.onSubmit = { [weak self] in self?.accept() }

        lay()
        load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        _ = field.becomeFirstResponder()
    }

    /// The bar shows only once there is somebody to send to, and a stack is what lets
    /// hiding it reclaim the space — a hidden view keeps its constraints anywhere else.
    private func lay() {
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "match")
        table.register(BubbleCell.self, forCellReuseIdentifier: "bubble")
        table.register(TimeCell.self, forCellReuseIdentifier: "time")
        table.separatorStyle = .none
        table.keyboardDismissMode = .interactive
        header()

        bar.isHidden = true

        let stack = UIStackView(arrangedSubviews: [table, bar])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // The keyboard guide sits at the safe area while the keyboard is down, so
            // one constraint covers both states.
            stack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }

    private func header() {
        field.frame.size = field.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        table.tableHeaderView = field
    }

    private func load() {
        Task { @MainActor in
            guard let target = NativeList.url("/contacts", like: url),
                  let page: Contacts = await NativeList.fetch(target) else { return }

            contacts = page.sections.flatMap(\.contacts)

            #if DEBUG
                // Lets a screenshot show the narrowed list without typing into it.
                if let query = ProcessInfo.processInfo.environment["DRIVE_QUERY"] {
                    field.text = query
                    narrow(to: query)

                    if ProcessInfo.processInfo.environment["DRIVE_RETURN"] != nil { accept() }
                }
            #endif
        }
    }

    /// Matches a name either way round, or a number however it was punctuated.
    private func narrow(to query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        let digits = trimmed.filter(\.isNumber)

        matches = trimmed.isEmpty ? [] : contacts.filter { contact in
            contact.name.localizedCaseInsensitiveContains(trimmed) ||
                (!digits.isEmpty && contact.phone.filter(\.isNumber).contains(digits))
        }

        table.reloadData()
    }
}
