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
        ConnectedMonthGridView(rows: [[entry.currentMonth]], size: .small)
            .widgetBackground()
    }
}

// MARK: - TwoMonthGridView

/// Medium widget: displays previous and current month side by side
struct TwoMonthGridView: View {
    let entry: CalendarWidgetEntry

    var body: some View {
        ConnectedMonthGridView(rows: [[entry.previousMonth, entry.currentMonth]], size: .medium)
        .widgetBackground()
    }
}

// MARK: - FourMonthGridView

/// Large widget: displays all 4 months in a 2x2 grid
struct FourMonthGridView: View {
    let entry: CalendarWidgetEntry

    var body: some View {
        ConnectedMonthGridView(
            rows: [
                [entry.previousMonth, entry.currentMonth],
                [entry.nextMonth, entry.nextNextMonth]
            ],
            size: .large
        )
        .widgetBackground()
    }
}

private struct ConnectedMonthGridView: View {
    let rows: [[CalendarMonthModel]]
    let size: WidgetSize

    var body: some View {
        GeometryReader { proxy in
            let cellWidth = proxy.size.width / CGFloat(max(columnCount, 1))
            let cellHeight = proxy.size.height / CGFloat(max(rowCount, 1))

            ZStack {
                ConnectedMonthGridSurface(cornerRadius: cornerRadius)

                VStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: 0) {
                            ForEach(row) { month in
                                MonthView(model: month, size: size, style: .connected)
                                    .frame(width: cellWidth, height: cellHeight)
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

                ConnectedMonthGridDividers(columns: columnCount, rows: rowCount, cornerRadius: cornerRadius)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var columnCount: Int {
        rows.map(\.count).max() ?? 1
    }

    private var rowCount: Int {
        rows.count
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .small: return 22
        case .medium: return 24
        case .large: return 24
        case .extraLarge: return 24
        }
    }
}

private struct ConnectedMonthGridSurface: View {
    let cornerRadius: CGFloat

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
    }

    private var gradientColors: [Color] {
        colorScheme == .dark
            ? [Color.white.opacity(0.05), Color.clear]
            : [Color.white.opacity(0.7), Color.white.opacity(0.3)]
    }

    private var shadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.22) : Color.black.opacity(0.055)
    }

    private var shadowRadius: CGFloat {
        colorScheme == .dark ? 3 : 5
    }

    private var shadowY: CGFloat {
        colorScheme == .dark ? 1.5 : 2
    }
}

private struct ConnectedMonthGridDividers: View {
    let columns: Int
    let rows: Int
    let cornerRadius: CGFloat

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(1..<columns, id: \.self) { column in
                    Rectangle()
                        .fill(separatorColor)
                        .frame(width: 1)
                        .position(x: proxy.size.width * CGFloat(column) / CGFloat(columns), y: proxy.size.height / 2)
                }

                ForEach(1..<rows, id: \.self) { row in
                    Rectangle()
                        .fill(separatorColor)
                        .frame(height: 1)
                        .position(x: proxy.size.width / 2, y: proxy.size.height * CGFloat(row) / CGFloat(rows))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var separatorColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.10) : Color.black.opacity(0.065)
    }
}

// MARK: - SixMonthGridView

/// Extra large widget: displays 6 months in a 3x2 grid
struct SixMonthGridView: View {
    let entry: CalendarWidgetEntry

    var body: some View {
        ConnectedMonthGridView(
            rows: [
                [entry.previousPreviousMonth, entry.previousMonth, entry.currentMonth],
                [entry.nextMonth, entry.nextNextMonth, entry.nextNextNextMonth]
            ],
            size: .extraLarge
        )
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
        case .systemLarge:
            FourMonthGridView(entry: entry)
        case .systemExtraLarge:
            SixMonthGridView(entry: entry)
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
        let months = builder.buildSixMonthModels()
        let entry = CalendarWidgetEntry(date: Date(), months: months)

        Group {
            CalendarWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("1 Month")

            CalendarWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("2 Months")

            CalendarWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("4 Months")

            if #available(macOS 14.0, *) {
                CalendarWidgetEntryView(entry: entry)
                    .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
                    .previewDisplayName("6 Months")

                CalendarWidgetEntryView(entry: entry)
                    .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
                    .previewDisplayName("6 Months Dark")
                    .environment(\.colorScheme, .dark)
            }
        }
    }
}
#endif
