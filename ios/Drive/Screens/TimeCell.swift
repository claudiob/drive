import UIKit

/// The centred timestamp that heads a block of messages.
final class TimeCell: UITableViewCell {
    private let caption = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear

        caption.textAlignment = .center
        caption.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(caption)

        NSLayoutConstraint.activate([
            caption.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            caption.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
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
