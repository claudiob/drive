import UIKit

/// The back button on a conversation: a chevron on its own, or a chevron and the number
/// of conversations still unread in a filled circle. Never the word "Messages" — where
/// you came from is obvious, and the count is worth the space instead.
enum BackButton {
    static func item(unread: Int, tint: UIColor, action: UIAction) -> UIBarButtonItem {
        let chevron = UIImageView(image: UIImage(
            systemName: "chevron.backward",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        ))
        chevron.tintColor = tint

        let stack = UIStackView(arrangedSubviews: unread > 0
            ? [chevron, badge(unread, tint: tint)]
            : [chevron])
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        // The button takes the tap; the stack is only how it is laid out.
        stack.isUserInteractionEnabled = false

        let button = UIButton(type: .system, primaryAction: action)
        button.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            stack.topAnchor.constraint(equalTo: button.topAnchor),
            stack.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])

        return UIBarButtonItem(customView: button)
    }

    private static func badge(_ count: Int, tint: UIColor) -> UIView {
        let label = UILabel()
        label.text = String(count)
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.backgroundColor = tint
        label.layer.cornerRadius = 11
        label.clipsToBounds = true

        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 22),
            label.heightAnchor.constraint(equalToConstant: 22)
        ])

        return label
    }
}
