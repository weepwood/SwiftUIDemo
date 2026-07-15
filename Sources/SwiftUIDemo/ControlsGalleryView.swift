import SwiftUI

struct ControlsGalleryView: View {
    @EnvironmentObject private var model: AppModel

    @State private var name = "SwiftUI Demo"
    @State private var email = "demo@example.com"
    @State private var notes = "这是一个可编辑的多行文本区域。"
    @State private var isEnabled = true
    @State private var volume = 0.72
    @State private var count = 3
    @State private var selectedMode = "标准"
    @State private var selectedDate = Date()
    @State private var selectedColor = Color.blue
    @State private var progress = 0.64
    @State private var isAlertPresented = false
    @State private var isSheetPresented = false
    @State private var isPopoverPresented = false

    private let modes = ["紧凑", "标准", "宽松"]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 360), spacing: 16)], alignment: .leading, spacing: 16) {
                buttonsCard
                inputCard
                selectionCard
                valueCard
                menuCard
                feedbackCard
            }
            .padding(24)
        }
        .background(.background.secondary)
        .alert("原生警告框", isPresented: $isAlertPresented) {
            Button("取消", role: .cancel) { }
            Button("确认") {
                model.addActivity(title: "确认了警告框", detail: "Alert 操作已完成", symbol: "checkmark.circle")
            }
        } message: {
            Text("Alert 会自动匹配 macOS 的视觉样式与键盘交互。")
        }
        .sheet(isPresented: $isSheetPresented) {
            VStack(spacing: 16) {
                Image(systemName: "rectangle.portrait.and.arrow.forward")
                    .font(.system(size: 44))
                    .foregroundStyle(.tint)
                Text("原生 Sheet")
                    .font(.title.bold())
                Text("Sheet 会附着在当前窗口上，并保留父窗口上下文。")
                    .foregroundStyle(.secondary)
                Button("完成") {
                    isSheetPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(32)
            .frame(width: 430, height: 250)
        }
    }

    private var buttonsCard: some View {
        DemoGroupBox(title: "按钮与操作", symbol: "cursorarrow.click.2") {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Button("默认按钮") { }
                    Button("强调按钮") { }
                        .buttonStyle(.borderedProminent)
                    Button("破坏性操作", role: .destructive) { }
                        .buttonStyle(.bordered)
                }

                HStack(spacing: 10) {
                    Button {
                        isAlertPresented = true
                    } label: {
                        Label("显示 Alert", systemImage: "exclamationmark.bubble")
                    }

                    Button {
                        isSheetPresented = true
                    } label: {
                        Label("显示 Sheet", systemImage: "rectangle.portrait")
                    }

                    Button {
                        isPopoverPresented.toggle()
                    } label: {
                        Label("显示 Popover", systemImage: "rectangle.and.hand.point.up.left")
                    }
                    .popover(isPresented: $isPopoverPresented, arrowEdge: .bottom) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("原生 Popover")
                                .font(.headline)
                            Text("适合承载临时工具和上下文信息。")
                                .foregroundStyle(.secondary)
                        }
                        .padding(18)
                        .frame(width: 260)
                    }
                }

                HStack {
                    Button("小号") { }
                        .controlSize(.small)
                    Button("常规") { }
                        .controlSize(.regular)
                    Button("大号") { }
                        .controlSize(.large)
                }
            }
        }
    }

    private var inputCard: some View {
        DemoGroupBox(title: "文本输入", symbol: "text.cursor") {
            VStack(alignment: .leading, spacing: 12) {
                TextField("应用名称", text: $name)
                    .textFieldStyle(.roundedBorder)

                TextField("电子邮箱", text: $email)
                    .textFieldStyle(.roundedBorder)

                TextEditor(text: $notes)
                    .font(.body)
                    .frame(minHeight: 86)
                    .padding(6)
                    .background(.background, in: RoundedRectangle(cornerRadius: 7))
                    .overlay {
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(.separator, lineWidth: 1)
                    }

                LabeledContent("实时内容") {
                    Text(name.isEmpty ? "未输入" : name)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var selectionCard: some View {
        DemoGroupBox(title: "选择控件", symbol: "checklist") {
            VStack(alignment: .leading, spacing: 14) {
                Toggle("启用实时同步", isOn: $isEnabled)

                Picker("布局密度", selection: $selectedMode) {
                    ForEach(modes, id: \.self) { mode in
                        Text(mode).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Picker("显示模式", selection: $selectedMode) {
                    ForEach(modes, id: \.self) { mode in
                        Text(mode).tag(mode)
                    }
                }

                DatePicker("计划日期", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])

                ColorPicker("强调颜色", selection: $selectedColor, supportsOpacity: true)
            }
        }
    }

    private var valueCard: some View {
        DemoGroupBox(title: "数值与进度", symbol: "slider.horizontal.3") {
            VStack(alignment: .leading, spacing: 14) {
                LabeledContent("音量", value: volume, format: .percent)
                Slider(value: $volume, in: 0...1)

                Stepper("重复次数：\(count)", value: $count, in: 1...10)

                LabeledContent("任务进度") {
                    Text(progress, format: .percent.precision(.fractionLength(0)))
                        .monospacedDigit()
                }
                ProgressView(value: progress)

                Gauge(value: volume) {
                    Text("资源")
                } currentValueLabel: {
                    Text(volume, format: .percent.precision(.fractionLength(0)))
                } minimumValueLabel: {
                    Text("0%")
                } maximumValueLabel: {
                    Text("100%")
                }
                .gaugeStyle(.accessoryLinearCapacity)
            }
        }
    }

    private var menuCard: some View {
        DemoGroupBox(title: "菜单与上下文", symbol: "menucard") {
            VStack(alignment: .leading, spacing: 14) {
                Menu("操作菜单") {
                    Button("新建记录", systemImage: "plus") {
                        model.addActivity(title: "新建记录", detail: "通过 Menu 触发", symbol: "plus.circle")
                    }
                    Button("复制", systemImage: "doc.on.doc") { }
                    Divider()
                    Button("删除", systemImage: "trash", role: .destructive) { }
                }

                Label("在此区域右键查看上下文菜单", systemImage: "cursorarrow.rays")
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(.quaternary.opacity(0.65), in: RoundedRectangle(cornerRadius: 10))
                    .contextMenu {
                        Button("复制标题", systemImage: "doc.on.doc") { }
                        Button("添加到收藏", systemImage: "star") { }
                        Divider()
                        Button("移除", systemImage: "trash", role: .destructive) { }
                    }

                ControlGroup {
                    Button { count = max(1, count - 1) } label: { Image(systemName: "minus") }
                    Text("\(count)")
                        .frame(minWidth: 28)
                    Button { count = min(10, count + 1) } label: { Image(systemName: "plus") }
                }
            }
        }
    }

    private var feedbackCard: some View {
        DemoGroupBox(title: "状态反馈", symbol: "waveform.path.ecg") {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Label("运行正常", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Label("需要注意", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Label("已暂停", systemImage: "pause.circle.fill")
                        .foregroundStyle(.secondary)
                }

                ContentUnavailableView {
                    Label("暂无更多内容", systemImage: "tray")
                } description: {
                    Text("ContentUnavailableView 用于统一空状态展示。")
                } actions: {
                    Button("重新载入") {
                        progress = min(1, progress + 0.1)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 150)
            }
        }
    }
}

private struct DemoGroupBox<Content: View>: View {
    let title: String
    let symbol: String
    @ViewBuilder let content: Content

    init(title: String, symbol: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.symbol = symbol
        self.content = content()
    }

    var body: some View {
        GroupBox {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        } label: {
            Label(title, systemImage: symbol)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
