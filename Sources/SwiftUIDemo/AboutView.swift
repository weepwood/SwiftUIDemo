import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openURL) private var openURL

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "开发版"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "local"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(.tint.gradient)
                        .frame(width: 112, height: 112)
                    Image(systemName: "swift")
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .shadow(color: .black.opacity(0.16), radius: 20, y: 10)

                VStack(spacing: 6) {
                    Text("SwiftUI Demo")
                        .font(.largeTitle.bold())
                    Text("版本 \(version)（\(build)）")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("一个面向 macOS 的原生功能展示应用，覆盖现代 SwiftUI 导航、控件、数据可视化、文件处理、通知、菜单栏、设置与多窗口能力。")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 520)

                HStack(spacing: 18) {
                    FeatureBadge(title: "SwiftUI", symbol: "swift")
                    FeatureBadge(title: "Swift Charts", symbol: "chart.xyaxis.line")
                    FeatureBadge(title: "AppKit", symbol: "macwindow")
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Label("项目特点", systemImage: "checkmark.seal")
                        .font(.headline)
                    Label("纯原生实现，不包含第三方运行时依赖", systemImage: "checkmark.circle")
                    Label("支持 Intel 与 Apple Silicon 的 Universal 构建", systemImage: "cpu")
                    Label("通过 GitHub Actions 自动生成 ZIP 与 DMG", systemImage: "shippingbox")
                    Label("MIT 开源协议，可直接学习与复用", systemImage: "doc.text")
                }
                .frame(maxWidth: 520, alignment: .leading)
                .font(.subheadline)

                HStack {
                    Button("查看 GitHub") {
                        if let url = URL(string: "https://github.com/weepwood/SwiftUIDemo") {
                            openURL(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("重置示例数据") {
                        model.resetDemoData()
                    }
                }
            }
            .padding(34)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct FeatureBadge: View {
    let title: String
    let symbol: String

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(.quaternary, in: Capsule())
    }
}
