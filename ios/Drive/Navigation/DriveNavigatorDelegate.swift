import HotwireNative
import UIKit

/// Decides which screens are drawn natively rather than as a web page. A path
/// configuration rule names the screen with `view_controller`, and this turns that name
/// into the controller.
final class DriveNavigatorDelegate: NSObject, NavigatorDelegate {
    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        switch proposal.viewController {
        case JobsViewController.pathConfigurationIdentifier:
            .acceptCustom(JobsViewController(url: proposal.url, navigator: navigator))
        default:
            .accept
        }
    }
}
