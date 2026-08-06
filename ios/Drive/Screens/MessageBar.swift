import UIKit

/// The row that sits under a conversation: a plus, the field itself, and a trailing
/// button that is the waveform while there is nothing to send and the send arrow the
/// moment there is — the swap Messages makes on the first character typed.
final class MessageBar: UIView {
    private let field = UITextField()
    private let trailing = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)

        let add = UIButton(type: .system)
        add.setImage(UIImage(systemName: "plus"), for: .normal)
        add.tintColor = .secondaryLabel
        add.backgroundColor = .secondarySystemFill
        add.layer.cornerRadius = 17
        add.setContentHuggingPriority(.required, for: .horizontal)

        field.placeholder = "Messages"
        field.font = .preferredFont(forTextStyle: .body)
        field.borderStyle = .none
        field.addTarget(self, action: #selector(typed), for: .editingChanged)

        trailing.setContentHuggingPriority(.required, for: .horizontal)

        let entry = UIStackView(arrangedSubviews: [field, trailing])
        entry.spacing = 8
        entry.alignment = .center
        entry.isLayoutMarginsRelativeArrangement = true
        entry.directionalLayoutMargins = .init(top: 7, leading: 14, bottom: 7, trailing: 8)
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

        #if DEBUG
            // Lets a screenshot show the send state without typing into it.
            field.text = ProcessInfo.processInfo.environment["DRIVE_DRAFT"]
        #endif

        typed()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(frame:) instead.")
    }

    /// The waveform records instead of typing, so it only makes sense while nothing has
    /// been typed; once something has, the same place is where you send it from.
    @objc private func typed() {
        let sending = !(field.text ?? "").isEmpty
        let size = UIImage.SymbolConfiguration(pointSize: sending ? 27 : 20)

        trailing.setImage(
            UIImage(systemName: sending ? "arrow.up.circle.fill" : "waveform",
                    withConfiguration: size),
            for: .normal
        )
        trailing.tintColor = sending ? .systemBlue : .systemOrange
    }
}
