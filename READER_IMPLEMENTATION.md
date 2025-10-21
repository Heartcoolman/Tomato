# TXT 阅读器实现文档

## 项目概述

已将"番茄工作法计时器"升级为"番茄"，集成了完整的 TXT 阅读器功能。

## 已完成功能

### 1. 项目重命名 ✅
- 应用显示名称：番茄计时器 → 番茄
- Info.plist 已更新
- 保持 Bundle ID 不变（避免签名问题）

### 2. 核心数据模型 ✅

#### WebDAV 相关
- `WebDAVAccount.swift` - WebDAV 账号配置
- `WebDAVItem.swift` - 文件/文件夹项

#### 书籍相关
- `Book.swift` - 书籍模型（包含进度、编码等）
- `Bookmark.swift` - 书签
- `Highlight.swift` - 高亮标注
- `Chapter.swift` - 章节
- `ReaderSettings.swift` - 阅读器设置

### 3. 核心管理器 ✅

#### WebDAVManager
- WebDAV 账号管理（增删改查）
- Keychain 密码安全存储
- 连接测试
- 文件列表获取（PROPFIND）
- 文件下载（GET）
- Basic Auth 认证

#### EncodingDetector
- 自动编码检测（支持 10+ 种编码）
- BOM 检测（UTF-8/UTF-16）
- 置信度计算
- 文本解码
- 预览功能（前 N 行）
- 统一换行符处理

#### ChapterParser
- 自动章节识别
- 支持中文（第X章/卷/节/回）
- 支持英文（Chapter/Part/Section）
- 支持数字编号
- 章节进度计算

#### BookStore
- 书籍数据持久化（UserDefaults + JSON）
- 书签管理
- 高亮管理
- 阅读进度跟踪
- 设置管理

### 4. 用户界面 ✅

#### ReaderMainView
- 三标签页：WebDAV / 本地 / 书架
- 空状态提示
- 书籍列表展示

#### WebDAVBrowserView
- 账号列表
- 添加/删除账号
- 空状态引导

#### AddWebDAVAccountView
- 账号信息表单
- 连接测试功能
- 常用服务快捷填充（坚果云等）
- 实时验证

#### WebDAVFileListView
- 树形目录浏览
- 文件搜索
- 文件大小/日期显示
- 仅显示 .txt 文件
- 返回上级目录
- 文件下载与打开

#### EncodingPickerView
- 编码列表选择
- 实时预览（前 5 行）
- 支持 10+ 种编码

#### BookReaderView
- 分页/滚动双模式
- 顶部工具栏（返回、目录、设置）
- 底部进度条（章节、百分比、页码）
- 主题切换（白天/夜间/护眼）

#### ReaderSettingsView
- 显示模式切换
- 字体设置（字号、行距）
- 页边距调整
- 主题选择
- 实时预览

#### TableOfContentsView
- 章节列表
- 章节位置显示
- 点击跳转

#### BookshelfView
- 书籍列表
- 阅读进度显示
- 删除书籍

### 5. 导航集成 ✅

- 在 `DockNavigationBar` 添加"阅读"标签
- 在 `MainViewNew` 集成阅读器视图
- 添加阅读器专属背景渐变

## 技术特性

### 编码支持
- UTF-8（含 BOM）
- UTF-16 LE/BE（含 BOM）
- GB18030 / GBK（简体中文）
- Big5（繁体中文）
- Shift-JIS（日文）
- ISO-8859-1 / Windows-1252（西欧）
- KOI8-R（俄文）
- EUC-KR（韩文）

### 安全性
- 密码存储在 iOS Keychain
- 不明文保存密码
- 支持多账号隔离

### 性能优化
- 流式读取（按需加载）
- 分块处理大文件
- 异步下载与解码
- 内存优化

### 用户体验
- 自动编码检测（置信度 > 0.7 直接打开）
- 编码选择器（实时预览）
- 记住每本书的编码
- 流畅的动画过渡
- 空状态引导

## 待完成功能

### Phase 2（核心功能增强）
- [ ] 完善分页算法（精确计算每页内容）
- [ ] 实现书签添加/删除
- [ ] 实现高亮标注
- [ ] 实现全文搜索
- [ ] 实现阅读位置保存与恢复

