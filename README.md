# Easy Calendar Widget

A clean, minimal calendar widget for macOS that displays multiple months on your desktop or Notification Center.

**[View the overview site](https://date.chrisdemeke.com)**

## Download

**[Download the latest release (DMG)](https://github.com/cdemeke/easy-calendar-widget/releases/latest)** — macOS 13.0+

## Features

- **Clear Layout Options**: Choose **Calendar - 1 Month**, **Calendar - 2 Months**, **Calendar - 4 Months**, or **Calendar - 6 Months**
- **Connected Calendar Design**: Months share one clean panel with subtle dividers to maximize readable space
- **Today Highlight**: Current day is visually highlighted for quick reference
- **Daily Updates**: Automatically refreshes at midnight to update the current day
- **Dark Mode Support**: Adapts to your system appearance with light and dark themes
- **Locale Aware**: Respects your system calendar settings for weekday order and date formatting

## Screenshots

![Widget on Desktop](img/screenshot1.png)
*Calendar widget in Large size, showing a 4-month view on the desktop*

![Widget Gallery](img/screenshot2.png)
*Widget gallery with the Calendar widget and its available size options*

## Requirements

- macOS 13.0 or later

## Installation

### Option 1: Mac App Store (Recommended)

[**Download on the Mac App Store**](https://apps.apple.com/app/easy-calendar-widget) *(Coming soon - pending review)*

### Option 2: Direct Download

1. Go to the [Releases](https://github.com/cdemeke/easy-calendar-widget/releases/latest) page
2. Download the latest `EasyCalendarWidget.dmg`
3. Open the DMG and drag `EasyCalendarWidget.app` to your Applications folder
4. Open the app once (it runs silently with no dock icon)
5. Add the widget to your desktop:
   - Right-click on your desktop
   - Select "Edit Widgets..."
   - Search for "Calendar"
   - Choose **Calendar - 1 Month**, **Calendar - 2 Months**, **Calendar - 4 Months**, or **Calendar - 6 Months**
   - Drag your preferred widget to your desktop

### Option 3: Build from Source

Requires Xcode 15.0+

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
   - Search for "Calendar"
   - Choose **Calendar - 1 Month**, **Calendar - 2 Months**, **Calendar - 4 Months**, or **Calendar - 6 Months**
   - Drag your preferred widget to your desktop

## Usage

Once installed, the host app provides instructions for adding the widget:

1. Right-click on your desktop
2. Select "Edit Widgets..."
3. Search for **Calendar** in the widget gallery
4. Choose **Calendar - 1 Month**, **Calendar - 2 Months**, **Calendar - 4 Months**, or **Calendar - 6 Months**
5. Drag your preferred widget to your desktop or Notification Center

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
