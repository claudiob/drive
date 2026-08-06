import UIKit

/// Pressing a bubble opens the system context menu over it, as Messages does: the
/// bubble lifts, what is behind it blurs, and the Tapbacks and actions are a real
/// `UIMenu`. All of it is UIKit's — the only thing added is the tap of feedback.
extension ConversationViewController: UITableViewDelegate {
    /// The Tapback row: an inline menu of small elements is what draws icons in a strip
    /// rather than as a list, which is the shape Messages uses.
    private static let tapbacks = ["heart", "hand.thumbsup", "hand.thumbsdown",
                                   "face.smiling", "exclamationmark.2", "questionmark"]

    func tableView(_ table: UITableView,
                   contextMenuConfigurationForRowAt path: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        guard case let .bubble(message, _) = rows[path.row] else { return nil }

        return UIContextMenuConfiguration(identifier: path as NSCopying) { _ in
            UIMenu(children: [Self.tapbackMenu, Self.actions(for: message)])
        }
    }

    func tableView(_ table: UITableView,
                   willDisplayContextMenu configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionAnimating?) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func tableView(_ table: UITableView,
                   previewForHighlightingContextMenuWithConfiguration
                       configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        preview(for: configuration, in: table)
    }

    func tableView(_ table: UITableView,
                   previewForDismissingContextMenuWithConfiguration
                       configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        preview(for: configuration, in: table)
    }

    // MARK: Private

    private static var tapbackMenu: UIMenu {
        UIMenu(options: .displayInline, preferredElementSize: .small,
               children: tapbacks.map { symbol in
                   UIAction(title: symbol, image: UIImage(systemName: symbol)) { _ in }
               })
    }

    private static func actions(for message: Bubble) -> UIMenu {
        UIMenu(options: .displayInline, children: [
            UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                UIPasteboard.general.string = message.body
            },
            UIAction(title: "Reply", image: UIImage(systemName: "arrowshape.turn.up.left")) { _ in },
            UIAction(title: "Delete", image: UIImage(systemName: "trash"),
                     attributes: .destructive) { _ in }
        ])
    }

    /// Hugging the bubble, not the row: a preview of the cell with everything outside
    /// the bubble's rounded rectangle clipped away.
    private func preview(for configuration: UIContextMenuConfiguration,
                         in table: UITableView) -> UITargetedPreview? {
        guard let path = configuration.identifier as? IndexPath,
              let cell = table.cellForRow(at: path) as? BubbleCell
        else { return nil }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: cell.bubbleFrame, cornerRadius: 18)

        return UITargetedPreview(view: cell, parameters: parameters)
    }
}
