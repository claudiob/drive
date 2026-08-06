import HotwireNative
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let navigatorDelegate = DriveNavigatorDelegate()
    private lazy var tabBarController = DriveTabBarController(navigatorDelegate: navigatorDelegate)

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Before `load`, which builds a navigator per tab and reads this as it goes.
        HotwireSetup.run()

        window = UIWindow(windowScene: windowScene)
        // Shows behind the bars, so black would band the top and bottom of every screen.
        window?.backgroundColor = .systemGroupedBackground
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        tabBarController.load(HotwireTab.all(baseURL: AppConfiguration.baseURL))
        Badges.apply(to: tabBarController, from: AppConfiguration.baseURL)

        #if DEBUG
            // Opens straight onto a tab, so a screenshot or a debug run can reach one
            // without tapping. Programmatic selection does not call the delegate, so
            // the navigator has to be started by hand.
            if let tab = ProcessInfo.processInfo.environment["DRIVE_TAB"],
               let index = Int(tab) {
                tabBarController.selectedIndex = index
                tabBarController.activeNavigator.start()

                if let path = ProcessInfo.processInfo.environment["DRIVE_ROUTE"],
                   let target = URL(string: path, relativeTo: AppConfiguration.baseURL) {
                    tabBarController.activeNavigator.route(target.absoluteURL)
                }
            }
        #endif
    }
}
