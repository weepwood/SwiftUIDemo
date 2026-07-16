<div align="center">
  <img src="Packaging/AppIcon.svg" width="128" height="128" alt="SwiftUI Demo icon" />
  <h1>SwiftUI Demo</h1>
  <p>使用 SwiftUI 构建的 macOS 原生功能与 Liquid Glass 展示应用。</p>

  [![CI](https://github.com/weepwood/SwiftUIDemo/actions/workflows/ci.yml/badge.svg)](https://github.com/weepwood/SwiftUIDemo/actions/workflows/ci.yml)
  [![Release macOS](https://github.com/weepwood/SwiftUIDemo/actions/workflows/release.yml/badge.svg)](https://github.com/weepwood/SwiftUIDemo/actions/workflows/release.yml)
  [![macOS 14+](https://img.shields.io/badge/macOS-14%2B-black?logo=apple)](https://www.apple.com/macos/)
  [![Liquid Glass](https://img.shields.io/badge/Liquid%20Glass-macOS%2026%2B-3b82f6?logo=apple)](https://developer.apple.com/documentation/technologyoverviews/liquid-glass)
</div>

## 项目定位

SwiftUI Demo 是一个可直接运行和复用的 macOS 示例项目，集中展示现代原生应用常用能力。项目使用 Swift Package 管理，无第三方运行时依赖，可直接通过 Xcode 打开 `Package.swift`。

项目最低运行版本仍为 macOS 14：

- macOS 26 及更高版本启用原生 Liquid Glass。
- macOS 14 和 15 自动使用 Material 回退。
- 业务结构和功能在新旧系统中保持一致。

## 已实现功能

- `NavigationSplitView` 侧边栏、统一工具栏与原生 Inspector。
- Dashboard、原生控件画廊、Liquid Glass、数据工作台、系统能力与关于页面。
- `glassEffect`、自定义玻璃形状、语义 tint 和兼容修饰器。
- `.glass`、`.glassProminent` 按钮样式。
- `GlassEffectContainer` 与 `glassEffectID` 流体展开、吸收动画。
- Button、TextField、TextEditor、Toggle、Picker、DatePicker、ColorPicker、Slider、Stepper、Gauge、Alert、Sheet、Popover、Menu 和 Context Menu。
- Swift Charts 柱状图、折线图和面积图。
- 原生 Table、搜索、选择、批量删除和上下文操作。
- 文件导入/导出、剪贴板、本地通知、异步任务与系统信息。
- Settings Scene、MenuBarExtra、多窗口和菜单命令快捷键。
- 浅色/深色主题、强调色与菜单栏显示设置。

## Liquid Glass 兼容策略

项目通过 `AdaptiveGlass.swift` 封装新旧系统差异：

```swift
VStack {
    Text("Liquid Glass")
}
.padding(24)
.adaptiveGlass(cornerRadius: 24)
```

在 macOS 26+ 中实际调用：

```swift
.glassEffect(.regular, in: .rect(cornerRadius: 24))
```

在旧系统中自动回退为 `regularMaterial` 和系统分隔线。

相邻的自定义玻璃元素统一放入 `GlassEffectContainer`，避免多个玻璃表面各自采样导致视觉不一致。

## 本地运行

### Xcode

1. 使用 Xcode 26 或更高版本打开 `Package.swift`。
2. 选择 `SwiftUIDemo` Scheme。
3. 运行目标选择 `My Mac`，按 `⌘R` 启动。

Xcode 26 是编译 Liquid Glass API 的必要条件；生成的应用仍可运行在 macOS 14 及更高版本。

### 命令行

```bash
swift run SwiftUIDemo
```

## 自动构建与发布

仓库包含两条 GitHub Actions 工作流：

- `CI`：使用 macOS 26 Runner，在 Apple Silicon 与 Intel 环境中执行构建和测试。
- `Release macOS`：分别编译 arm64 与 x86_64，使用 `lipo` 合成 Universal 应用，并生成 `.zip`、`.dmg` 与 `SHA256SUMS.txt`。

发布规则：

- 合并或推送到 `main`：自动更新 `nightly` 预发布版本。
- 推送 `v*` 标签：自动创建正式 GitHub Release，例如：

```bash
git tag v1.1.0
git push origin v1.1.0
```

- 也可以从 Actions 页面手动运行 `Release macOS` 并填写版本号。
- Pull Request 会执行完整 Universal 打包验证，但不会发布 Release。

## 签名说明

自动工作流默认生成 ad-hoc 签名的应用，适合源码验证和本地测试。`scripts/package-app.sh` 仍保留 Developer ID 签名与 Apple 公证能力；需要正式分发时，可在受控 CI 或本地环境中提供对应签名变量。

首次打开 ad-hoc 签名构建时，如果系统提示无法验证开发者，可在“系统设置 → 隐私与安全性”中确认打开。

## 项目结构

```text
SwiftUIDemo/
├── Sources/SwiftUIDemo/
│   ├── AdaptiveGlass.swift          # macOS 14–26+ 兼容封装
│   ├── LiquidGlassGalleryView.swift # Liquid Glass 专用演示页
│   └── ...                          # 其他 SwiftUI 页面
├── Tests/SwiftUIDemoTests/          # 单元测试
├── Packaging/                       # Info.plist 与应用图标
├── scripts/package-app.sh           # Universal App、ZIP、DMG 打包脚本
├── .github/workflows/               # CI 与自动发布
└── Package.swift
```

## 开源协议

MIT License
