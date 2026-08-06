import UIKit

/// The centered timestamp that heads a block of messages.
///
/// A hand-built label rather than a `UIListContentConfiguration`, deliberately: the
/// heading is "Today" in semibold followed by the time in regular, and a content
/// configuration takes a `String` and one font, so moving to one would cost the two
/// weights Messages actually shows. What the system does supply, and what this now takes
/// from it, is the horizontal inset — the cell's own layout margins rather than a 16 of
/// mine. The type is already `.caption1` at `.secondaryLabel`, built in `ConversationRow`.
final class TimeCell: UITableViewCell {
    private let caption = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear

        caption.textAlignment = .center
        caption.numberOfLines = 0
        caption.adjustsFontForContentSizeCategory = true
        caption.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(caption)

        let margins = contentView.layoutMarginsGuide

        NSLayoutConstraint.activate([
            caption.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            caption.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            caption.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            caption.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(style:reuseIdentifier:) instead.")
    }

    func show(_ text: NSAttributedString) {
        caption.attributedText = text
    }
}
