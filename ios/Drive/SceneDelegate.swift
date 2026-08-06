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
    }
}
