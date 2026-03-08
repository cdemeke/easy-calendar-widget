import Foundation

// MARK: - CalendarDayModel

/// Represents a single day in the calendar grid
struct CalendarDayModel: Identifiable, Hashable {
    let id: String
    let dayNumber: Int
    let isToday: Bool
    let isPlaceholder: Bool // Empty cell for grid alignment
    let date: Date?

    /// Accessibility label for VoiceOver
    var accessibilityLabel: String {
        if isPlaceholder {
            return "Empty"
        }
        guard let date = date else {
            return "Day \(dayNumber)"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    /// Creates an empty placeholder cell
    static func placeholder(id: String) -> CalendarDayModel {
        CalendarDayModel(
            id: id,
            dayNumber: 0,
            isToday: false,
            isPlaceholder: true,
            date: nil
        )
    }
}

// MARK: - CalendarWeekModel

/// Represents a single week (row) in the calendar grid
struct CalendarWeekModel: Identifiable, Hashable {
    let id: String
    let days: [CalendarDayModel]
}

// MARK: - CalendarMonthModel

/// Complete model for a single month's calendar display
struct CalendarMonthModel: Identifiable, Hashable {
    let id: String
    let year: Int
    let month: Int
    let title: String
    let weekdaySymbols: [String]
    let weeks: [CalendarWeekModel]
    let containsToday: Bool

    /// Accessibility label for the month
    var accessibilityLabel: String {
        "\(title), \(year)"
    }
}

// MARK: - CalendarWidgetEntry

import WidgetKit

/// The timeline entry containing precomputed month models
struct CalendarWidgetEntry: TimelineEntry {
    let date: Date
    let months: [CalendarMonthModel]

    /// Two months before current (index 0)
    var previousPreviousMonth: CalendarMonthModel { months[0] }

    /// Previous month (index 1)
    var previousMonth: CalendarMonthModel { months[1] }

    /// Current month (index 2)
    var currentMonth: CalendarMonthModel { months[2] }

    /// Next month (index 3)
    var nextMonth: CalendarMonthModel { months[3] }

    /// Month after next (index 4)
    var nextNextMonth: CalendarMonthModel { months[4] }

    /// Two months after next (index 5)
    var nextNextNextMonth: CalendarMonthModel { months[5] }
}
