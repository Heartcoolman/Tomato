# 项目结构说明

番茄计时器完整项目结构与文件说明。

## 📁 目录结构

```
TomatoTimer/
├── .github/
│   └── workflows/
│       └── build.yml                 # GitHub Actions 构建工作流
├── TomatoTimer/
│   ├── Models/                       # 数据模型
│   │   ├── TimerMode.swift          # 计时器模式枚举
│   │   ├── TimerState.swift         # 计时器状态枚举
│   │   └── PomodoroSession.swift    # 番茄会话记录
│   ├── Core/                         # 核心功能
│   │   ├── TimerEngine.swift        # 精准计时引擎
│   │   ├── NotificationManager.swift # 通知管理器
│   │   ├── HapticManager.swift      # 触觉反馈管理器
│   │   └── SoundManager.swift       # 声音管理器
│   ├── Stores/                       # 数据存储
│   │   ├── SettingsStore.swift      # 设置存储
│   │   ├── StatsStore.swift         # 统计数据存储
│   │   └── AppStateCoordinator.swift # 多窗口状态协调器
│   ├── Views/                        # 视图
│   │   ├── MainView.swift           # 主容器视图
│   │   ├── Timer/
│   │   │   ├── TimerView.swift      # 计时器页面
│   │   │   ├── CircularProgressView.swift # 圆环进度
│   │   │   └── TodayStatsView.swift # 今日统计
│   │   ├── History/
│   │   │   ├── HistoryView.swift    # 历史记录页面
│   │   │   └── WeekStatsView.swift  # 周统计
│   │   └── Settings/
│   │       └── SettingsView.swift   # 设置页面
│   ├── Utilities/                    # 工具类
│   │   ├── Colors.swift             # 颜色扩展
│   │   ├── CSVExporter.swift        # CSV 导出
│   │   └── AccessibilityHelpers.swift # 可访问性辅助
│   ├── Assets.xcassets/              # 资源文件
│   │   ├── AppIcon.appiconset/      # App 图标
│   │   ├── lightYellow.colorset/    # 背景颜色
│   │   └── Contents.json
│   ├── Info.plist                    # 应用配置
│   └── TomatoTimerApp.swift         # 应用入口
├── TomatoTimerTests/                 # 单元测试
│   ├── TimerEngineTests.swift       # 计时引擎测试
│   └── AutoSwitchTests.swift        # 自动切换测试
├── TomatoTimer.xcodeproj/            # Xcode 项目文件
│   └── project.pbxproj
├── ExportOptions.plist               # IPA 导出配置
├── README.md                         # 项目说明
├── FREE_ACCOUNT_GUIDE.md             # 免费账号使用指南
├── APP_ICON_DESIGN.md                # 图标设计指南
├── PROJECT_STRUCTURE.md              # 本文件
└── .gitignore                        # Git 忽略配置
```

## 🏗️ 架构说明

### MVVM + Actor 模式

```
View ← ObservableObject → ViewModel/Store
                              ↓
                          TimerEngine (Actor)
                              ↓
                          UserDefaults
```

### 数据流

```
用户操作 → View → TimerEngine → 状态更新 → @Published → View 刷新
                       ↓
                  UserDefaults (持久化)
                       ↓
                  StatsStore (统计)
```

## 📦 核心组件

### 1. TimerEngine（计时引擎）
**职责**：
- 精准计时（抗漂移）
- 状态机管理（idle/running/paused/completed）
- 自动切换逻辑（每 4 个番茄进入长休息）
- 状态持久化

**关键技术**：
- 使用目标结束时间（targetEndDate）避免累积误差
- Combine 框架的 Timer.publish
- @MainActor 确保线程安全

### 2. 多窗口支持（AppStateCoordinator）
**职责**：
- 管理全局唯一的 TimerEngine
- 协调多个 Scene 的状态
- 确保只有一个窗口可以控制计时器

**实现方式**：
- 单例模式
- NotificationCenter 广播
- @AppStorage 存储活动窗口 ID

### 3. 通知系统
**组件**：
- NotificationManager：本地通知
- SoundManager：蜂鸣音效
- HapticManager：触觉反馈

**触发时机**：
- 计时完成
- 模式切换（可选）

### 4. 数据持久化
**SettingsStore**：
- 使用 @AppStorage
- 自动保存设置
- 支持多窗口同步

**StatsStore**：
- UserDefaults + JSON
- 保存完成的番茄记录
- 计算统计数据

### 5. 可访问性
**支持特性**：
- VoiceOver：所有控件有 label 和 hint
- Dynamic Type：使用系统字体
- Reduce Motion：检测并简化动画
- 键盘快捷键：完整的快捷键支持

## 🎨 UI 组件

### 主要视图

1. **MainView**：NavigationSplitView 容器
2. **TimerView**：计时器主页面
3. **HistoryView**：历史统计
4. **SettingsView**：设置页面

### 自定义组件

