import AppKit
import SwiftUI
import UniformTypeIdentifiers
import UserNotifications

struct SystemGalleryView: View {
    @EnvironmentObject private var model: AppModel

    @State private var isImporterPresented = false
    @State private var isExporterPresented = false
    @State private var exportDocument = DemoTextDocument(text: "SwiftUI Demo 导出内容\n")
    @State private var importedPreview = "尚未导入文件"
    @State private var clipboardText = "SwiftUI Demo — macOS 原生应用示例"
    @State private var taskProgress = 0.0
    @State private var taskStatus = "等待开始"
    @State private var notificationStatus = "尚未请求权限"
    @State private var task: Task<Void, Never>?

    private let columns = [
        GridItem(.adaptive(minimum: 350), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                fileCard
                clipboardCard
                notificationCard
                taskCard
                systemInfoCard
                sharingCard
            }
            .padding(24)
        }
        .background(.background.secondary)
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.plainText, .json],
            allowsMultipleSelection: false
        ) { result in
            importFile(result)
        }
        .fileExporter(
            isPresented: $isExporterPresented,
            document: exportDocument,
            contentType: .plainText,
            defaultFilename: "SwiftUIDemo-Export"
        ) { result in
            switch result {
            case .success(let url):
                model.addActivity(title: "文件导出完成", detail: url.lastPathComponent, symbol: "square.and.arrow.up")
            case .failure(let error):
                model.addActivity(title: "文件导出失败", detail: error.localizedDescription, symbol: "xmark.octagon")
            }
        }
        .onDisappear {
            task?.cancel()
        }
    }

    private var fileCard: some View {
        SystemCard(title: "文件导入与导出", symbol: "folder.badge.gearshape") {
            VStack(alignment: .leading, spacing: 12) {
                Text("使用 SwiftUI 的 fileImporter 与 fileExporter，自动处理系统文件面板和沙盒授权。")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    Button("导入文本文件") {
                        isImporterPresented = true
                    }
                    Button("导出演示文件") {
                        exportDocument.text = exportText
                        isExporterPresented = true
                    }
                    .buttonStyle(.borderedProminent)
                }

                Text(importedPreview)
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(5)
                    .frame(maxWidth: .infinity, minHeight: 74, alignment: .topLeading)
                    .padding(10)
                    .background(.background, in: RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.separator, lineWidth: 1)
                    }
            }
        }
    }

    private var clipboardCard: some View {
        SystemCard(title: "剪贴板", symbol: "doc.on.clipboard") {
            VStack(alignment: .leading, spacing: 12) {
                TextField("要复制的内容", text: $clipboardText)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("复制到剪贴板") {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(clipboardText, forType: .string)
                        model.addActivity(title: "内容已复制", detail: clipboardText, symbol: "doc.on.doc")
                    }

                    Button("读取剪贴板") {
                        clipboardText = NSPasteboard.general.string(forType: .string) ?? "剪贴板中没有文本"
                    }
                }

                Label("使用 AppKit NSPasteboard 与 SwiftUI 状态双向联动", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var notificationCard: some View {
        SystemCard(title: "本地通知", symbol: "bell.badge") {
            VStack(alignment: .leading, spacing: 12) {
                Text(notificationStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("请求权限并发送通知") {
                    scheduleNotification()
                }
                .buttonStyle(.borderedProminent)

                Text("通知将在约 2 秒后投递。首次使用时 macOS 会显示权限请求。")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var taskCard: some View {
        SystemCard(title: "异步任务", symbol: "hourglass") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(taskStatus)
                    Spacer()
                    Text(taskProgress, format: .percent.precision(.fractionLength(0)))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: taskProgress)

                HStack {
                    Button("开始任务") {
                        startTask()
                    }
                    .disabled(task != nil)

                    Button("取消", role: .destructive) {
                        task?.cancel()
                        task = nil
                        taskStatus = "任务已取消"
                    }
                    .disabled(task == nil)
                }
            }
        }
    }

    private var systemInfoCard: some View {
        SystemCard(title: "系统信息", symbol: "desktopcomputer") {
            Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 10) {
                infoRow("操作系统", ProcessInfo.processInfo.operatingSystemVersionString)
                infoRow("设备名称", Host.current().localizedName ?? "未知")
                infoRow("处理器数量", "\(ProcessInfo.processInfo.processorCount)")
                infoRow("内存", ByteCountFormatter.string(fromByteCount: Int64(ProcessInfo.processInfo.physicalMemory), countStyle: .memory))
                infoRow("本地语言", Locale.current.localizedString(forIdentifier: Locale.current.identifier) ?? Locale.current.identifier)
            }
        }
    }

    private var sharingCard: some View {
        SystemCard(title: "共享与外部链接", symbol: "square.and.arrow.up") {
            VStack(alignment: .leading, spacing: 12) {
                if let repositoryURL = URL(string: "https://github.com/weepwood/SwiftUIDemo") {
                    ShareLink(item: repositoryURL) {
                        Label("共享项目地址", systemImage: "square.and.arrow.up")
                    }

                    Link(destination: repositoryURL) {
                        Label("在浏览器中打开 GitHub", systemImage: "safari")
                    }
                }

                Button("在 Finder 中显示下载目录") {
                    let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
                    if let downloads {
                        NSWorkspace.shared.activateFileViewerSelecting([downloads])
                    }
                }
            }
        }
    }

    private var exportText: String {
        let formatter = ISO8601DateFormatter()
        let lines = model.records.map { record in
            "- \(record.name) | \(record.category) | \(record.count) | \(record.isActive ? "活跃" : "停用")"
        }
        return ([
            "SwiftUI Demo 数据导出",
            "生成时间：\(formatter.string(from: .now))",
            "记录数量：\(model.records.count)",
            ""
        ] + lines).joined(separator: "\n")
    }

    @ViewBuilder
    private func infoRow(_ label: String, _ value: String) -> some View {
        GridRow {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .textSelection(.enabled)
        }
    }

    private func importFile(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else { return }
            let canAccess = url.startAccessingSecurityScopedResource()
            defer {
                if canAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let data = try Data(contentsOf: url)
            let text = String(data: data, encoding: .utf8) ?? "无法按 UTF-8 解码"
            importedPreview = String(text.prefix(500))
            model.addActivity(title: "文件导入完成", detail: url.lastPathComponent, symbol: "square.and.arrow.down")
        } catch {
            importedPreview = "导入失败：\(error.localizedDescription)"
        }
    }

    private func scheduleNotification() {
        Task {
            do {
                let center = UNUserNotificationCenter.current()
                let granted = try await center.requestAuthorization(options: [.alert, .sound])
                guard granted else {
                    notificationStatus = "通知权限未授予"
                    return
                }

                let content = UNMutableNotificationContent()
                content.title = "SwiftUI Demo"
                content.body = "这是一条由 macOS 原生 UserNotifications 发送的本地通知。"
                content.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                try await center.add(request)
                notificationStatus = "通知已安排，约 2 秒后投递"
                model.addActivity(title: "本地通知已安排", detail: "等待系统投递", symbol: "bell.badge.fill")
            } catch {
                notificationStatus = "通知失败：\(error.localizedDescription)"
            }
        }
    }

    private func startTask() {
        task?.cancel()
        taskProgress = 0
        taskStatus = "任务运行中"

        task = Task {
            for step in 1...20 {
                guard !Task.isCancelled else { return }
                try? await Task.sleep(for: .milliseconds(120))
                guard !Task.isCancelled else { return }
                taskProgress = Double(step) / 20
            }

            taskStatus = "任务已完成"
            task = nil
            model.addActivity(title: "异步任务完成", detail: "进度已达到 100%", symbol: "checkmark.seal.fill")
        }
    }
}

private struct SystemCard<Content: View>: View {
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
                .padding(.top, 5)
        } label: {
            Label(title, systemImage: symbol)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
