import SwiftUI
import UIKit

@main
struct ScreenshotTestApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

private struct ScreenshotSettings: Codable {
    var alertsEnabled = true
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var alertsEnabled = true
    @State private var screenshotCount = 0
    @State private var showAlert = false

    private var settingsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ScreenshotSettings.plist")
    }

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Show screenshot alert", isOn: $alertsEnabled)
                    .onChange(of: alertsEnabled) { _, enabled in
                        saveSettings(enabled)
                        if !enabled { showAlert = false }
                    }
                LabeledContent("Screenshot events", value: "\(screenshotCount)")
                Text("Test file: Documents/ScreenshotSettings.plist. Set alertsEnabled to false in 3105, then reopen this app.")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Screenshot Test")
            .alert("Screenshot detected", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .onAppear(perform: loadSettings)
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { loadSettings() }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
                screenshotCount += 1
                if alertsEnabled { showAlert = true }
            }
        }
    }

    private func loadSettings() {
        guard let data = try? Data(contentsOf: settingsURL),
              let settings = try? PropertyListDecoder().decode(ScreenshotSettings.self, from: data) else {
            saveSettings(true)
            return
        }
        alertsEnabled = settings.alertsEnabled
    }

    private func saveSettings(_ enabled: Bool) {
        let settings = ScreenshotSettings(alertsEnabled: enabled)
        guard let data = try? PropertyListEncoder().encode(settings) else { return }
        try? data.write(to: settingsURL, options: .atomic)
    }
}
