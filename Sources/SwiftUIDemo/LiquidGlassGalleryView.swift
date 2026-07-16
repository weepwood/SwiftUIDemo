import SwiftUI

struct LiquidGlassGalleryView: View {
    var body: some View {
        Group {
            if #available(macOS 26.0, *) {
                ModernLiquidGlassGallery()
            } else {
                LegacyLiquidGlassGallery()
            }
        }
    }
}

@available(macOS 26.0, *)
private struct ModernLiquidGlassGallery: View {
    @Namespace private var glassNamespace
    @State private var isExpanded = true
    @State private var selectedAccent = DemoAccent.blue
    @State private var intensity = 0.62
    @State private var isEnabled = true

    private let actions = [
        GlassAction(title: "导入", symbol: "square.and.arrow.down"),
        GlassAction(title: "导出", symbol: "square.and.arrow.up"),
        GlassAction(title: "收藏", symbol: "star.fill")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero
                glassStyles
                morphingActions
                nativeControls
                implementationNotes
            }
            .padding(24)
            .frame(maxWidth: 1120)
            .frame(maxWidth: .infinity)
        }
        .background {
            LiquidGlassBackdrop()
        }
    }

    private var hero: some View {
        HStack(alignment: .center, spacing: 22) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 104, height: 104)

                Image(systemName: "drop.fill")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .shadow(color: .blue.opacity(0.24), radius: 24, y: 12)

            VStack(alignment: .leading, spacing: 8) {
                Text("Liquid Glass")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text("使用 macOS 26+ 原生 SwiftUI API 构建会折射背景、自动适配明暗内容并支持流体过渡的玻璃界面。")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    Label("macOS 26+", systemImage: "checkmark.seal.fill")
                    Label("Xcode 26", systemImage: "hammer.fill")
                    Label("旧系统自动回退", systemImage: "arrow.triangle.branch")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            }

            Spacer(minLength: 0)
        }
        .padding(28)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
    }

    private var glassStyles: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                title: "玻璃样式",
                subtitle: "自定义形状和 tint 应只用于表达层级或语义，而不是装饰所有内容。",
                symbol: "square.3.layers.3d"
            )

            GlassEffectContainer {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 16) {
                        standardGlassSample
                        roundedGlassSample
                        tintedGlassSample
                    }

                    VStack(spacing: 16) {
                        standardGlassSample
                        roundedGlassSample
                        tintedGlassSample
                    }
                }
            }
        }
    }

    private var standardGlassSample: some View {
        GlassSample(
            title: "标准玻璃",
            detail: "默认胶囊形状",
            symbol: "capsule"
        )
        .glassEffect()
    }

    private var roundedGlassSample: some View {
        GlassSample(
            title: "自定义形状",
            detail: "连续圆角矩形",
            symbol: "rectangle.roundedtop"
        )
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
    }

    private var tintedGlassSample: some View {
        GlassSample(
            title: "语义强调",
            detail: selectedAccent.title,
            symbol: "paintpalette.fill"
        )
        .glassEffect(
            .regular.tint(selectedAccent.color),
            in: .rect(cornerRadius: 22)
        )
        .contextMenu {
            ForEach(DemoAccent.allCases) { accent in
                Button(accent.title) {
                    selectedAccent = accent
                }
            }
        }
    }

    private var morphingActions: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                title: "流体组合与过渡",
                subtitle: "GlassEffectContainer 让相邻玻璃共享采样区域，glassEffectID 负责元素展开和吸收动画。",
                symbol: "circle.hexagongrid.fill"
            )

            HStack {
                Spacer()

                GlassEffectContainer {
                    HStack(spacing: 12) {
                        if isExpanded {
                            ForEach(actions) { action in
                                Button(action.title, systemImage: action.symbol) {
                                    // Demonstration action.
                                }
                                .buttonStyle(.glass)
                                .glassEffectID(action.id, in: glassNamespace)
                            }
                        }

                        Button(
                            isExpanded ? "收起" : "展开",
                            systemImage: isExpanded ? "xmark" : "ellipsis"
                        ) {
                            withAnimation(.spring(response: 0.46, dampingFraction: 0.78)) {
                                isExpanded.toggle()
                            }
                        }
                        .buttonStyle(.glassProminent)
                        .glassEffectID("action-toggle", in: glassNamespace)
                    }
                    .controlSize(.large)
                }

                Spacer()
            }
            .padding(.vertical, 22)
        }
        .padding(22)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    private var nativeControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "原生控件",
                subtitle: "使用 Xcode 26 SDK 构建后，按钮、分段选择器、滑块和开关会自动采用新的系统设计。",
                symbol: "switch.2"
            )

            Picker("强调色", selection: $selectedAccent) {
                ForEach(DemoAccent.allCases) { accent in
                    Text(accent.title).tag(accent)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 12) {
                Button("普通操作", systemImage: "sparkles") {}
                    .buttonStyle(.glass)

                Button("主要操作", systemImage: "arrow.right.circle.fill") {}
                    .buttonStyle(.glassProminent)
            }
            .controlSize(.large)

            LabeledContent("玻璃强度示意") {
                Slider(value: $intensity, in: 0...1, step: 0.1)
                    .frame(maxWidth: 340)
            }

            Toggle("启用实时玻璃效果", isOn: $isEnabled)
        }
        .padding(22)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    private var implementationNotes: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "使用原则",
                subtitle: "内容保持在底层，玻璃用于导航、工具和临时操作层。",
                symbol: "lightbulb.max.fill"
            )

            Label("优先使用 NavigationSplitView、Toolbar、Inspector 和标准控件，让系统自动适配。", systemImage: "checkmark.circle")
            Label("相邻自定义玻璃放入同一个 GlassEffectContainer，避免采样不一致。", systemImage: "checkmark.circle")
            Label("不要在工具栏背后叠加额外 Material 或深色遮罩，以免干扰系统滚动边缘效果。", systemImage: "checkmark.circle")
            Label("macOS 14 和 15 使用 Material 回退，功能和信息层级保持一致。", systemImage: "checkmark.circle")
        }
        .font(.subheadline)
        .padding(22)
        .adaptiveGlass(cornerRadius: 24)
    }

    private func sectionHeader(title: String, subtitle: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(title, systemImage: symbol)
                .font(.title2.bold())
            Text(subtitle)
                .foregroundStyle(.secondary)
        }
    }
}

