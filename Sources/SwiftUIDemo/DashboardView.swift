import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings
    @State private var isWelcomePresented = false

    private let columns = [
        GridItem(.adaptive(minimum: 210), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero

                LazyVGrid(columns: columns, spacing: 14) {
                    MetricCard(title: "原生页面", value: "6", detail: "包含 Liquid Glass 专页", symbol: "macwindow")
                    MetricCard(title: "示例记录", value: "\(model.records.count)", detail: "Table、搜索与排序", symbol: "tablecells")
                    MetricCard(title: "系统集成", value: "6", detail: "文件、通知、剪贴板", symbol: "puzzlepiece.extension")
                    MetricCard(title: "外部依赖", value: "0", detail: "完全使用 Apple 框架", symbol: "checkmark.seal")
                }

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 16) {
                        activityCard
                        quickActionsCard
                    }
                    VStack(spacing: 16) {
                        activityCard
                        quickActionsCard
                    }
                }
            }
            .padding(24)
        }
        .background {
            DashboardBackdrop()
        }
        .sheet(isPresented: $isWelcomePresented) {
            WelcomeSheet()
        }
    }

    private var hero: some View {
        HStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.accentColor.gradient)
                    .frame(width: 94, height: 94)

                Image(systemName: "swift")
                    .font(.system(size: 45, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .shadow(color: .black.opacity(0.12), radius: 18, y: 8)

            VStack(alignment: .leading, spacing: 8) {
                Text("探索 macOS 原生体验")
                    .font(.system(size: 30, weight: .bold, design: .rounded))

                Text("集中展示 SwiftUI 控件、Liquid Glass、数据视图、系统集成、窗口管理与设置场景。")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    Button("体验液态玻璃") {
                        model.selectedSection = .liquidGlass
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("查看介绍") {
                        isWelcomePresented = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(.top, 4)
            }

            Spacer(minLength: 0)
        }
        .padding(24)
        .adaptiveGlass(cornerRadius: 20)
    }

    private var activityCard: some View {
        GroupBox("最近活动") {
            VStack(spacing: 0) {
                ForEach(Array(model.activity.prefix(5).enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 12) {
                        Image(systemName: item.symbol)
                            .frame(width: 28, height: 28)
                            .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                            .foregroundStyle(.tint)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.subheadline.weight(.medium))
                            Text(item.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(item.date, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 9)

                    if index < min(model.activity.count, 5) - 1 {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity)
    }

    private var quickActionsCard: some View {
        GroupBox("快捷操作") {
            VStack(spacing: 10) {
                ActionRow(title: "体验 Liquid Glass", subtitle: "玻璃样式、按钮与流体过渡", symbol: "drop.fill") {
                    model.selectedSection = .liquidGlass
                }
                ActionRow(title: "打开控件画廊", subtitle: "浏览按钮、输入框和选择器", symbol: "switch.2") {
                    model.selectedSection = .controls
                }
                ActionRow(title: "查看数据视图", subtitle: "体验 Chart、Table 与搜索", symbol: "chart.bar.xaxis") {
                    model.selectedSection = .data
                }
                ActionRow(title: "打开设置", subtitle: "调整主题、强调色与菜单栏", symbol: "gearshape") {
                    openSettings()
                }
                ActionRow(title: "打开关于窗口", subtitle: "演示多窗口 Scene", symbol: "macwindow.badge.plus") {
                    openWindow(id: "about")
                }
            }
            .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let detail: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: symbol)
                    .font(.title3)
                    .foregroundStyle(.tint)
                Spacer()
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
            }
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.separator.opacity(0.35), lineWidth: 1)
        }
    }
}

private struct ActionRow: View {
    let title: String
    let subtitle: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.title3)
                    .frame(width: 32)
                    .foregroundStyle(.tint)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(10)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct WelcomeSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 54))
                .foregroundStyle(.tint)

            Text("SwiftUI Demo")
                .font(.largeTitle.bold())

            Text("此项目展示现代 macOS 原生能力，并在 macOS 26+ 上启用 Liquid Glass。所有页面均可直接阅读、修改和复用。")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 440)

            HStack(spacing: 18) {
                Label("Liquid Glass", systemImage: "drop.fill")
                Label("Swift Charts", systemImage: "chart.xyaxis.line")
                Label("System APIs", systemImage: "gearshape.2")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Button("继续") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(36)
        .frame(width: 560, height: 340)
    }
}

private struct DashboardBackdrop: View {
    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)

            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.12),
                    .clear,
                    .purple.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.accentColor.opacity(0.13))
                .frame(width: 360, height: 360)
                .blur(radius: 84)
                .offset(x: -360, y: -260)
        }
        .ignoresSafeArea()
    }
}
