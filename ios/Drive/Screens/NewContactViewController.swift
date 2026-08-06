import HotwireNative
import UIKit

/// The New Contact sheet: Cancel, the title, and an Add that stays disabled until there
/// is enough to save. A homeowner also has an address; a provider does not.
final class NewContactViewController: UITableViewController, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "newContact" }

    let url: URL
    private let kinds = UISegmentedControl(items: ["Homeowner", "Provider"])
    var fields: [UITextField] = []
    var address: Place?

    init(url: URL, navigator: Navigator?) {
        self.url = url

        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(url:navigator:) instead.")
    }

    var homeowner: Bool { kinds.selectedSegmentIndex == 0 }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "New"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) })
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add", style: .done, target: self, action: #selector(add))
        navigationItem.rightBarButtonItem?.isEnabled = false

        fields = ContactField.allCases.map { $0.makeField(target: self, action: #selector(edited)) }
        tableView.register(FieldCell.self, forCellReuseIdentifier: "field")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "address")
        kinds.selectedSegmentIndex = 0
        kinds.addTarget(self, action: #selector(switched), for: .valueChanged)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        fields.first?.becomeFirstResponder()
    }

    func field(_ kind: ContactField) -> UITextField { fields[kind.rawValue] }

    /// The kind switch rides as the first section's header rather than the table's:
    /// a section header is handed its width, while a table header must be given a
    /// frame before it has one, and a zero-width segmented control draws nothing.
    override func tableView(_ table: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }

        let holder = UIView()
        kinds.translatesAutoresizingMaskIntoConstraints = false
        holder.addSubview(kinds)

        NSLayoutConstraint.activate([
            kinds.leadingAnchor.constraint(equalTo: holder.layoutMarginsGuide.leadingAnchor),
            kinds.trailingAnchor.constraint(equalTo: holder.layoutMarginsGuide.trailingAnchor),
            kinds.centerYAnchor.constraint(equalTo: holder.centerYAnchor)
        ])

        return holder
    }

    override func tableView(_ table: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 56 : UITableView.automaticDimension
    }

    @objc private func switched() {
        address = homeowner ? address : nil
        tableView.reloadData()
    }

    /// What the model insists on: ten digits, with neither the area code nor the
    /// exchange starting at 0 or 1. Mirrored here so Add is honest about when it works.
    @objc private func edited() {
        let digits = Array(field(.phone).text?.filter(\.isNumber) ?? "")
        let dialable: ClosedRange<Character> = "2" ... "9"
        let valid = digits.count == 10 && dialable.contains(digits[0]) &&
            dialable.contains(digits[3])

        navigationItem.rightBarButtonItem?.isEnabled = valid
    }

    @objc private func add() {
        Task { @MainActor in
            guard await save() else { return }

            dismiss(animated: true)
        }
    }
}
