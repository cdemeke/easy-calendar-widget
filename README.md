# Easy Calendar Widget

A clean, minimal calendar widget for macOS that displays multiple months on your desktop or Notification Center.

## Features

- **Multiple Sizes**: Small (1 month), Medium (2 months), or Large (4 months) widget options
- **Today Highlight**: Current day is visually highlighted for quick reference
- **Daily Updates**: Automatically refreshes at midnight to update the current day
- **Dark Mode Support**: Adapts to your system appearance with light and dark themes
- **Locale Aware**: Respects your system calendar settings for weekday order and date formatting

## Screenshots

| Small | Medium | Large |
|-------|--------|-------|
| Current month | Previous + Current | 4-month grid (2x2) |

## Requirements

- macOS 13.0 or later
- Xcode 15.0+ (for building from source)

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/cdemeke/easy-calendar-widget.git
   cd easy-calendar-widget
   ```

2. Open the project in Xcode:
   ```bash
   open EasyCalendarWidget.xcodeproj
   ```

3. Build and run the project (⌘R)

4. Add the widget to your desktop:
   - Right-click on your desktop
   - Select "Edit Widgets..."
   - Find "Easy Calendar Widget" and drag it to your desktop

## Usage

Once installed, the host app provides instructions for adding the widget:

1. Right-click on your desktop
2. Select "Edit Widgets..."
3. Find "Easy Calendar Widget" in the widget gallery
4. Drag your preferred size to your desktop or Notification Center

## Project Structure

```
├── EasyCalendarWidget/              # Host application
│   ├── EasyCalendarWidgetApp.swift  # App entry point
│   └── ContentView.swift            # Setup instructions UI
│
├── CalendarWidgetExtension/         # Widget extension
│   ├── CalendarWidget.swift         # Widget definition & timeline
│   ├── Models/
│   │   └── CalendarMonthModel.swift # Data models
│   ├── Builders/
│   │   └── CalendarMonthBuilder.swift # Calendar logic
│   └── Views/
│       ├── MonthView.swift          # Single month view
│       └── CalendarGridViews.swift  # Multi-month layouts
```

## Tech Stack

- **Swift 5** & **SwiftUI**
- **WidgetKit** for widget functionality
- No external dependencies

## License

MIT License - See [LICENSE](LICENSE) for details.
