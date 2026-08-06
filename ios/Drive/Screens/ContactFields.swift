import UIKit

/// The fields a new contact is made of, and the traits each one needs. Pairing
/// `keyboardType` with `textContentType` is what Apple's guidance asks for: the first
/// picks the keyboard, the second is what lets AutoFill offer a value at all.
enum ContactField: Int, CaseIterable {
    case phone, first, last, email

    var placeholder: String {
        switch self {
        case .phone: "Mobile phone"
        case .first: "First name"
        case .last: "Last name"
        case .email: "Email"
        }
    }

    var keyboard: UIKeyboardType {
        switch self {
        case .phone: .phonePad
        case .email: .emailAddress
        default: .default
        }
    }

    var content: UITextContentType {
        switch self {
        case .phone: .telephoneNumber
        case .first: .givenName
        case .last: .familyName
        case .email: .emailAddress
        }
    }

    var capitalization: UITextAutocapitalizationType {
        switch self {
        case .first, .last: .words
        default: .none
        }
    }

    /// Builds the field, wired to tell the screen when its value changed.
    func makeField(target: Any, action: Selector) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.font = .preferredFont(forTextStyle: .body)
        field.keyboardType = keyboard
        field.textContentType = content
        field.autocapitalizationType = capitalization
        field.autocorrectionType = .no
        field.clearButtonMode = .whileEditing
        field.returnKeyType = self == ContactField.allCases.last ? .done : .next
        field.addTarget(target, action: action, for: .editingChanged)

        return field
    }
}
