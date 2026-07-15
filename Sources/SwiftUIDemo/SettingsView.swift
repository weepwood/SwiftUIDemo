import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel

    @AppStorage("appearance") private var appearanceRawValue = DemoAppearance.system.rawValue
    @AppStorage("accent") private var accentRawValue = DemoAccent.blue.rawValue
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    @AppStorage("enableAnimations") private var enableAnimations = true
    @AppStorage("confirmDestructiveActions") private var confirmDestructiveActions = true

    var body: some View {
        TabView {
            Form {
                Section("应用行为") {
                    Toggle("启用界面动画", isOn: $enableAnimations)
                    Toggle("破坏性操作前确认", isOn: $confirmDestructiveActions)
                    Toggle("显示菜单栏图标", isOn: $showMenuBarExtra)
                }

                Section("演示数据") {
                    LabeledContent("当前记录", value: "\(model.records.count) 条")
                    Button("恢复默认数据") {
                        model.resetDemoData()
                    }
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("通用", systemImage: "gearshape")
            }

            Form {
                Section("外观") {
                    Picker("主题", selection: $appearanceRawValue) {
                        ForEach(DemoAppearance.allCases) { appearance in
                            Text(appearance.title).tag(appearance.rawValue)
                        }
                    }
                    .pickerStyle(.radioGroup)
                }

                Section("强调色") {
                    Picker("颜色", selection: $accentRawValue) {
                        ForEach(DemoAccent.allCases) { accent in
                            Label {
                                Text(accent.title)
                            } icon: {
                                Circle()
                                    .fill(accent.color)
                                    .frame(width: 12, height: 12)
                            }
                            .tag(accent.rawValue)
                        }
                    }
                    .pickerStyle(.radioGroup)
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("外观", systemImage: "paintbrush")
            }

            VStack(alignment: .leading, spacing: 18) {
                Label("快捷键", systemImage: "keyboard")
                    .font(.title2.bold())

                Grid(alignment: .leading, horizontalSpacing: 28, verticalSpacing: 12) {
                    shortcutRow("打开主窗口", "⌘1")
                    shortcutRow("显示概览", "⇧⌘O")
                    shortcutRow("显示原生控件", "⇧⌘K")
                    shortcutRow("打开设置", "⌘,")
                }

                Spacer()

                Text("更多命令可在系统菜单栏的“演示”菜单中查看。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(28)
            .tabItem {
                Label("快捷键", systemImage: "command")
            }
        }
        .padding(12)
    }

    @ViewBuilder
    private func shortcutRow(_ action: String, _ shortcut: String) -> some View {
        GridRow {
            Text(action)
            Text(shortcut)
                .font(.system(.body, design: .monospaced, weight: .semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
        }
    }
}