1. **CircularProgressView**：圆环进度条
2. **TodayStatsView**：今日统计卡片
3. **WeekStatsView**：周统计卡片
4. **ToggleRow**：设置开关行
5. **DurationStepper**：时长调节器

## 🧪 测试

### TimerEngineTests
- 初始状态测试
- 开始/暂停/重置功能
- 时间调整
- 进度计算

### AutoSwitchTests
- 工作 → 短休息切换
- 短休息 → 工作切换
- 4 个番茄后进入长休息
- 长休息 → 工作切换
- 番茄计数

## 🔧 配置文件

### Info.plist
```xml
- 应用名称：番茄计时器
- 支持平台：iPad only (iPadOS 26+)
- 多窗口支持：是
- 通知权限描述
- 后台音频支持
```

### ExportOptions.plist
```xml
- 构建方式：development
- 签名方式：automatic
- Team ID：运行时替换
```

### project.pbxproj
```
- 目标平台：iPadOS 26.0+
- Swift 版本：5.0
- 设备家族：iPad (2)
- Bundle ID：com.tomatotimer.app
```

## 🚀 构建流程

### GitHub Actions 工作流

1. **Checkout**：拉取代码
2. **Setup Xcode**：配置 Xcode 15.2
3. **Import Certificates**：设置签名
4. **Build**：
   - Archive 项目
   - Export IPA
5. **Upload**：上传 Artifacts

### 环境变量
- `APPLE_ID`：Apple ID 邮箱
- `APPLE_PASSWORD`：App 专用密码
- `TEAM_ID`：开发团队 ID

## 📊 数据模型

### PomodoroSession
```swift
- id: UUID
- date: Date
- mode: TimerMode
- duration: TimeInterval
```

### TimerMode
```swift
- work: 25 分钟
- shortBreak: 5 分钟
- longBreak: 15 分钟
```

### TimerState
```swift
- idle: 待机
- running: 运行中
- paused: 已暂停
- completed: 已完成
```

## 🎯 关键特性实现

### 1. 精准计时（抗漂移）
```swift
// 保存目标结束时间
targetEndDate = Date().addingTimeInterval(remainingTime)

// 每次 tick 计算剩余时间
remainingTime = max(0, target.timeIntervalSinceNow)
```

### 2. 状态恢复
```swift
// 启动时检查 UserDefaults
if let savedTarget = loadTargetEndDate() {
    if savedTarget > Date() {
        // 时间未过期，恢复运行
        targetEndDate = savedTarget
        startTicking()
    } else {
        // 已过期，重置
        reset()
    }
}
```

### 3. 自动切换
```swift
func switchToNextMode() {
    switch currentMode {
    case .work:
        // 每 4 个番茄进入长休息
        if workSessionsCount % 4 == 0 {
            currentMode = .longBreak
        } else {
            currentMode = .shortBreak
        }
    case .shortBreak, .longBreak:
        currentMode = .work
    }
}
```

### 4. 保持屏幕常亮
```swift
// 开始计时时
UIApplication.shared.isIdleTimerDisabled = true

// 停止计时时
UIApplication.shared.isIdleTimerDisabled = false
```

## 🔐 安全注意事项

1. **不要提交敏感信息**
   - Apple ID
   - App 专用密码
   - Team ID
   - 证书文件（.p8, .p12）

2. **使用 GitHub Secrets**
   - 所有凭证存储在 Secrets
   - 工作流通过环境变量访问

3. **.gitignore 配置**
   - 忽略 build/ 目录
   - 忽略 xcuserdata/
   - 忽略证书文件

## 📚 依赖项

### 系统框架
- SwiftUI
- Combine
- UserNotifications
- AVFoundation
- UIKit（触觉反馈）
- UniformTypeIdentifiers（CSV 导出）

### 无第三方依赖
本项目不依赖任何第三方库，仅使用 Apple 官方框架。

## 🎓 学习资源

### 官方文档
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [User Notifications](https://developer.apple.com/documentation/usernotifications)

### 相关技术
- MVVM 架构
- Combine 响应式编程
- SwiftUI 声明式 UI
- @MainActor 并发模型
- UserDefaults 持久化

## 🤝 贡献指南

### 开发流程
1. Fork 项目
2. 创建功能分支
3. 提交代码
4. 运行测试
5. 创建 Pull Request

### 代码规范
- 遵循 Swift API Design Guidelines
- 使用有意义的变量名
- 添加注释说明复杂逻辑
- 编写单元测试

## 📝 待办事项

- [ ] 添加更多单元测试
- [ ] 支持 Widget（小组件）
- [ ] 支持 Shortcuts（快捷指令）
- [ ] 添加更多统计图表
- [ ] 支持自定义主题
- [ ] 添加音乐集成（播放白噪音）
- [ ] iCloud 同步

## 🐛 已知问题

1. 免费账号通知可能不工作
2. 7 天签名限制
3. 多窗口状态同步有轻微延迟

## 📄 许可证

MIT License - 详见 LICENSE 文件

---

**项目完整，即可构建使用！** 🍅

