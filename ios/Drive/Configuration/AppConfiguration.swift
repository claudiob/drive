import Foundation

/// Where the app talks to, read from the bundle so a build configuration can change it
/// without touching code.
enum AppConfiguration {
    static var baseURL: URL {
        guard let string = Bundle.main.object(forInfoDictionaryKey: "DriveBaseURL") as? String,
              let url = URL(string: string)
        else {
            fatalError("DriveBaseURL is missing from Info.plist")
        }

        return url
    }
}
