import Charts
import SwiftUI

struct DataGalleryView: View {
    @EnvironmentObject private var model: AppModel

    @State private var query = ""
    @State private var showOnlyActive = false
    @State private var selection = Set<DemoRecord.ID>()
    @State private var chartMetric = ChartMetric.requests
    @State private var isAddRecordPresented = false

    private var filteredRecords: [DemoRecord] {
        model.records.filter { record in
            record.matches(query: query) && (!showOnlyActive || record.isActive)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            ViewThatFits(in: .vertical) {
                VStack(spacing: 16) {
                    chartCard
                        .frame(minHeight: 280)
                    tableCard
                        .frame(minHeight: 280)
                }
                .padding(20)

                ScrollView {
                    VStack(spacing: 16) {
                        chartCard
                            .frame(height: 320)
                        tableCard
                            .frame(height: 340)
                    }
                    .padding(20)
                }
            }
        }
        .background(.background.secondary)
        .searchable(text: $query, placement: .toolbar, prompt: "搜索名称、分类或数量")
        .sheet(isPresented: $isAddRecordPresented) {
            AddRecordSheet { record in
                model.records.append(record)
                model.addActivity(title: "新增数据记录", detail: record.name, symbol: "plus.square.fill")
            }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("数据工作台")
                    .font(.title2.bold())
                Text("Swift Charts、Table、搜索、选择与状态筛选")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("仅活跃", isOn: $showOnlyActive)
                .toggleStyle(.switch)

            Button {
                isAddRecordPresented = true
            } label: {
                Label("新增记录", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.bar)
    }

    private var chartCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chartMetric.title)
                            .font(.headline)
                        Text("最近 14 天演示数据")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Picker("指标", selection: $chartMetric) {
                        ForEach(ChartMetric.allCases) { metric in
                            Text(metric.shortTitle).tag(metric)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 220)
                }

                Chart(ChartPoint.samples) { point in
                    switch chartMetric {
                    case .requests:
                        BarMark(
                            x: .value("日期", point.date, unit: .day),
                            y: .value("请求数", point.requests)
                        )
                        .foregroundStyle(Color.accentColor.gradient)
                        .cornerRadius(4)
                    case .latency:
                        LineMark(
                            x: .value("日期", point.date, unit: .day),
                            y: .value("延迟", point.latency)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .foregroundStyle(.tint)
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("日期", point.date, unit: .day),
                            y: .value("延迟", point.latency)
                        )
                        .foregroundStyle(Color.accentColor.opacity(0.12).gradient)
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 2)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartYScale(domain: chartMetric.domain)
                .accessibilityLabel(chartMetric.title)
            }
            .padding(.top, 4)
        }
    }

    private var tableCard: some View {
        GroupBox {
            VStack(spacing: 10) {
                HStack {
                    Text("共 \(filteredRecords.count) 条记录")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if !selection.isEmpty {
                        Text("已选择 \(selection.count) 项")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.tint)

                        Button("删除", role: .destructive) {
                            model.records.removeAll { selection.contains($0.id) }
                            selection.removeAll()
                            model.addActivity(title: "删除数据记录", detail: "已移除所选项目", symbol: "trash")
                        }
                        .controlSize(.small)
                    }
                }

                Table(filteredRecords, selection: $selection) {
                    TableColumn("名称", value: \.name)
                    TableColumn("分类", value: \.category)
                    TableColumn("数量") { record in
                        Text(record.count, format: .number)
                            .monospacedDigit()
                    }
                    .width(min: 70, ideal: 90, max: 120)
                    TableColumn("状态") { record in
                        Label(record.isActive ? "活跃" : "停用", systemImage: record.isActive ? "checkmark.circle.fill" : "pause.circle")
                            .foregroundStyle(record.isActive ? .green : .secondary)
                    }
                    .width(min: 90, ideal: 110, max: 150)
                    TableColumn("更新时间") { record in
                        Text(record.updatedAt, style: .relative)
                            .foregroundStyle(.secondary)
                    }
                    .width(min: 100, ideal: 130, max: 180)
                }
                .contextMenu(forSelectionType: DemoRecord.ID.self) { selectedIDs in
                    if !selectedIDs.isEmpty {
                        Button("切换状态", systemImage: "arrow.triangle.2.circlepath") {
                            for index in model.records.indices where selectedIDs.contains(model.records[index].id) {
                                model.records[index].isActive.toggle()
                            }
                        }

                        Divider()

                        Button("删除", systemImage: "trash", role: .destructive) {
                            model.records.removeAll { selectedIDs.contains($0.id) }
                            selection.subtract(selectedIDs)
                        }
                    }
                } primaryAction: { selectedIDs in
                    if let id = selectedIDs.first,
                       let index = model.records.firstIndex(where: { $0.id == id }) {
                        model.records[index].isActive.toggle()
                    }
                }
            }
        } label: {
            Label("原生表格", systemImage: "tablecells")
                .font(.headline)
        }
    }
}

private enum ChartMetric: String, CaseIterable, Identifiable {
    case requests
    case latency

    var id: String { rawValue }

    var title: String {
        switch self {
        case .requests: "每日请求数量"
        case .latency: "平均响应延迟"
        }
    }

    var shortTitle: String {
        switch self {
        case .requests: "请求量"
        case .latency: "延迟"
        }
    }

    var domain: ClosedRange<Double> {
        switch self {
        case .requests: 0...260
        case .latency: 80...230
        }
    }
}

private struct AddRecordSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category = "界面"
    @State private var count = 1
    @State private var isActive = true

    let onSave: (DemoRecord) -> Void

    private let categories = ["界面", "数据", "文件", "系统", "效率"]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("新增记录")
                .font(.title2.bold())

            Form {
                TextField("名称", text: $name)
                Picker("分类", selection: $category) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                Stepper("数量：\(count)", value: $count, in: 1...999)
                Toggle("活跃状态", isOn: $isActive)
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button("取消", role: .cancel) {
                    dismiss()
                }
                Button("保存") {
                    onSave(DemoRecord(
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        category: category,
                        count: count,
                        updatedAt: .now,
                        isActive: isActive
                    ))
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 460, height: 360)
    }
}
