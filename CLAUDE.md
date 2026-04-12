# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development

This is an Xcode project — open with `open EasyCalendarWidget.xcodeproj`, build with ⌘R.

**Command-line build (Release archive):**
```bash
xcodebuild archive -project EasyCalendarWidget.xcodeproj -scheme EasyCalendarWidget -configuration Release -archivePath build/EasyCalendarWidget.xcarchive
```

**Create distribution DMG:**
```bash
scripts/create_dmg.sh
```

There are no tests, linter, or formatter configured.

## Architecture

**Host app + Widget extension pattern.** The host app (`EasyCalendarWidget/`) is a minimal container that shows setup instructions. All real logic lives in the widget extension (`CalendarWidgetExtension/`).

The app runs as a background agent (`LSUIElement = YES`) — no Dock icon.

### Widget Extension Data Flow

1. **`CalendarWidgetBundle.swift`** — `@main` entry point, registers two widgets:
   - `CalendarWidget` — supports small, medium, large, extra-large
   - `SixMonthCalendarWidget` — extra-large only (6-month grid)

2. **`CalendarTimelineProvider`** (in `CalendarWidget.swift`) — produces a single `CalendarWidgetEntry` per day, refreshing at midnight. Precomputes 6 months of data at timeline generation time.

3. **`CalendarMonthBuilder.swift`** — pure date math using `Calendar.current`. Builds `CalendarMonthModel` arrays (4 or 6 months). Handles locale-aware weekday ordering and leading/trailing placeholder cells for grid alignment.

4. **`CalendarMonthModel.swift`** — data layer: `CalendarDayModel`, `CalendarWeekModel`, `CalendarMonthModel`, and `CalendarWidgetEntry` (which holds 6 months with named convenience accessors: `previousPreviousMonth` through `nextNextNextMonth`).

5. **Views** (`CalendarWidgetExtension/Views/`):
   - `MonthView.swift` — single month card rendering (title, weekday header, day grid, today highlight circle). Contains `WidgetSize` enum with size-specific dimensions.
   - `CalendarGridViews.swift` — layout compositions: `SingleMonthView`, `TwoMonthGridView`, `FourMonthGridView`, `SixMonthGridView`. `CalendarWidgetEntryView` dispatches to the right layout based on `widgetFamily`.

### Widget Sizes

| Size | Months | Layout | View |
|------|--------|--------|------|
| Small | 1 (current) | Single | `SingleMonthView` |
| Medium | 2 (prev + current) | Side-by-side | `TwoMonthGridView` |
| Large | 4 | 2×2 grid | `FourMonthGridView` |
| Extra Large | 6 | 3×2 grid | `SixMonthGridView` |

Extra-large requires macOS 14.0+ — there are conditional `#available` checks throughout.

### Styling

Neumorphism design using `ultraThinMaterial` backgrounds with subtle gradients and responsive shadows. Accent color for today highlight. All dimensions (font sizes, padding, corner radii) scale per `WidgetSize`.

## Platform Requirements

- macOS 13.0 minimum (extra-large needs 14.0)
- Xcode 15.0+
- Swift 5, SwiftUI, WidgetKit
- No external dependencies

## Release Process

Push a git tag matching `v*` → GitHub Actions (`.github/workflows/release.yml`) builds, signs with Developer ID, notarizes via `xcrun notarytool`, creates styled DMG, publishes GitHub Release.
