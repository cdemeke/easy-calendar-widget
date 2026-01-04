import SwiftUI

/// Main application entry point
/// This app serves as the host for the Calendar Widget extension
@main
struct EasyCalendarWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