private struct LegacyLiquidGlassGallery: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Label("Liquid Glass 兼容模式", systemImage: "drop.fill")
                    .font(.largeTitle.bold())

                Text("当前系统低于 macOS 26，因此页面使用 Material 模拟层次。升级到 macOS 26 或更高版本后，同一份应用会自动启用原生 glassEffect、玻璃按钮和流体组合动画。")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    Label("最低运行版本仍为 macOS 14", systemImage: "desktopcomputer")
                    Label("不需要维护两套业务逻辑", systemImage: "arrow.triangle.branch")
                    Label("新旧系统保持相同的信息结构", systemImage: "rectangle.3.group")
                }
                .padding(22)
                .adaptiveGlass(cornerRadius: 22)

                HStack(spacing: 12) {
                    Button("普通操作") {}
                        .adaptiveGlassButtonStyle()
                    Button("主要操作") {}
                        .adaptiveGlassButtonStyle(prominent: true)
                }
                .controlSize(.large)
            }
            .padding(30)
            .frame(maxWidth: 820, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background {
            LiquidGlassBackdrop()
        }
    }
}

private struct GlassSample: View {
    let title: String
    let detail: String
    let symbol: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title2)
                .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
    }
}

private struct GlassAction: Identifiable {
    let id = UUID()
    let title: String
    let symbol: String
}

private struct LiquidGlassBackdrop: View {
    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)

            LinearGradient(
                colors: [
                    .cyan.opacity(0.16),
                    .blue.opacity(0.08),
                    .purple.opacity(0.13),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.cyan.opacity(0.22))
                .frame(width: 340, height: 340)
                .blur(radius: 74)
                .offset(x: -330, y: -240)

            Circle()
                .fill(.purple.opacity(0.18))
                .frame(width: 420, height: 420)
                .blur(radius: 92)
                .offset(x: 360, y: 270)
        }
        .ignoresSafeArea()
    }
}
