import XCTest
@testable import SwiftUIDemo

final class AppModelTests: XCTestCase {
    func testRecordSearchMatchesNameAndCategory() {
        let record = DemoRecord(
            name: "设计系统",
            category: "界面",
            count: 128,
            updatedAt: .now,
            isActive: true
        )

        XCTAssertTrue(record.matches(query: "设计"))
        XCTAssertTrue(record.matches(query: "界面"))
        XCTAssertTrue(record.matches(query: "128"))
        XCTAssertFalse(record.matches(query: "通知"))
    }

    func testEmptySearchMatchesEveryRecord() {
        let record = DemoRecord.samples[0]
        XCTAssertTrue(record.matches(query: ""))
        XCTAssertTrue(record.matches(query: "   "))
    }

    @MainActor
    func testResetDemoDataRestoresSamples() {
        let model = AppModel()
        model.records.removeAll()

        model.resetDemoData()

        XCTAssertEqual(model.records.count, DemoRecord.samples.count)
        XCTAssertEqual(model.activity.first?.title, "示例数据已重置")
    }
}
