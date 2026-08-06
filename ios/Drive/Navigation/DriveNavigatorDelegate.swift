import HotwireNative
import UIKit

/// Decides which screens are drawn natively rather than as a web page. A path
/// configuration rule names the screen with `view_controller`, and this turns that name
/// into the controller. Everything unnamed stays a web view — the detail pages and
/// forms included.
final class DriveNavigatorDelegate: NSObject, NavigatorDelegate {
    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        let url = proposal.url

        return switch proposal.viewController {
        case JobsViewController.pathConfigurationIdentifier:
            .acceptCustom(JobsViewController(url: url, navigator: navigator))
        case ListsViewController.pathConfigurationIdentifier:
            .acceptCustom(ListsViewController(url: url, navigator: navigator))
        case ContactsViewController.pathConfigurationIdentifier:
            .acceptCustom(ContactsViewController(url: url, navigator: navigator))
        case MessagesViewController.pathConfigurationIdentifier:
            .acceptCustom(MessagesViewController(url: url, navigator: navigator))
        case ConversationViewController.pathConfigurationIdentifier:
            .acceptCustom(ConversationViewController(url: url, navigator: navigator))
        case NewContactViewController.pathConfigurationIdentifier:
            .acceptCustom(NewContactViewController(url: url, navigator: navigator))
        case ComposeViewController.pathConfigurationIdentifier:
            .acceptCustom(ComposeViewController(url: url, navigator: navigator))
        case SettingsViewController.pathConfigurationIdentifier:
            .acceptCustom(SettingsViewController(url: url, navigator: navigator))
        default:
            .accept
        }
    }
}
