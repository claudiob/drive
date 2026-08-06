import UIKit

/// The "To:" row at the top of a new message: a label, the field itself, and the
/// circled plus that opens the picker — the header Messages puts above its results.
final class ComposeField: UIView {
    var onChange: ((String) -> Void)?
    var onClear: (() -> Void)?
    var isLocked = false

    private let field = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBackground

        let to = UILabel()
        to.text = "To:"
        to.textColor = .secondaryLabel
        to.font = .preferredFont(forTextStyle: .body)
        to.setContentHuggingPriority(.required, for: .horizontal)

        field.font = .preferredFont(forTextStyle: .body)
        field.autocorrectionType = .no
        field.autocapitalizationType = .words
        // The email layout, with @ and . on the keyboard: a recipient here is a name,
        // a number or an address, and this is the keyboard Messages offers for it.
        field.keyboardType = .emailAddress
        field.delegate = self
        field.addTarget(self, action: #selector(changed), for: .editingChanged)

        // No circled plus: there are no group messages, so there is never a second
        // recipient to add.
        let stack = UIStackView(arrangedSubviews: [to, field])
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        let hairline = UIView()
        hairline.backgroundColor = .separator
        hairline.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hairline)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 11),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11),
            hairline.leadingAnchor.constraint(equalTo: leadingAnchor),
            hairline.trailingAnchor.constraint(equalTo: trailingAnchor),
            hairline.bottomAnchor.constraint(equalTo: bottomAnchor),
            hairline.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(frame:) instead.")
    }

    var text: String {
        get { field.text ?? "" }
        set { field.text = newValue }
    }

    override func becomeFirstResponder() -> Bool {
        field.becomeFirstResponder()
    }

    @objc private func changed() {
        onChange?(field.text ?? "")
    }
}

extension ComposeField: UITextFieldDelegate {
    /// Once a recipient is chosen the field takes no more typing; a backspace clears
    /// the whole thing and lets another be picked.
    func textField(_ field: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard isLocked else { return true }

        if string.isEmpty { onClear?() }

        return false
    }
}
