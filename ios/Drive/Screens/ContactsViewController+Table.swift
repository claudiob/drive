import UIKit

/// The table itself. Split from the controller only to keep either file readable.
extension ContactsViewController {
    /// My Card takes a section of its own above the letters, the way Contacts shows it.
    private var offset: Int { myCard == nil ? 0 : 1 }

    override func numberOfSections(in tableView: UITableView) -> Int {
        listed.count + offset
    }

    override func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        section < offset ? 1 : listed[section - offset].contacts.count
    }

    override func tableView(_ table: UITableView, titleForHeaderInSection section: Int) -> String? {
        section < offset ? nil : listed[section - offset].title
    }

    override func tableView(_ table: UITableView,
                            cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "contact", for: path)
        guard let contact = card(at: path) else { return cell }

        var content = cell.defaultContentConfiguration()
        content.attributedText = Self.name(contact)
        content.secondaryText = path.section < offset ? "My Card" : nil
        cell.contentConfiguration = content
        cell.accessoryType = .none

        return cell
    }

    /// The A–Z scrub strip. A table view draws and tracks it; there is no collection
    /// view equivalent, which is why this screen is a table.
    override func sectionIndexTitles(for table: UITableView) -> [String]? {
        query.isEmpty ? listed.map(\.title) : nil
    }

    override func tableView(_ table: UITableView,
                            sectionForSectionIndexTitle title: String,
                            at index: Int) -> Int {
        index + offset
    }

    override func tableView(_ table: UITableView, didSelectRowAt path: IndexPath) {
        table.deselectRow(at: path, animated: true)

        guard let contact = card(at: path) else { return }

        route(contact.path)
    }
}

private extension ContactsViewController {
    /// Given name in semibold, family name regular — one label, two weights, which is
    /// what Contacts shows and what a plain `text` cannot express.
    static func name(_ contact: ContactCard) -> NSAttributedString {
        let body = UIFont.preferredFont(forTextStyle: .body)
        let given = NSMutableAttributedString(
            string: contact.first ?? contact.name,
            attributes: [.font: UIFont.systemFont(ofSize: body.pointSize, weight: .semibold)])

        if let last = contact.last, !last.isEmpty {
            given.append(NSAttributedString(string: " " + last, attributes: [.font: body]))
        }

        return given
    }
}

extension ContactsViewController: UISearchResultsUpdating {
    func updateSearchResults(for controller: UISearchController) {
        query = controller.searchBar.text ?? ""
        tableView.reloadData()
    }
}
