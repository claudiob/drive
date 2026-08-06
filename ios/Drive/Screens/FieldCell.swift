import UIKit

/// A row that is nothing but a text field. The field is owned by the screen rather than
/// the cell, so its value survives the cell being reused.
final class FieldCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(style:reuseIdentifier:) instead.")
    }

    func adopt(_ field: UITextField) {
        guard field.superview != contentView else { return }

        contentView.subviews.forEach { $0.removeFromSuperview() }
        field.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(field)

        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            field.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            field.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11),
            field.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11)
        ])
    }
}
