import SwiftUI

/// Main content view for the host application
/// Provides instructions for adding the widget
struct ContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // App icon
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 128)

            Text("Easy Calendar Widget")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("A clean, multi-month calendar for your desktop")
                .font(.title3)
                .foregroundStyle(.secondary)

            Divider()
                .padding(.vertical, 8)

            // Instructions
            VStack(alignment: .leading, spacing: 16) {
                InstructionRow(
                    number: 1,
                    title: "Add the Widget",
                    description: "Right-click on your desktop and select \"Edit Widgets\", or click the time in your menu bar."
                )

                InstructionRow(
                    number: 2,
                    title: "Find Easy Calendar",
                    description: "Search for \"Calendar\" or browse to find the Easy Calendar widget."
                )

                InstructionRow(
                    number: 3,
                    title: "Choose a Size",
                    description: "Small shows 1 month, Medium shows 2 months, Large shows 4 months in a grid."
                )

                InstructionRow(
                    number: 4,
                    title: "Place It",
                    description: "Drag the widget to your desired location on the desktop or in Notification Center."
                )
            }
            .padding(.horizontal)

            Spacer()

            Text("You can close this window — the widget will continue to work.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(32)
        .frame(minWidth: 500, minHeight: 500)
    }
}

/// A single instruction row with number, title, and description
struct InstructionRow: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Number badge
            Text("\(number)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(.tint))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    ContentView()
}
