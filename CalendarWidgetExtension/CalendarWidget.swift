import WidgetKit
import SwiftUI

// MARK: - CalendarTimelineProvider

/// Provides timeline entries for the calendar widget
/// Updates daily after midnight to keep "today" accurate
struct CalendarTimelineProvider: TimelineProvider {

    // MARK: - Placeholder

    func placeholder(in context: Context) -> CalendarWidgetEntry {
        createEntry(for: Date())
    }

    // MARK: - Snapshot

    func getSnapshot(in context: Context, completion: @escaping (CalendarWidgetEntry) -> Void) {
        let entry = createEntry(for: Date())
        completion(entry)
    }

    // MARK: - Timeline

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarWidgetEntry>) -> Void) {
        let now = Date()
        let entry = createEntry(for: now)

        // Calculate next update time: shortly after local midnight
        let nextUpdate = calculateNextUpdateDate(from: now)

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    // MARK: - Private Helpers

    /// Creates a calendar entry with precomputed month models
    private func createEntry(for date: Date) -> CalendarWidgetEntry {
        let builder = CalendarMonthBuilder(referenceDate: date)
        let months = builder.buildSixMonthModels()
        return CalendarWidgetEntry(date: date, months: months)
    }

    /// Calculates the next update time (1 minute after midnight)
    private func calculateNextUpdateDate(from date: Date) -> Date {
        TimelineRefreshCalculator().nextUpdateDate(from: date)
    }
}

// MARK: - Calendar Widget Layouts

enum CalendarWidgetLayout {
    case oneByOne
    case oneByTwo
    case twoByTwo
    case threeByTwo

    var kind: String {
        #if DEBUG
        switch self {
        case .oneByOne: return "DevCalendar1x1Widget"
        case .oneByTwo: return "DevCalendar1x2Widget"
        case .twoByTwo: return "DevCalendar2x2Widget"
        case .threeByTwo: return "DevCalendar3x2Widget"
        }
        #else
        switch self {
        case .oneByOne: return "Calendar1x1Widget"
        case .oneByTwo: return "Calendar1x2Widget"
        case .twoByTwo: return "Calendar2x2Widget"
        case .threeByTwo: return "Calendar3x2Widget"
        }
        #endif
    }

    var displayName: String {
        #if DEBUG
        switch self {
        case .oneByOne: return "Dev - 1 Month (1x1)"
        case .oneByTwo: return "Dev - 2 Months (1x2)"
        case .twoByTwo: return "Dev - 4 Months (2x2)"
        case .threeByTwo: return "Dev - 6 Months (3x2)"
        }
        #else
        switch self {
        case .oneByOne: return "Calendar - 1 Month"
        case .oneByTwo: return "Calendar - 2 Months"
        case .twoByTwo: return "Calendar - 4 Months"
        case .threeByTwo: return "Calendar - 6 Months"
        }
        #endif
    }

    var displayDescription: String {
        #if DEBUG
        "DEV BUILD — \(description)"
        #else
        description
        #endif
    }

    var supportedFamilies: [WidgetFamily] {
        switch self {
        case .oneByOne: return [.systemSmall]
        case .oneByTwo: return [.systemMedium]
        case .twoByTwo, .threeByTwo: return [.systemLarge]
        }
    }

    private var description: String {
        switch self {
        case .oneByOne: return "Compact single-month view."
        case .oneByTwo: return "Two-month side-by-side view."
        case .twoByTwo: return "Four-month planning view."
        case .threeByTwo: return "Six-month overview."
        }
    }
}

private struct CalendarLayoutEntryView: View {
    let layout: CalendarWidgetLayout
    let entry: CalendarWidgetEntry

    var body: some View {
        switch layout {
        case .oneByOne:
            SingleMonthView(entry: entry)
        case .oneByTwo:
            TwoMonthGridView(entry: entry)
        case .twoByTwo:
            FourMonthGridView(entry: entry)
        case .threeByTwo:
            SixMonthGridView(entry: entry)
        }
    }
}

struct Calendar1x1Widget: Widget {
    var body: some WidgetConfiguration {
        makeCalendarLayoutConfiguration(layout: .oneByOne)
    }
}

struct Calendar1x2Widget: Widget {
    var body: some WidgetConfiguration {
        makeCalendarLayoutConfiguration(layout: .oneByTwo)
    }
}

struct Calendar2x2Widget: Widget {
    var body: some WidgetConfiguration {
        makeCalendarLayoutConfiguration(layout: .twoByTwo)
    }
}

struct Calendar3x2Widget: Widget {
    var body: some WidgetConfiguration {
        makeCalendarLayoutConfiguration(layout: .threeByTwo)
    }
}

@available(macOS 14.0, *)
private func makeCalendarLayoutConfigurationModern(layout: CalendarWidgetLayout) -> some WidgetConfiguration {
    StaticConfiguration(kind: layout.kind, provider: CalendarTimelineProvider()) { entry in
        CalendarLayoutEntryView(layout: layout, entry: entry)
    }
    .configurationDisplayName(layout.displayName)
    .description(layout.displayDescription)
    .supportedFamilies(layout.supportedFamilies)
    .contentMarginsDisabled()
}

private func makeCalendarLayoutConfigurationLegacy(layout: CalendarWidgetLayout) -> some WidgetConfiguration {
    StaticConfiguration(kind: layout.kind, provider: CalendarTimelineProvider()) { entry in
        CalendarLayoutEntryView(layout: layout, entry: entry)
    }
    .configurationDisplayName(layout.displayName)
    .description(layout.displayDescription)
    .supportedFamilies(layout.supportedFamilies)
}

private func makeCalendarLayoutConfiguration(layout: CalendarWidgetLayout) -> some WidgetConfiguration {
    if #available(macOS 14.0, *) {
        return makeCalendarLayoutConfigurationModern(layout: layout)
    } else {
        return makeCalendarLayoutConfigurationLegacy(layout: layout)
    }
}
