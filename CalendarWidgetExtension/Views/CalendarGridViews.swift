import SwiftUI
import WidgetKit

// MARK: - Widget Background Modifier

/// Cross-version compatible background modifier
struct WidgetBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 14.0, *) {
            content
                .containerBackground(for: .widget) {
                    WidgetBackgroundView()
                }
        } else {
            // macOS 13 fallback: use padding and background
            content
                .padding(8)
                .background(WidgetBackgroundView())
        }
    }
}

extension View {
    func widgetBackground() -> some View {
        modifier(WidgetBackgroundModifier())
    }
}

// MARK: - SingleMonthView

/// Small widget: displays only the current month
struct SingleMonthView: View {
    let entry: CalendarWidgetEntry

    var body: some View {
        MonthView(model: entry.currentMonth, size: .small)
            .widgetBackground()
    }
}

// MARK: - TwoMonthGridView

/// Medium widget: displays previous and current month side by side
struct TwoMonthGridView: View {
    let entry: CalendarWidgetEntry

    var body: some View {
        HStack(spacing: 8) {
            MonthView(model: entry.previousMonth, size: .medium)
            MonthView(model: entry.currentMonth, size: .medium)
        }
        .widgetBackground()
    }
}

// MARK: - FourMonthGridView

/// Large widget: displays all 4 months in a 2x2 grid
struct FourMonthGridView: View {
    let entry: CalendarWidgetEntry

    var body: some View {
        VStack(spacing: 8) {
            // Top row: Previous + Current
            HStack(spacing: 8) {
                MonthView(model: entry.previousMonth, size: .large)
                MonthView(model: entry.currentMonth, size: .large)
            }

            // Bottom row: Next + Next Next
            HStack(spacing: 8) {
                MonthView(model: entry.nextMonth, size: .large)
                MonthView(model: entry.nextNextMonth, size: .large)
            }
        }
        .widgetBackground()
    }
}

// MARK: - WidgetBackgroundView

/// Consistent background for all widget sizes
struct WidgetBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if colorScheme == .dark {
            // Dark mode: subtle dark gradient
            LinearGradient(
                colors: [
                    Color(white: 0.15),
                    Color(white: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            // Light mode: soft light gradient
            LinearGradient(
                colors: [
                    Color(white: 0.95),
                    Color(white: 0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Widget Entry View

/// Main entry point that switches based on widget family
struct CalendarWidgetEntryView: View {
    let entry: CalendarWidgetEntry

    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SingleMonthView(entry: entry)
        case .systemMedium:
            TwoMonthGridView(entry: entry)
        case .systemLarge, .systemExtraLarge:
            FourMonthGridView(entry: entry)
        @unknown default:
            TwoMonthGridView(entry: entry)
        }
    }
}

// MARK: - Preview Provider

#if DEBUG
struct CalendarWidgetPreviews: PreviewProvider {
    static var previews: some View {
        let builder = CalendarMonthBuilder()
        let months = builder.buildFourMonthModels()
        let entry = CalendarWidgetEntry(date: Date(), months: months)

        Group {
            CalendarWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small")

            CalendarWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")

            CalendarWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large")

            CalendarWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large Dark")
                .environment(\.colorScheme, .dark)
        }
    }
}
#endif
