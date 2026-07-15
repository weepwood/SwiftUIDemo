import AppKit
import SwiftUI

@main
struct SwiftUIDemoApp: App {
    @StateObject private var model = AppModel()
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true

    var body: some Scene {
        WindowGroup("SwiftUI Demo", id: "main") {
            RootView()
                .environmentObject(model)
        }
        .defaultSize(width: 1180, height: 760)
        .windowResizability(.contentMinSize)
        .windowToolbarStyle(.unifiedCompact)
        .commands {
            DemoCommands(model: model)
        }

        Settings {
            SettingsView()
                .environmentObject(model)
                .frame(width: 560, height: 430)
        }

        Window("关于 SwiftUI Demo", id: "about") {
            AboutView()
                .environmentObject(model)
                .frame(minWidth: 520, minHeight: 420)
        }
        .windowResizability(.contentSize)

        MenuBarExtra("SwiftUI Demo", systemImage: "swift", isInserted: $showMenuBarExtra) {
            MenuBarView()
                .environmentObject(model)
        }
        .menuBarExtraStyle(.window)
    }
}

struct DemoCommands: Commands {
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var model: AppModel

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("打开主窗口") {
                openWindow(id: "main")
            }
            .keyboardShortcut("1", modifiers: [.command])
        }

        CommandMenu("演示") {
            Button("显示概览") {
                model.selectedSection = .overview
                openWindow(id: "main")
            }
            .keyboardShortcut("o", modifiers: [.command, .shift])

            Button("显示原生控件") {
                model.selectedSection = .controls
                openWindow(id: "main")
            }
            .keyboardShortcut("k", modifiers: [.command, .shift])

            Divider()

            Button("重置示例数据") {
                model.resetDemoData()
            }

            Button("关于 SwiftUI Demo") {
                openWindow(id: "about")
            }
        }
    }
}

private struct MenuBarView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "swift")
                    .font(.title2)
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text("SwiftUI Demo")
                        .font(.headline)
                    Text("macOS 原生能力展示")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            Button("打开主窗口") {
                openWindow(id: "main")
            }

            Button("打开设置") {
                openSettings()
            }

            Button("重置示例数据") {
                model.resetDemoData()
            }

            Divider()

            Button("退出 SwiftUI Demo") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(16)
        .frame(width: 260)
    }
}
