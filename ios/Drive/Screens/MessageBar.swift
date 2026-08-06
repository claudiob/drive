import UIKit

/// The row that sits under a conversation: a plus, the field itself, and the waveform
/// that records instead of typing — the bar Messages puts at the foot of a thread.
final class MessageBar: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        let add = UIButton(type: .system)
        add.setImage(UIImage(systemName: "plus"), for: .normal)
        add.tintColor = .secondaryLabel
        add.backgroundColor = .secondarySystemFill
        add.layer.cornerRadius = 17
        add.setContentHuggingPriority(.required, for: .horizontal)

        let field = UITextField()
        field.placeholder = "Messages"
        field.font = .preferredFont(forTextStyle: .body)
        field.borderStyle = .none

        let wave = UIButton(type: .system)
        wave.setImage(UIImage(systemName: "waveform"), for: .normal)
        wave.tintColor = .systemOrange
        wave.setContentHuggingPriority(.required, for: .horizontal)

        let entry = UIStackView(arrangedSubviews: [field, wave])
        entry.spacing = 8
        entry.alignment = .center
        entry.isLayoutMarginsRelativeArrangement = true
        entry.directionalLayoutMargins = .init(top: 7, leading: 14, bottom: 7, trailing: 12)
        entry.layer.cornerRadius = 18
        entry.layer.borderWidth = 1
        entry.layer.borderColor = UIColor.separator.cgColor

        let stack = UIStackView(arrangedSubviews: [add, entry])
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            add.widthAnchor.constraint(equalToConstant: 34),
            add.heightAnchor.constraint(equalToConstant: 34),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(frame:) instead.")
    }
}
