import SwiftUI

struct RootView: View {
    @EnvironmentObject private var model: AppModel
    @AppStorage("accent") private var accentRawValue = DemoAccent.blue.rawValue
    @AppStorage("appearance") private var appearanceRawValue = DemoAppearance.system.rawValue

    private var accent: DemoAccent {
        DemoAccent(rawValue: accentRawValue) ?? .blue
    }

    private var appearance: DemoAppearance {
        DemoAppearance(rawValue: appearanceRawValue) ?? .system
    }

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
                .navigationTitle(model.selectedSection?.title ?? "SwiftUI Demo")
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button {
                            model.resetDemoData()
                        } label: {
                            Label("重置数据", systemImage: "arrow.counterclockwise")
                        }
                        .help("恢复内置示例数据")

                        Button {
                            model.isInspectorPresented.toggle()
                        } label: {
                            Label("检查器", systemImage: "sidebar.trailing")
                        }
                        .help("显示或隐藏检查器")
                    }
                }
                .inspector(isPresented: $model.isInspectorPresented) {
                    InspectorView()
                        .environmentObject(model)
                        .inspectorColumnWidth(min: 220, ideal: 260, max: 320)
                }
        }
        .navigationSplitViewStyle(.balanced)
        .tint(accent.color)
        .preferredColorScheme(appearance.colorScheme)
        .frame(minWidth: 900, minHeight: 620)
    }

    private var sidebar: some View {
        List(DemoSection.allCases, selection: $model.selectedSection) { section in
            Label(section.title, systemImage: section.symbol)
                .tag(section)
        }
        .navigationTitle("SwiftUI Demo")
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 5) {
                Divider()
                Label("macOS 14+", systemImage: "desktopcomputer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("纯 SwiftUI · 无第三方依赖")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch model.selectedSection ?? .overview {
        case .overview:
            DashboardView()
        case .controls:
            ControlsGalleryView()
        case .data:
            DataGalleryView()
        case .system:
            SystemGalleryView()
        case .about:
            AboutView()
        }
    }
}

private struct InspectorView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Form {
            Section("当前页面") {
                LabeledContent("名称", value: model.selectedSection?.title ?? "未选择")
                LabeledContent("图标") {
                    Image(systemName: model.selectedSection?.symbol ?? "questionmark")
                }
            }

            Section("应用状态") {
                LabeledContent("数据记录", value: "\(model.records.count)")
                LabeledContent("活动日志", value: "\(model.activity.count)")
                LabeledContent("检查器", value: model.isInspectorPresented ? "已显示" : "已隐藏")
            }

            Section("提示") {
                Text("此检查器使用 macOS 原生 Inspector API，可随窗口宽度自动折叠。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding(.vertical, 8)
    }
}
