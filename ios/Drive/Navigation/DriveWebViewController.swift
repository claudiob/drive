import HotwireNative
import UIKit

/// The screen every web page is shown in, corrected for the places UIKit's defaults and
/// Apple's own apps disagree.
final class DriveWebViewController: HotwireWebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // `VisitableViewController` sets plain white, which is wrong in dark mode.
        // The grouped grey is what every screen here sits on.
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never

        // The nav bar and tab bar on iOS 17 are opaque, and a page drawn underneath
        // them reports no safe-area insets at all — so `env(safe-area-inset-*)` is
        // zero and the page has no way to clear the chrome itself. Keeping the view
        // inside the bars instead makes the web view exactly the visible area.
        edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = false
    }
}
