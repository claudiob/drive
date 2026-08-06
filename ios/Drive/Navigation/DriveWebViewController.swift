import HotwireNative
import UIKit

/// The screen every web page is shown in, corrected for the places UIKit's defaults and
/// Apple's own apps disagree.
final class DriveWebViewController: HotwireWebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // `VisitableViewController` sets plain white, which is wrong in dark mode.
        // The grouped gray is what every screen here sits on.
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never

        // The nav bar and tab bar on iOS 17 are opaque, and a page drawn underneath
        // them reports no safe-area insets at all — so `env(safe-area-inset-*)` is
        // zero and the page has no way to clear the chrome itself. Keeping the view
        // inside the bars instead makes the web view exactly the visible area.
        edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // A sheet is dismissed with Cancel on the trailing side, the way Apple's own
        // are. The library offers a Done button instead, which reads wrong on a form
        // that has its own submit.
        guard presentingViewController != nil,
              navigationItem.rightBarButtonItem == nil
        else { return }

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) }
        )
    }
}
