import SwiftUI
import UIKit

@main
struct ScreenshotTestApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    @State private var alertsEnabled = true
    @State private var screenshotCount = 0
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Show screenshot alert", isOn: $alertsEnabled)
                LabeledContent("Screenshot events", value: "\(screenshotCount)")
                Text("Take a screenshot to test the alert. The counter records events in this session.")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Screenshot Test")
            .alert("Screenshot detected", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
                screenshotCount += 1
                if alertsEnabled { showAlert = true }
            }
            .onChange(of: alertsEnabled) { _, enabled in
                if !enabled { showAlert = false }
            }
        }
    }
}
