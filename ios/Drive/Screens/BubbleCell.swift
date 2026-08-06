import UIKit

/// One message in a conversation. Heard from the contact it sits left in grey; sent by
/// the agent it sits right in blue, with a tick reporting whether it arrived.
final class BubbleCell: UITableViewCell {
    private let body = UILabel()
    private let tick = UIImageView()
    private let bubble = UIView()
    private var leading: NSLayoutConstraint!
    private var trailing: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear

        bubble.layer.cornerRadius = 18
        bubble.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubble)

        body.numberOfLines = 0
        body.font = .preferredFont(forTextStyle: .body)

        tick.image = UIImage(systemName: "checkmark",
                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 10))
        tick.setContentHuggingPriority(.required, for: .horizontal)

        // Bottom-aligned, so the tick sits on the last line of a message of any height.
        let stack = UIStackView(arrangedSubviews: [body, tick])
        stack.spacing = 5
        stack.alignment = .bottom
        stack.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(stack)

        leading = bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailing = bubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -16)

        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            // A bubble grows with its text but stops well short of the far edge, so the
            // side it is on reads at a glance.
            bubble.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor,
                                          multiplier: 0.75),
            stack.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 9),
            stack.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -9),
            stack.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -14)
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

    func show(_ message: Bubble) {
        body.text = message.body
        body.textColor = message.inbound ? .label : .white
        bubble.backgroundColor = message.inbound ? .secondarySystemFill : .systemBlue

        // Nothing we received was delivered by us, so only our own side reports.
        tick.isHidden = message.inbound
        tick.tintColor = message.delivered ? .systemGreen : UIColor.white.withAlphaComponent(0.6)

        leading.isActive = message.inbound
        trailing.isActive = !message.inbound
    }
}
