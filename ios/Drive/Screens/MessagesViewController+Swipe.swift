import UIKit

/// Swiping a conversation toggles whether it has been read. A real
/// `UISwipeActionsConfiguration`, so the reveal, the rubber-band and the snap-back are
/// the system's own — none of which a web view could be made to imitate honestly.
extension MessagesViewController {
    override func tableView(
        _ table: UITableView,
        leadingSwipeActionsConfigurationForRowAt path: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let thread = threads[path.item]

        let action = UIContextualAction(
            style: .normal,
            title: thread.unread ? "Read" : "Unread"
        ) { [weak self] _, _, done in
            self?.toggleRead(thread)
            done(true)
        }

        action.image = UIImage(
            systemName: thread.unread ? "envelope.open.fill" : "envelope.badge.fill")
        action.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [action])
    }

    /// `POST` marks the whole thread read, `DELETE` puts the newest message back to
    /// unread — the nested `read` resource, rather than an action on messages.
    private func toggleRead(_ thread: Thread) {
        guard let target = NativeList.url(thread.readPath, like: url) else { return }

        var request = URLRequest(url: target)
        request.httpMethod = thread.unread ? "POST" : "DELETE"

        Task { @MainActor in
            _ = try? await URLSession.shared.data(for: request)
            load()
        }
    }
}
