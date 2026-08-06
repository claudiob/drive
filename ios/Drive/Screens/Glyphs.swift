import UIKit

/// The small images these screens draw for themselves: an initials circle, the unread
/// dot, and the rounded-square badge iOS Settings puts beside every row.
enum Glyphs {
    /// A circle of initials, the stand-in Contacts and Messages both use for someone
    /// with no picture. `unread` adds the blue dot Messages puts to its left, drawn
    /// into the same image because a list cell has no slot of its own for one.
    static func avatar(_ initials: String, diameter: CGFloat = 40,
                       unread: Bool = false) -> UIImage {
        // Always reserved, drawn only when unread, so every avatar shares a column.
        let gutter: CGFloat = 18
        let size = CGSize(width: diameter + gutter, height: diameter)

        return UIGraphicsImageRenderer(size: size).image { context in
            if unread {
                UIColor.systemBlue.setFill()
                context.cgContext.fillEllipse(
                    in: CGRect(x: 0, y: diameter / 2 - 5, width: 10, height: 10))
            }

            UIColor.systemGray3.setFill()
            context.cgContext.fillEllipse(
                in: CGRect(x: gutter, y: 0, width: diameter, height: diameter))

            let font = UIFont.systemFont(ofSize: diameter * 0.4, weight: .regular)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font, .foregroundColor: UIColor.white
            ]
            let text = initials as NSString
            let bounds = text.size(withAttributes: attributes)

            text.draw(
                at: CGPoint(x: gutter + (diameter - bounds.width) / 2,
                            y: (diameter - bounds.height) / 2),
                withAttributes: attributes
            )
        }
    }

    /// Everything in a row's leading slot is drawn into the same square, which is what
    /// lines an icon on one row up with a dot on the next — and keeps the titles of
    /// rows that have neither aligned with those that do.
    static let slot: CGFloat = 28

    /// A symbol centred in the slot, or an empty slot when there is no symbol.
    static func leading(_ symbol: String?, tint: UIColor = .label) -> UIImage {
        let size = CGSize(width: slot, height: slot)

        return UIGraphicsImageRenderer(size: size).image { _ in
            guard let symbol,
                  let glyph = UIImage(
                      systemName: symbol,
                      withConfiguration: UIImage.SymbolConfiguration(pointSize: 17)
                  )?.withTintColor(tint, renderingMode: .alwaysOriginal)
            else { return }

            glyph.draw(at: CGPoint(x: (slot - glyph.size.width) / 2,
                                   y: (slot - glyph.size.height) / 2))
        }.withRenderingMode(.alwaysOriginal)
    }

    /// The unread dot, centred in that same slot.
    static var dot: UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: slot, height: slot)).image { context in
            UIColor.systemBlue.setFill()
            context.cgContext.fillEllipse(
                in: CGRect(x: slot / 2 - 5, y: slot / 2 - 5, width: 10, height: 10))
        }.withRenderingMode(.alwaysOriginal)
    }

    /// A glyph in a filled rounded square, 29pt — the size and radius Settings uses.
    static func badge(_ symbol: String, tint: UIColor) -> UIImage {
        let side: CGFloat = 29
        let size = CGSize(width: side, height: side)

        return UIGraphicsImageRenderer(size: size).image { _ in
            let box = UIBezierPath(
                roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 7)
            tint.setFill()
            box.fill()

            let configuration = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
            let glyph = UIImage(systemName: symbol, withConfiguration: configuration)?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
            glyph?.draw(at: CGPoint(x: (side - (glyph?.size.width ?? 0)) / 2,
                                    y: (side - (glyph?.size.height ?? 0)) / 2))
        }.withRenderingMode(.alwaysOriginal)
    }
}
