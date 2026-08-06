import UIKit

/// The matches. Both lines are tinted, the way Messages shows a pickable contact, and
/// the given name is weighted apart from the family name as it is in Contacts.
extension ComposeViewController {
    override func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        recipient == nil ? matches.count : rows.count
    }

    override func tableView(_ table: UITableView,
                            cellForRowAt path: IndexPath) -> UITableViewCell {
        if recipient != nil {
            guard case let .bubble(message) = rows[path.row] else {
                let cell = table.dequeueReusableCell(withIdentifier: "time", for: path)
                if case let .time(caption) = rows[path.row] { (cell as? TimeCell)?.show(caption) }

                return cell
            }

            let cell = table.dequeueReusableCell(withIdentifier: "bubble", for: path)
            (cell as? BubbleCell)?.show(message)

            return cell
        }

        let cell = table.dequeueReusableCell(withIdentifier: "match", for: path)
        let contact = matches[path.row]

        var content = cell.defaultContentConfiguration()
        content.attributedText = Self.name(contact, tint: view.tintColor)
        content.secondaryText = NativeList.phone(contact.phone)
        content.secondaryTextProperties.color = view.tintColor
        content.image = Glyphs.avatar(contact.initials)
        content.imageProperties.cornerRadius = 20
        // Messages sits the avatar close to the edge, nearer than a standard row does.
        content.directionalLayoutMargins.leading = 10
        content.imageToTextPadding = 12
        cell.contentConfiguration = content

        return cell
    }

    override func tableView(_ table: UITableView, didSelectRowAt path: IndexPath) {
        table.deselectRow(at: path, animated: true)

        guard recipient == nil else { return }

        choose(matches[path.row])
    }

    /// Picking someone fills the field, locks it, and turns the list into the
    /// conversation with them — all without leaving the sheet.
    func choose(_ contact: ContactCard) {
        recipient = contact
        field.text = contact.name
        field.isLocked = true
        matches = []
        tableView.reloadData()

        Task { @MainActor in
            guard let target = NativeList.url("\(contact.path)/messages", like: url),
                  let thread: Conversation = await NativeList.fetch(target) else { return }

            rows = ConversationRow.rows(thread.messages)
            tableView.reloadData()
            tableView.separatorStyle = .none
        }
    }

    func release() {
        recipient = nil
        rows = []
        field.text = ""
        field.isLocked = false
        tableView.reloadData()
    }

    static func name(_ contact: ContactCard, tint: UIColor) -> NSAttributedString {
        let body = UIFont.preferredFont(forTextStyle: .body)
        let given = NSMutableAttributedString(
            string: contact.first ?? contact.name,
            attributes: [
                .font: UIFont.systemFont(ofSize: body.pointSize, weight: .semibold),
                .foregroundColor: tint,
            ]
        )

        if let last = contact.last, !last.isEmpty {
            given.append(NSAttributedString(string: " " + last,
                                            attributes: [.font: body, .foregroundColor: tint]))
        }

        return given
    }
}
