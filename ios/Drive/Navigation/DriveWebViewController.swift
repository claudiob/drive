import HotwireNative
import UIKit

/// The screen every web page is shown in, corrected for the places UIKit's defaults and
/// Apple's own apps disagree.
final class DriveWebViewController: HotwireWebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // `VisitableViewController` sets plain white, which is wrong in dark mode.
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
    }
}
