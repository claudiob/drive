import UIKit

/// Choosing who the message is to, and letting go of that choice.
extension ComposeViewController {
    /// Ten digits and a Return is a recipient, whether or not anybody by that number is
    /// known: the message is to the number, and a contact for it may not exist yet.
    func accept() {
        let digits = String(field.text.filter(\.isNumber))
        guard digits.count == 10 else { return }

        let known = contacts.first { $0.phone.filter(\.isNumber) == digits }

        choose(known ?? ContactCard(id: 0, name: NativeList.phone(digits), initials: "#",
                                    first: nil, last: nil, phone: digits, path: ""))
    }

    /// Picking someone fills the field, locks it, and turns the list into the
    /// conversation with them — all without leaving the sheet.
    func choose(_ contact: ContactCard) {
        recipient = contact
        field.text = contact.name
        field.isLocked = true
        matches = []
        // There is somebody to send to now, so the bar has something to do.
        bar.isHidden = false
        table.reloadData()

        // A number nobody is known by has no thread to fetch — it starts empty.
        guard !contact.path.isEmpty else { return }

        Task { @MainActor in
            guard let target = NativeList.url("\(contact.path)/messages", like: url),
                  let thread: Conversation = await NativeList.fetch(target) else { return }

            rows = ConversationRow.rows(thread.messages)
            table.reloadData()
        }
    }

    func release() {
        recipient = nil
        rows = []
        field.text = ""
        field.isLocked = false
        bar.isHidden = true
        table.reloadData()
    }
}
