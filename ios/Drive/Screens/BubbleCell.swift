import UIKit

/// One message in a conversation. Heard from the contact it sits left in gray; sent by
/// the agent it sits right in blue, with a muted word under it reporting whether it
/// arrived — the way Messages says it, rather than a mark inside the bubble.
final class BubbleCell: UITableViewCell {
    private let body = UILabel()
    private let status = UILabel()
    private let bubble = UIView()
    private let column = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear

        body.numberOfLines = 0
        body.font = .preferredFont(forTextStyle: .body)
        body.adjustsFontForContentSizeCategory = true
        body.translatesAutoresizingMaskIntoConstraints = false

        bubble.layer.cornerRadius = 18
        bubble.addSubview(body)

        status.font = .preferredFont(forTextStyle: .caption2)
        status.adjustsFontForContentSizeCategory = true
        status.textColor = .secondaryLabel

        // A stack rather than a pair of constraints toggled per side: hiding the status
        // takes its spacing with it, so a message that reports nothing is as tight
        // against the next as one from the contact.
        column.axis = .vertical
        column.spacing = 2
        column.addArrangedSubview(bubble)
        column.addArrangedSubview(status)
        column.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(column)

        NSLayoutConstraint.activate([
            column.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            column.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            column.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            column.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            // A bubble grows with its text but stops well short of the far edge, so the
            // side it is on reads at a glance.
            bubble.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor,
                                          multiplier: 0.75),
            body.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 9),
            body.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -9),
            body.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 14),
            body.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -14)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(style:reuseIdentifier:) instead.")
    }

    /// Where the bubble sits inside the cell, so a context menu can hug it rather than
    /// lifting the whole width of the row.
    var bubbleFrame: CGRect {
        bubble.convert(bubble.bounds, to: self)
    }

    /// `reports` says this is the last message we sent, and so the only one that
    /// carries the word: Messages leaves the ones above it silent.
    func show(_ message: Bubble, reports: Bool) {
        body.text = message.body
        body.textColor = message.inbound ? .label : .white
        bubble.backgroundColor = message.inbound ? .secondarySystemFill : .systemBlue

        // Nothing we received was delivered by us, so only our own side reports.
        status.text = message.delivered ? "Delivered" : "Sent"
        status.isHidden = message.inbound || !reports

        column.alignment = message.inbound ? .leading : .trailing
    }
}
