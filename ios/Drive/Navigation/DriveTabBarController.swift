import HotwireNative
import UIKit

/// The tab bar, plus the one behavior every Apple app has and the library does not:
/// tapping the tab you are already on returns you to its root.
final class DriveTabBarController: HotwireTabBarController {
    private let tabSelection = TabSelectionDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()

        // `HotwireTabBarController` makes itself the delegate and implements
        // `didSelect` in an extension, and Swift will not let a subclass override a
        // method declared there — nor re-declare the conformance. So the way in is a
        // delegate of our own, which then owes what the library's was doing.
        delegate = tabSelection
    }
}

/// Starts a tab's navigator the first time that tab is chosen, and pops the stack back
/// to its root when the tab already showing is tapped again.
private final class TabSelectionDelegate: NSObject, UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        guard tabBarController.selectedViewController === viewController,
              let navigation = viewController as? UINavigationController,
              navigation.viewControllers.count > 1
        else { return true }

        navigation.popToRootViewController(animated: true)

        return true
    }

    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        // The debt: without this a tab chosen for the first time never cold-boots.
        (tabBarController as? HotwireTabBarController)?.activeNavigator.start()
    }
}
