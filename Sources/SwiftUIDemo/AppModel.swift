import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published var selectedSection: DemoSection? = .overview
    @Published var isInspectorPresented = true
    @Published var records = DemoRecord.samples
    @Published var activity: [ActivityItem] = [
        ActivityItem(title: "应用已启动", detail: "SwiftUI 场景初始化完成", symbol: "bolt.fill", date: .now),
        ActivityItem(title: "示例数据已载入", detail: "已生成 6 条本地记录", symbol: "tray.full.fill", date: .now.addingTimeInterval(-300)),
        ActivityItem(title: "系统外观已同步", detail: "使用 macOS 当前外观设置", symbol: "circle.lefthalf.filled", date: .now.addingTimeInterval(-720))
    ]

    func resetDemoData() {
        records = DemoRecord.samples
        addActivity(title: "示例数据已重置", detail: "恢复到内置演示数据", symbol: "arrow.counterclockwise")
    }

    func addActivity(title: String, detail: String, symbol: String) {
        activity.insert(ActivityItem(title: title, detail: detail, symbol: symbol, date: .now), at: 0)
        if activity.count > 8 {
            activity.removeLast(activity.count - 8)
        }
    }
}
