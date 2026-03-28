# 黄金助手 (GoldenHelper) - iOS 原生版本

> 基于 SwiftUI 开发的投资收益计算工具

## 项目信息

- **版本**: 1.0.0
- **最低支持**: iOS 14.0
- **开发语言**: Swift 5.0
- **UI框架**: SwiftUI
- **设备支持**: iPhone / iPad

## 功能特性

### 1. 投资收益计算器 📊
- 输入持仓数量、成本均价、实时价格
- 支持加仓/减仓操作模拟
- 手续费计算（按比例/固定费用）
- 实时计算净盈利和收益率
- 一键确认加仓/卖出，自动更新持仓数据

### 2. 通用公式计算器 🧮
- 自定义公式创建和管理
- 使用英文变量名创建公式
- 预设公式模板（净收益、投资回报率、平均成本等）
- 自动保存计算结果和变量值

### 3. 设置 ⚙️
- 重量单位切换（克/盎司）
- 货币单位切换（人民币/美元）
- 深色模式支持
- 使用帮助和术语说明

## 项目结构

```
GoldenHelper_ios/
├── GoldenHelper.xcodeproj/     # Xcode 项目配置
├── GoldenHelper/
│   ├── GoldenHelperApp.swift   # App 入口
│   ├── ContentView.swift       # 主内容视图
│   ├── Info.plist              # 应用配置
│   ├── Assets.xcassets/        # 资源文件
│   ├── Models/
│   │   ├── Models.swift        # 数据模型定义
│   │   └── AppState.swift      # 全局状态管理
│   ├── Views/
│   │   ├── HomeView.swift      # 首页
│   │   ├── CalculatorView.swift    # 投资计算器
│   │   ├── FormulaView.swift       # 公式列表
│   │   ├── FormulaEditorView.swift # 公式编辑器
│   │   ├── FormulaCalculatorView.swift # 公式计算
│   │   └── SettingsView.swift      # 设置页面
│   └── Components/
│       ├── Theme.swift         # 主题和颜色
│       └── Components.swift    # 通用UI组件
└── README.md
```

## 开发说明

### 环境要求
- macOS 13.0+
- Xcode 15.0+
- iOS 14.0+ 设备或模拟器

### 构建步骤
1. 使用 Xcode 打开 `GoldenHelper.xcodeproj`
2. 选择目标设备（iPhone 模拟器或真机）
3. 点击运行按钮或按 `Cmd + R`

### 发布准备
根据 `iosapp策划书.md` 的要求：

1. **App 图标**: 需要准备 1024x1024 PNG 图标，放入 `Assets.xcassets/AppIcon.appiconset/`
2. **隐私政策**: 需要准备隐私政策链接
3. **截图**: 需要准备多尺寸应用截图
4. **ICP备案**: 如有联网功能需要备案（当前版本为纯本地应用）

## 符合 iOS 审核要求

- ✅ 支持 iOS 14+
- ✅ 支持 iPhone / iPad
- ✅ 支持暗黑模式 (Dark Mode)
- ✅ 支持动态字体 (Dynamic Type)
- ✅ 无第三方登录（无需 Sign in with Apple）
- ✅ 无网络请求（纯本地应用）
- ✅ 无内购功能
- ✅ 使用 UserDefaults 本地存储

## 从 uni-app 版本转换说明

原版本功能已完整迁移：
- 投资收益计算器 → `CalculatorView.swift`
- 通用公式计算器 → `FormulaView.swift` + 相关视图
- 设置页面 → `SettingsView.swift`
- 全局状态管理 → `AppState.swift`

移除的功能：
- VIP/付费功能（原版使用 uniCloud）
- 支付功能

## 当前公式模块说明

- 公式变量使用英文变量名，例如 `cost`、`price`、`amount`
- 当前版本仅输入变量名和值，不设置变量单位
- 保存公式时会校验空变量、重复变量、非法变量名和非法表达式

## 许可证

© 2024 GoldenHelper. All rights reserved.
