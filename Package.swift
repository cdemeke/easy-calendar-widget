// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EasyCalendarWidget",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CalendarWidgetLogic",
            targets: ["CalendarWidgetLogic"]
        )
    ],
    targets: [
        .target(
            name: "CalendarWidgetLogic",
            path: "CalendarWidgetExtension",
            exclude: [
                "Assets.xcassets",
                "CalendarWidget.swift",
                "CalendarWidgetBundle.swift",
                "CalendarWidgetExtension.entitlements",
                "Models/CalendarWidgetEntry.swift",
                "Info.plist",
                "Views"
            ],
            sources: [
                "Builders/CalendarMonthBuilder.swift",
                "Models/CalendarMonthModel.swift",
                "Support/TimelineRefreshCalculator.swift"
            ]
        ),
        .testTarget(
            name: "CalendarWidgetLogicTests",
            dependencies: ["CalendarWidgetLogic"]
        )
    ]
)
