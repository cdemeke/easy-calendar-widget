import XCTest
#if canImport(CalendarWidgetLogic)
@testable import CalendarWidgetLogic
#elseif canImport(CalendarWidgetExtension)
@testable import CalendarWidgetExtension
#endif

final class CalendarWidgetLogicTests: XCTestCase {
    func testSundayFirstWeekdaySymbolsStaySundayFirst() {
        let calendar = makeCalendar(localeIdentifier: "en_US_POSIX", firstWeekday: 1)
        let builder = CalendarMonthBuilder(calendar: calendar, referenceDate: makeDate(year: 2026, month: 1, day: 15, calendar: calendar))

        let month = builder.buildMonthModel(monthOffset: 0)

        XCTAssertEqual(month.weekdaySymbols, ["S", "M", "T", "W", "T", "F", "S"])
    }

    func testMondayFirstWeekdaySymbolsReorderForLocale() {
        let calendar = makeCalendar(localeIdentifier: "en_GB", firstWeekday: 2)
        let builder = CalendarMonthBuilder(calendar: calendar, referenceDate: makeDate(year: 2026, month: 1, day: 15, calendar: calendar))

        let month = builder.buildMonthModel(monthOffset: 0)

        XCTAssertEqual(month.weekdaySymbols, ["M", "T", "W", "T", "F", "S", "S"])
    }

    func testMonthGridAlignmentHandlesSundayStartInMondayFirstCalendar() throws {
        let calendar = makeCalendar(localeIdentifier: "en_GB", firstWeekday: 2)
        let builder = CalendarMonthBuilder(calendar: calendar, referenceDate: makeDate(year: 2025, month: 6, day: 15, calendar: calendar))

        let month = builder.buildMonthModel(monthOffset: 0)
        let firstWeek = try XCTUnwrap(month.weeks.first)

        XCTAssertEqual(firstWeek.days.prefix(6).map(\.isPlaceholder), [true, true, true, true, true, true])
        XCTAssertEqual(firstWeek.days[6].dayNumber, 1)
        XCTAssertFalse(firstWeek.days[6].isPlaceholder)
    }

    func testFebruaryDayCountsCoverLeapAndNonLeapYears() {
        let calendar = makeCalendar(localeIdentifier: "en_US_POSIX", firstWeekday: 1)

        let leapYearBuilder = CalendarMonthBuilder(calendar: calendar, referenceDate: makeDate(year: 2024, month: 2, day: 10, calendar: calendar))
        let nonLeapYearBuilder = CalendarMonthBuilder(calendar: calendar, referenceDate: makeDate(year: 2025, month: 2, day: 10, calendar: calendar))

        let leapYearMonth = leapYearBuilder.buildMonthModel(monthOffset: 0)
        let nonLeapYearMonth = nonLeapYearBuilder.buildMonthModel(monthOffset: 0)

        XCTAssertEqual(visibleDays(in: leapYearMonth).count, 29)
        XCTAssertEqual(visibleDays(in: nonLeapYearMonth).count, 28)
        XCTAssertEqual(visibleDays(in: leapYearMonth).last?.dayNumber, 29)
        XCTAssertEqual(visibleDays(in: nonLeapYearMonth).last?.dayNumber, 28)
    }

    func testMonthGridAlwaysPadsToSixRows() {
        let calendar = makeCalendar(localeIdentifier: "en_US_POSIX", firstWeekday: 1)
        let builder = CalendarMonthBuilder(calendar: calendar, referenceDate: makeDate(year: 2026, month: 2, day: 10, calendar: calendar))

        let month = builder.buildMonthModel(monthOffset: 0)

        XCTAssertEqual(month.weeks.count, 6)
        XCTAssertTrue(month.weeks[4].days.allSatisfy { $0.isPlaceholder })
        XCTAssertTrue(month.weeks[5].days.allSatisfy { $0.isPlaceholder })
    }

    func testRefreshBoundaryUpdatesOneMinuteAfterNextMidnight() {
        let calendar = makeCalendar(localeIdentifier: "en_US_POSIX", firstWeekday: 1)
        let calculator = TimelineRefreshCalculator(calendar: calendar)
        let date = makeDate(year: 2026, month: 4, day: 26, hour: 13, minute: 45, calendar: calendar)

        let nextUpdate = calculator.nextUpdateDate(from: date)

        XCTAssertEqual(nextUpdate, makeDate(year: 2026, month: 4, day: 27, hour: 0, minute: 1, calendar: calendar))
    }

    func testRefreshBoundaryHandlesMonthRollover() {
        let calendar = makeCalendar(localeIdentifier: "en_US_POSIX", firstWeekday: 1)
        let calculator = TimelineRefreshCalculator(calendar: calendar)
        let date = makeDate(year: 2026, month: 2, day: 28, hour: 23, minute: 59, calendar: calendar)

        let nextUpdate = calculator.nextUpdateDate(from: date)

        XCTAssertEqual(nextUpdate, makeDate(year: 2026, month: 3, day: 1, hour: 0, minute: 1, calendar: calendar))
    }

    private func visibleDays(in month: CalendarMonthModel) -> [CalendarDayModel] {
        month.weeks.flatMap(\.days).filter { !$0.isPlaceholder }
    }

    private func makeCalendar(localeIdentifier: String, firstWeekday: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: localeIdentifier)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    private func makeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 12,
        minute: Int = 0,
        calendar: Calendar
    ) -> Date {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components)!
    }
}