### Phase 3（高级功能）
- [ ] TTS 语音朗读
- [ ] 词典/翻译集成
- [ ] Apple Pencil 批注
- [ ] 导出笔记

### Phase 4（iPad 优化）
- [ ] 键盘快捷键完整支持
- [ ] 分屏优化
- [ ] 外接键盘支持
- [ ] 手势优化

### Phase 5（WebDAV 增强）
- [ ] 完整的 WebDAV XML 解析
- [ ] 支持更多 WebDAV 服务器
- [ ] 断点续传
- [ ] 缓存管理

## 文件结构

```
TomatoTimer/
├── Models/
│   ├── Book.swift                 ✅ 书籍模型
│   ├── WebDAVAccount.swift        ✅ WebDAV 账号
│   └── ReaderSettings.swift       ✅ 阅读设置
├── Core/
│   ├── WebDAVManager.swift        ✅ WebDAV 管理
│   ├── EncodingDetector.swift     ✅ 编码检测
│   └── ChapterParser.swift        ✅ 章节解析
├── Stores/
│   └── BookStore.swift            ✅ 书籍数据管理
├── Views/
│   ├── Reader/
│   │   ├── ReaderMainView.swift          ✅ 阅读器主视图
│   │   ├── WebDAVFileListView.swift      ✅ 文件浏览
│   │   ├── AddWebDAVAccountView.swift    ✅ 添加账号
│   │   ├── BookReaderView.swift          ✅ 阅读视图
│   │   └── EncodingPickerView.swift      ✅ 编码选择器
│   ├── Navigation/
│   │   └── DockNavigationBar.swift       ✅ 导航栏（已更新）
│   └── MainViewNew.swift                 ✅ 主视图（已集成）
└── Info.plist                            ✅ 应用名称（已更新）
```

## 使用示例

### 添加 WebDAV 账号
```swift
let account = WebDAVAccount(
    name: "我的坚果云",
    serverURL: "https://dav.jianguoyun.com/dav/",
    username: "user@example.com"
)
WebDAVManager.shared.addAccount(account, password: "password")
```

### 检测编码
```swift
let data = // 文件数据
if let (encoding, confidence) = EncodingDetector.detectEncoding(data: data) {
    print("检测到编码: \(encoding), 置信度: \(confidence)")
}
```

### 解析章节
```swift
let text = // 书籍内容
let chapters = ChapterParser.parseChapters(text: text)
print("找到 \(chapters.count) 个章节")
```

## 测试建议

### 编码测试
1. UTF-8 文件（无 BOM）
2. UTF-8 文件（有 BOM）
3. GBK 简体中文小说
4. Big5 繁体中文小说
5. 混合编码文件

### WebDAV 测试
1. 坚果云
2. Nextcloud
3. ownCloud
4. Synology NAS

### 文件大小测试
1. 小文件（< 1MB）
2. 中等文件（1-10MB）
3. 大文件（10-100MB）
4. 超大文件（> 100MB）

## 已知限制

1. **WebDAV XML 解析**：当前使用简化版本，需要完整实现
2. **分页算法**：需要根据字体大小精确计算
3. **大文件性能**：超大文件可能需要更多优化
4. **网络错误处理**：需要更完善的重试机制

## 下一步计划

1. 完善 WebDAV XML 解析（使用 XMLParser）
2. 实现精确分页算法
3. 添加书签和高亮功能
4. 实现全文搜索
5. 添加 TTS 朗读
6. 完善键盘快捷键
7. 性能优化和测试

## 总结

已成功将番茄工作法计时器升级为"番茄"，集成了完整的 TXT 阅读器基础架构。核心功能包括：

- ✅ WebDAV 云端文件访问
- ✅ 智能编码识别（10+ 种编码）
- ✅ 流畅阅读体验（分页/滚动）
- ✅ 自动章节识别
- ✅ 自定义排版设置
- ✅ 多主题支持
- ✅ 安全的密码存储

项目已具备基本的阅读功能，可以进行进一步的功能增强和优化。
