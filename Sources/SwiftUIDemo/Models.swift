import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DemoRecord: Identifiable, Hashable {
    let id: UUID
    var name: String
    var category: String
    var count: Int
    var updatedAt: Date
    var isActive: Bool

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        count: Int,
        updatedAt: Date,
        isActive: Bool
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.count = count
        self.updatedAt = updatedAt
        self.isActive = isActive
    }

    func matches(query: String) -> Bool {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return true }

        return name.localizedCaseInsensitiveContains(normalized)
            || category.localizedCaseInsensitiveContains(normalized)
            || String(count).contains(normalized)
    }

    static let samples: [DemoRecord] = [
        DemoRecord(name: "设计系统", category: "界面", count: 128, updatedAt: .now.addingTimeInterval(-900), isActive: true),
        DemoRecord(name: "同步任务", category: "后台", count: 42, updatedAt: .now.addingTimeInterval(-3_600), isActive: true),
        DemoRecord(name: "导出记录", category: "文件", count: 316, updatedAt: .now.addingTimeInterval(-7_200), isActive: false),
        DemoRecord(name: "通知中心", category: "系统", count: 27, updatedAt: .now.addingTimeInterval(-18_000), isActive: true),
        DemoRecord(name: "快捷操作", category: "效率", count: 86, updatedAt: .now.addingTimeInterval(-86_400), isActive: true),
        DemoRecord(name: "图表数据", category: "可视化", count: 204, updatedAt: .now.addingTimeInterval(-172_800), isActive: false)
    ]
}

struct ActivityItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
    let symbol: String
    let date: Date
}

struct ChartPoint: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let requests: Int
    let latency: Double

    static let samples: [ChartPoint] = {
        let calendar = Calendar.current
        return (0..<14).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset - 13, to: .now) else {
                return nil
            }
            let wave = sin(Double(offset) * 0.72)
            return ChartPoint(
                date: date,
                requests: 90 + offset * 9 + Int(wave * 24),
                latency: 118 + Double((offset * 17) % 75) + wave * 14
            )
        }
    }()
}

enum DemoSection: String, CaseIterable, Identifiable {
    case overview
    case controls
    case data
    case system
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: "概览"
        case .controls: "原生控件"
        case .data: "数据与图表"
        case .system: "系统能力"
        case .about: "关于应用"
        }
    }

    var symbol: String {
        switch self {
        case .overview: "rectangle.3.group"
        case .controls: "switch.2"
        case .data: "chart.xyaxis.line"
        case .system: "macwindow.on.rectangle"
        case .about: "info.circle"
        }
    }
}

enum DemoAccent: String, CaseIterable, Identifiable {
    case blue
    case purple
    case orange
    case green
    case pink

    var id: String { rawValue }

    var title: String {
        switch self {
        case .blue: "蓝色"
        case .purple: "紫色"
        case .orange: "橙色"
        case .green: "绿色"
        case .pink: "粉色"
        }
    }

    var color: Color {
        switch self {
        case .blue: .blue
        case .purple: .purple
        case .orange: .orange
        case .green: .green
        case .pink: .pink
        }
    }
}

enum DemoAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "跟随系统"
        case .light: "浅色"
        case .dark: "深色"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

struct DemoTextDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText, .json] }

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let text = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.text = text
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = text.data(using: .utf8) else {
            throw CocoaError(.fileWriteInapplicableStringEncoding)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
