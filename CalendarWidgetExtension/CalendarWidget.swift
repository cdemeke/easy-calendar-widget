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
        let calendar = Calendar.current

        // Get tomorrow's date
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) else {
            // Fallback: update in 24 hours
            return date.addingTimeInterval(24 * 60 * 60)
        }

        // Get start of tomorrow (midnight)
        let startOfTomorrow = calendar.startOfDay(for: tomorrow)

        // Add 1 minute buffer to ensure we're past midnight
        return startOfTomorrow.addingTimeInterval(60)
    }
}

// MARK: - CalendarWidget

/// The main widget definition
struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        makeConfiguration()
    }

    /// Supported widget families for macOS
    private var supportedFamilies: [WidgetFamily] {
        if #available(macOS 14.0, *) {
            return [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
        } else {
            return [.systemSmall, .systemMedium, .systemLarge]
        }
    }

    private var displayName: String {
        #if DEBUG
        "Dev - Calendar"
        #else
        "Calendar"
        #endif
    }

    private var displayDescription: String {
        #if DEBUG
        "DEV BUILD — View multiple months at a glance."
        #else
        "View multiple months at a glance."
        #endif
    }

    @available(macOS 14.0, *)
    private func makeConfigurationModern() -> some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarTimelineProvider()) { entry in
            CalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(displayName)
        .description(displayDescription)
        .supportedFamilies(supportedFamilies)
        .contentMarginsDisabled()
    }

    private func makeConfigurationLegacy() -> some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarTimelineProvider()) { entry in
            CalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(displayName)
        .description(displayDescription)
        .supportedFamilies(supportedFamilies)
    }

    private func makeConfiguration() -> some WidgetConfiguration {
        if #available(macOS 14.0, *) {
            return makeConfigurationModern()
        } else {
            return makeConfigurationLegacy()
        }
    }
}

// MARK: - SixMonthCalendarWidget

/// A separate widget that always shows 6 months in a 3x2 grid at the large size
struct SixMonthCalendarWidget: Widget {
    let kind: String = "SixMonthCalendarWidget"

    var body: some WidgetConfiguration {
        makeConfiguration()
    }

    private var displayName: String {
        #if DEBUG
        "Dev - 6-Month Calendar"
        #else
        "6-Month Calendar"
        #endif
    }

    private var displayDescription: String {
        #if DEBUG
        "DEV BUILD — View 6 months at a glance in a 3×2 grid."
        #else
        "View 6 months at a glance in a 3×2 grid."
        #endif
    }

    @available(macOS 14.0, *)
    private func makeConfigurationModern() -> some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarTimelineProvider()) { entry in
            SixMonthGridView(entry: entry)
        }
        .configurationDisplayName(displayName)
        .description(displayDescription)
        .supportedFamilies([.systemLarge])
        .contentMarginsDisabled()
    }

    private func makeConfigurationLegacy() -> some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarTimelineProvider()) { entry in
            SixMonthGridView(entry: entry)
        }
        .configurationDisplayName(displayName)
        .description(displayDescription)
        .supportedFamilies([.systemLarge])
    }

    private func makeConfiguration() -> some WidgetConfiguration {
        if #available(macOS 14.0, *) {
            return makeConfigurationModern()
        } else {
            return makeConfigurationLegacy()
        }
    }
}
