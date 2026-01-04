import WidgetKit
import SwiftUI

/// Widget bundle that registers all widgets in this extension
@main
struct CalendarWidgetBundle: WidgetBundle {
    var body: some Widget {
        CalendarWidget()
    }
}
