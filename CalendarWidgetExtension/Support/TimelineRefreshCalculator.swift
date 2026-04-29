import Foundation

/// Calculates when the widget should refresh to keep the highlighted day accurate.
struct TimelineRefreshCalculator {
    private let calendar: Calendar
    private let postMidnightBuffer: TimeInterval

    init(calendar: Calendar = .current, postMidnightBuffer: TimeInterval = 60) {
        self.calendar = calendar
        self.postMidnightBuffer = postMidnightBuffer
    }

    /// Returns a refresh date shortly after the next local midnight.
    func nextUpdateDate(from date: Date) -> Date {
        guard let startOfNextDay = calendar.dateInterval(of: .day, for: date)?.end else {
            return date.addingTimeInterval(24 * 60 * 60)
        }

        return startOfNextDay.addingTimeInterval(postMidnightBuffer)
    }
}
