import Foundation

/// Builds CalendarMonthModel instances using proper Calendar APIs
/// Handles all date math, locale differences, and edge cases
struct CalendarMonthBuilder {

    private let calendar: Calendar
    private let today: Date

    // MARK: - Initialization

    /// Initialize with a specific calendar and reference date
    /// - Parameters:
    ///   - calendar: The calendar to use (defaults to user's current calendar)
    ///   - referenceDate: The reference date for "today" (defaults to now)
    init(calendar: Calendar = .current, referenceDate: Date = Date()) {
        self.calendar = calendar
        self.today = calendar.startOfDay(for: referenceDate)
    }

    // MARK: - Public API

    /// Builds models for four consecutive months centered around the current month
    /// - Returns: Array of [previous, current, next, nextNext] month models
    func buildFourMonthModels() -> [CalendarMonthModel] {
        return (-1...2).map { offset in
            buildMonthModel(monthOffset: offset)
        }
    }

    /// Builds a model for a specific month relative to the current month
    /// - Parameter monthOffset: Offset from current month (0 = current, -1 = previous, etc.)
    /// - Returns: The calendar month model
    func buildMonthModel(monthOffset: Int) -> CalendarMonthModel {
        guard let targetDate = calendar.date(byAdding: .month, value: monthOffset, to: today) else {
            fatalError("Failed to calculate month with offset \(monthOffset)")
        }

        let components = calendar.dateComponents([.year, .month], from: targetDate)
        guard let year = components.year, let month = components.month else {
            fatalError("Failed to extract year/month components")
        }

        let title = monthTitle(for: targetDate)
        let weekdaySymbols = localizedWeekdaySymbols()
        let weeks = buildWeeks(for: targetDate)
        let containsToday = calendar.isDate(targetDate, equalTo: today, toGranularity: .month)

        return CalendarMonthModel(
            id: "\(year)-\(month)",
            year: year,
            month: month,
            title: title,
            weekdaySymbols: weekdaySymbols,
            weeks: weeks,
            containsToday: containsToday
        )
    }

    // MARK: - Private Helpers

    /// Gets the localized month title (e.g., "January 2025")
    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMMM yyyy",
            options: 0,
            locale: calendar.locale ?? .current
        )
        return formatter.string(from: date)
    }

    /// Gets localized weekday symbols in the correct order for the calendar
    private func localizedWeekdaySymbols() -> [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let firstWeekday = calendar.firstWeekday // 1 = Sunday, 2 = Monday, etc.

        // Reorder symbols to start with the calendar's first weekday
        var reordered: [String] = []
        for i in 0..<7 {
            let index = (firstWeekday - 1 + i) % 7
            reordered.append(symbols[index])
        }
        return reordered
    }

    /// Builds all week rows for a given month
    private func buildWeeks(for monthDate: Date) -> [CalendarWeekModel] {
        // Get the first day of the month
        var components = calendar.dateComponents([.year, .month], from: monthDate)
        components.day = 1
        guard let firstDay = calendar.date(from: components) else { return [] }

        // Calculate which weekday the month starts on
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let calendarFirstWeekday = calendar.firstWeekday

        // Calculate leading empty cells
        let leadingEmptyCells = (firstWeekday - calendarFirstWeekday + 7) % 7

        // Get the number of days in the month
        guard let range = calendar.range(of: .day, in: .month, for: monthDate) else { return [] }
        let daysInMonth = range.count

        // Build the grid
        var weeks: [CalendarWeekModel] = []
        var currentDay = 1
        var weekIndex = 0

        while currentDay <= daysInMonth {
            var days: [CalendarDayModel] = []

            for dayIndex in 0..<7 {
                if weekIndex == 0 && dayIndex < leadingEmptyCells {
                    // Leading placeholder
                    days.append(.placeholder(id: "placeholder-leading-\(dayIndex)"))
                } else if currentDay <= daysInMonth {
                    // Actual day
                    var dayComponents = components
                    dayComponents.day = currentDay
                    let dayDate = calendar.date(from: dayComponents)
                    let isToday = dayDate.map { calendar.isDate($0, inSameDayAs: today) } ?? false

                    days.append(CalendarDayModel(
                        id: "\(components.year ?? 0)-\(components.month ?? 0)-\(currentDay)",
                        dayNumber: currentDay,
                        isToday: isToday,
                        isPlaceholder: false,
                        date: dayDate
                    ))
                    currentDay += 1
                } else {
                    // Trailing placeholder
                    days.append(.placeholder(id: "placeholder-trailing-\(dayIndex)-\(weekIndex)"))
                }
            }

            weeks.append(CalendarWeekModel(
                id: "week-\(weekIndex)",
                days: days
            ))
            weekIndex += 1
        }

        return weeks
    }
}

// MARK: - Date Extension for Convenience

extension Calendar {
    /// Gets the start of the day for a given date in this calendar
    func startOfDay(for date: Date) -> Date {
        return self.date(from: self.dateComponents([.year, .month, .day], from: date)) ?? date
    }
}
