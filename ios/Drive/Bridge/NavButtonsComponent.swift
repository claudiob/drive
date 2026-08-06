import HotwireNative
import UIKit

/// Puts the buttons a page declares into the real navigation bar, and clicks the page's
/// own element when one is tapped — so the behavior stays in the HTML and only the
/// chrome is native.
final class NavButtonsComponent: BridgeComponent {
    override class var name: String { "nav-buttons" }

    override func onReceive(message: Message) {
        guard let viewController, let data: ConnectData = message.data() else { return }

        viewController.navigationItem.leftBarButtonItems = data.leading.map(barButton)
        viewController.navigationItem.rightBarButtonItems = data.trailing.map(barButton)
    }

    private var viewController: UIViewController? {
        delegate?.destination as? UIViewController
    }

    /// Replying re-runs the page's callback, and the bridge keeps that callback for the
    /// life of the message — so one `connect` serves every tap that follows.
    private func barButton(_ button: Button) -> UIBarButtonItem {
        let action = UIAction { [unowned self] _ in
            reply(to: "connect", with: TapData(id: button.id))
        }

        let item = if let symbol = button.symbol, let image = UIImage(systemName: symbol) {
            UIBarButtonItem(image: image, primaryAction: action)
        } else {
            UIBarButtonItem(title: button.title, primaryAction: action)
        }

        item.style = button.prominent == true ? .done : .plain

        return item
    }
}

private extension NavButtonsComponent {
    struct ConnectData: Decodable {
        let leading: [Button]
        let trailing: [Button]
    }

    struct Button: Decodable {
        let id: String
        let title: String
        let symbol: String?
        let prominent: Bool?
    }

    struct TapData: Encodable {
        let id: String
    }
}
