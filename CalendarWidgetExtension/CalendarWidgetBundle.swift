import WidgetKit
import SwiftUI

/// Widget bundle that registers all widgets in this extension
@main
struct CalendarWidgetBundle: WidgetBundle {
    var body: some Widget {
        Calendar1x1Widget()
        Calendar1x2Widget()
        Calendar2x2Widget()
        Calendar3x2Widget()
    }
}
