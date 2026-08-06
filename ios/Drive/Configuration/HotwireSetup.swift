import HotwireNative
import UIKit
import WebKit

/// Everything that must be true before the first `Navigator` is built. The tab bar
/// makes one per tab, and each reads this configuration as it is created.
enum HotwireSetup {
    static func run() {
        // Registered before any web view is made: the component names go into the user
        // agent, and the bridge only initializes when the list is non-empty.
        Hotwire.registerBridgeComponents([
            NavButtonsComponent.self
        ])

        Hotwire.loadPathConfiguration(from: [
            // The bundled copy is synchronous, so the very first visit of a cold launch
            // routes correctly; the server copy then overrides it, which lets routing
            // change without shipping a build. Both are named for the platform and
            // versioned, because the loader caches under the last path component alone
            // — an `ios`/`android` pair sharing a name would overwrite each other.
            .file(Bundle.main.url(forResource: "ios_v1", withExtension: "json")!),
            .server(AppConfiguration.baseURL.appendingPathComponent("configurations/ios_v1.json"))
        ])

        Hotwire.config.applicationUserAgentPrefix = "Drive iOS;"
        // Cancel is added per screen instead, on the trailing side.
        Hotwire.config.showDoneButtonOnModals = false
        Hotwire.config.backButtonDisplayMode = .minimal

        // The tab bar stays put on a pushed screen. Hiding it would change
        // `safe-area-inset-bottom` mid-transition, and the search pill is positioned
        // off exactly that.
        Hotwire.config.hidesTabBarWhenPushed = false

        Hotwire.config.defaultViewController = { DriveWebViewController(url: $0) }
        Hotwire.config.makeCustomWebView = makeWebView

        #if DEBUG
            Hotwire.config.debugLoggingEnabled = true
        #endif

        styleBars()
    }

    /// Both bars are opaque here and the page sits between them, so they need a real
    /// background — left transparent they show the window through, and a label-coloured
    /// title on it is invisible.
    private static func styleBars() {
        let navigationBar = UINavigationBarAppearance()
        navigationBar.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navigationBar
        UINavigationBar.appearance().compactAppearance = navigationBar
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBar

        let tabBar = UITabBarAppearance()
        tabBar.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBar
        UITabBar.appearance().scrollEdgeAppearance = tabBar
    }

    private static func makeWebView(_ configuration: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: configuration)

        #if DEBUG
            // What puts the page in Safari's Develop menu. The library has a helper for
            // this, but it is internal to the package.
            webView.isInspectable = true
        #endif

        // Whatever the page has not painted yet must not be white in dark mode.
        webView.underPageBackgroundColor = UIColor.systemBackground
        webView.isOpaque = false
        webView.backgroundColor = UIColor.systemBackground
        webView.scrollView.backgroundColor = UIColor.systemBackground

        // Sideways rubber-banding is always wrong in a list app, and the message rows
        // scroll horizontally themselves.
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.showsHorizontalScrollIndicator = false

        // Rows are buttons, not links to preview.
        webView.allowsLinkPreview = false

        return webView
    }
}
