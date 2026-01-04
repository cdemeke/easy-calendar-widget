import SwiftUI
import WidgetKit

// MARK: - MonthView

/// Displays a single month calendar with neumorphism-inspired styling
struct MonthView: View {
    let model: CalendarMonthModel
    let size: WidgetSize

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: spacing.vertical) {
            // Month title
            Text(model.title)
                .font(titleFont)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .accessibilityLabel(model.accessibilityLabel)

            // Weekday header row
            WeekdayHeaderView(symbols: model.weekdaySymbols, size: size)

            // Day grid
            VStack(spacing: spacing.dayRow) {
                ForEach(model.weeks) { week in
                    WeekRowView(week: week, size: size)
                }
            }
        }
        .padding(cardPadding)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
    }

    // MARK: - Sizing Properties

    private var titleFont: Font {
        switch size {
        case .small:
            return .system(size: 11, weight: .semibold)
        case .medium:
            return .system(size: 12, weight: .semibold)
        case .large:
            return .system(size: 13, weight: .semibold)
        }
    }

    private var spacing: (vertical: CGFloat, dayRow: CGFloat) {
        switch size {
        case .small:
            return (4, 2)
        case .medium:
            return (5, 2)
        case .large:
            return (6, 3)
        }
    }

    private var cardPadding: CGFloat {
        switch size {
        case .small: return 8
        case .medium: return 10
        case .large: return 12
        }
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .small: return 12
        case .medium: return 14
        case .large: return 16
        }
    }

    private var shadowRadius: CGFloat {
        colorScheme == .dark ? 4 : 6
    }

    private var shadowY: CGFloat {
        colorScheme == .dark ? 2 : 3
    }

    private var shadowColor: Color {
        colorScheme == .dark
            ? Color.black.opacity(0.3)
            : Color.black.opacity(0.08)
    }

    @ViewBuilder
    private var cardBackground: some View {
        if colorScheme == .dark {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.05),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        } else {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color.white.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        }
    }
}

// MARK: - WeekdayHeaderView

/// Displays the weekday symbols row
struct WeekdayHeaderView: View {
    let symbols: [String]
    let size: WidgetSize

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(symbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(font)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var font: Font {
        switch size {
        case .small: return .system(size: 8)
        case .medium: return .system(size: 9)
        case .large: return .system(size: 10)
        }
    }
}

// MARK: - WeekRowView

/// Displays a single week row of days
struct WeekRowView: View {
    let week: CalendarWeekModel
    let size: WidgetSize

    var body: some View {
        HStack(spacing: 0) {
            ForEach(week.days) { day in
                DayView(day: day, size: size)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - DayView

/// Displays a single day cell with optional "today" highlight
struct DayView: View {
    let day: CalendarDayModel
    let size: WidgetSize

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            if day.isToday {
                Circle()
                    .fill(todayBackgroundColor)
                    .frame(width: todayCircleSize, height: todayCircleSize)
            }

            if !day.isPlaceholder {
                Text("\(day.dayNumber)")
                    .font(font)
                    .fontWeight(day.isToday ? .bold : .regular)
                    .foregroundStyle(day.isToday ? todayTextColor : .primary)
            }
        }
        .frame(height: rowHeight)
        .accessibilityLabel(day.accessibilityLabel)
        .accessibilityHidden(day.isPlaceholder)
    }

    // MARK: - Sizing

    private var font: Font {
        switch size {
        case .small: return .system(size: 9)
        case .medium: return .system(size: 10)
        case .large: return .system(size: 11)
        }
    }

    private var rowHeight: CGFloat {
        switch size {
        case .small: return 12
        case .medium: return 14
        case .large: return 16
        }
    }

    private var todayCircleSize: CGFloat {
        switch size {
        case .small: return 14
        case .medium: return 16
        case .large: return 20
        }
    }

    private var todayBackgroundColor: Color {
        colorScheme == .dark
            ? Color.accentColor.opacity(0.4)
            : Color.accentColor.opacity(0.2)
    }

    private var todayTextColor: Color {
        colorScheme == .dark
            ? Color.white
            : Color.accentColor
    }
}

// MARK: - WidgetSize

/// Represents the widget size for layout calculations
enum WidgetSize {
    case small
    case medium
    case large

    init(from family: WidgetFamily) {
        switch family {
        case .systemSmall:
            self = .small
        case .systemMedium:
            self = .medium
        case .systemLarge, .systemExtraLarge:
            self = .large
        @unknown default:
            self = .medium
        }
    }
}
