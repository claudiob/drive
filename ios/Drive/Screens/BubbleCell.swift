import UIKit

/// One message in a conversation. Heard from the contact it sits left in grey; sent by
/// the agent it sits right in blue — the two sides Messages draws.
final class BubbleCell: UITableViewCell {
    private let body = UILabel()
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
        body.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(body)

        leading = bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailing = bubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -16)

        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            // A bubble grows with its text but stops well short of the far edge, so the
            // side it is on stays readable at a glance.
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

    func show(_ message: Bubble) {
        body.text = message.body
        body.textColor = message.inbound ? .label : .white
        bubble.backgroundColor = message.inbound ? .secondarySystemFill : .systemBlue

        leading.isActive = message.inbound
        trailing.isActive = !message.inbound
    }
}
