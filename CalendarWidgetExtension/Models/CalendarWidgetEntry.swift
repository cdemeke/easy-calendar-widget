import Foundation
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
