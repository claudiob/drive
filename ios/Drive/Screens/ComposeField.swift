import UIKit

/// The "To:" row at the top of a new message: a label and the field itself.
///
/// The field is a `UISearchTextField`, which is the component Mail and Messages put a
/// recipient in — it owns the token, so the pill's shape, tint, selected state and
/// one-backspace deletion are Apple's rather than ours. Its search chrome is turned off,
/// since this row is a plain line with a hairline under it, not a rounded search box.
final class ComposeField: UIView {
    var onChange: ((String) -> Void)?
    var onClear: (() -> Void)?
    var onSubmit: (() -> Void)?

    private let field = UISearchTextField()
    private var held = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBackground

        let to = UILabel()
        to.text = "To:"
        to.textColor = .secondaryLabel
        to.font = .preferredFont(forTextStyle: .body)
        to.setContentHuggingPriority(.required, for: .horizontal)

        field.borderStyle = .none
        field.backgroundColor = .clear
        field.clearButtonMode = .never
        // The class ships the search chrome a search bar wants: a rounded fill, a
        // magnifying glass, and a token tinted grey to sit inside that fill. This row is
        // a plain line in a sheet, so the fill and the glass go and the token takes the
        // tint a recipient has.
        //
        // Solid, and knowingly one shade off Messages, which shows an unselected
        // recipient as pale blue with blue text. `tokenBackgroundColor` is the only knob
        // the class offers and the token's own text stays white whatever it is set to —
        // a pale fill was tried and is unreadable. So this is Apple's *selected* token,
        // which is nearer than grey and is at least a rendering Apple ships.
        field.leftView = nil
        field.leftViewMode = .never
        field.tokenBackgroundColor = .tintColor
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

    /// What has been typed, which is never the recipient: once one is chosen it is a
    /// token, and a token is not text.
    var text: String {
        get { field.text ?? "" }
        set { field.text = newValue }
    }

    /// Whether somebody has been chosen.
    var isHolding: Bool { held }

    /// Holds the chosen recipient as a token, and takes back the line they were typed on.
    func hold(_ name: String) {
        field.text = ""
        field.insertToken(UISearchToken(icon: nil, text: name), at: 0)
        held = true
    }

    /// Empties the field without reporting it, since the caller is the one emptying it.
    func clear() {
        held = false
        field.text = ""
        while !field.tokens.isEmpty { field.removeToken(at: 0) }
    }

    override func becomeFirstResponder() -> Bool {
        field.becomeFirstResponder()
    }

    @objc private func changed() {
        noticeDeletion()
        onChange?(field.text ?? "")
    }

    /// Deleting a token changes no text, so the count is what says it happened. It can
    /// arrive as an edit or as a selection change, so both hooks ask.
    private func noticeDeletion() {
        guard held, field.tokens.isEmpty else { return }

        held = false
        onClear?()
    }
}

extension ComposeField: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ field: UITextField) {
        noticeDeletion()
    }

    /// One recipient, so typing past the token is refused. A backspace goes through,
    /// because deleting the token is how the field is emptied.
    func textField(_ field: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        held ? string.isEmpty : true
    }

    /// Return accepts what has been typed, when what has been typed is a whole number.
    func textFieldShouldReturn(_ field: UITextField) -> Bool {
        onSubmit?()

        return false
    }
}
