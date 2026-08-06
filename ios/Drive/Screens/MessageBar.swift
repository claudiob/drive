import UIKit

/// The row that sits under a conversation: a plus, the field itself, and a trailing
/// button that is the waveform while there is nothing to send and the send arrow the
/// moment there is — the swap Messages makes on the first character typed.
///
/// A `UIInputView` in the keyboard style, so the background is the material UIKit gives
/// anything that sits against the keyboard rather than a color picked here, and the field
/// is a `UITextView` with scrolling off, which is how a compose box grows a line at a time
/// instead of scrolling a single line sideways.
final class MessageBar: UIInputView {
    /// Five or so lines, after which it scrolls rather than eating the conversation.
    private static let tallest = 120.0

    private let field = UITextView()
    private let placeholder = UILabel()
    private let trailing = UIButton(type: .system)

    init() {
        super.init(frame: .zero, inputViewStyle: .keyboard)

        allowsSelfSizing = true

        let add = UIButton(type: .system)
        add.setImage(UIImage(systemName: "plus"), for: .normal)
        add.tintColor = .secondaryLabel
        add.backgroundColor = .secondarySystemFill
        add.layer.cornerRadius = 17
        add.setContentHuggingPriority(.required, for: .horizontal)

        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.backgroundColor = .clear
        field.isScrollEnabled = false
        // A text view insets its text by default and a text field does not, so without
        // these the placeholder and the typed line would not sit where the caret does.
        field.textContainerInset = .zero
        field.textContainer.lineFragmentPadding = 0
        field.delegate = self

        // A text view has no placeholder of its own, which is the one part of a compose
        // box UIKit leaves to the caller.
        placeholder.text = "Messages"
        placeholder.font = .preferredFont(forTextStyle: .body)
        placeholder.adjustsFontForContentSizeCategory = true
        placeholder.textColor = .placeholderText
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        field.addSubview(placeholder)

        trailing.setContentHuggingPriority(.required, for: .horizontal)

        let entry = UIStackView(arrangedSubviews: [field, trailing])
        entry.spacing = 8
        entry.alignment = .bottom
        entry.isLayoutMarginsRelativeArrangement = true
        entry.directionalLayoutMargins = .init(top: 7, leading: 14, bottom: 7, trailing: 8)
        entry.layer.cornerRadius = 18
        entry.layer.borderWidth = 1
        entry.layer.borderColor = UIColor.separator.cgColor

        let stack = UIStackView(arrangedSubviews: [add, entry])
        stack.spacing = 8
        stack.alignment = .bottom
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            add.widthAnchor.constraint(equalToConstant: 34),
            add.heightAnchor.constraint(equalToConstant: 34),
            field.heightAnchor.constraint(lessThanOrEqualToConstant: Self.tallest),
            placeholder.leadingAnchor.constraint(equalTo: field.leadingAnchor),
            placeholder.topAnchor.constraint(equalTo: field.topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])

        #if DEBUG
            // Lets a screenshot show the send state without typing into it.
            field.text = ProcessInfo.processInfo.environment["DRIVE_DRAFT"]
        #endif

        typed()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init() instead.")
    }

    /// The waveform records instead of typing, so it only makes sense while nothing has
    /// been typed; once something has, the same place is where you send it from.
    private func typed() {
        let sending = !field.text.isEmpty
        let size = UIImage.SymbolConfiguration(pointSize: sending ? 27 : 20)

        placeholder.isHidden = sending
        trailing.setImage(
            UIImage(systemName: sending ? "arrow.up.circle.fill" : "waveform",
                    withConfiguration: size),
            for: .normal
        )
        trailing.tintColor = sending ? .systemBlue : .systemOrange
    }
}

extension MessageBar: UITextViewDelegate {
    func textViewDidChange(_ view: UITextView) {
        // Growing stops at the cap, and past it the text view goes back to scrolling.
        view.isScrollEnabled = view.contentSize.height > Self.tallest
        typed()
    }
}
