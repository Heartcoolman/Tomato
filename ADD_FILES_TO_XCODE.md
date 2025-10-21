# 将新文件添加到 Xcode 项目

## ✅ 已完成！

所有新文件已经自动添加到 Xcode 项目中。GitHub Actions 现在应该可以成功构建了。

## 📋 已添加的文件

如果 GitHub Actions 仍然失败，请参考下面的手动添加步骤。

## 📋 已添加的文件列表

### Models（3个文件）
- `TomatoTimer/Models/Book.swift`
- `TomatoTimer/Models/WebDAVAccount.swift`
- `TomatoTimer/Models/ReaderSettings.swift`

### Core（3个文件）
- `TomatoTimer/Core/WebDAVManager.swift`
- `TomatoTimer/Core/EncodingDetector.swift`
- `TomatoTimer/Core/ChapterParser.swift`

### Stores（1个文件）
- `TomatoTimer/Stores/BookStore.swift`

### Views/Reader（5个文件）
- `TomatoTimer/Views/Reader/ReaderMainView.swift`
- `TomatoTimer/Views/Reader/WebDAVFileListView.swift`
- `TomatoTimer/Views/Reader/AddWebDAVAccountView.swift`
- `TomatoTimer/Views/Reader/BookReaderView.swift`
- `TomatoTimer/Views/Reader/EncodingPickerView.swift`

## 🔧 添加步骤

### 方法 1：批量添加（推荐）

1. **打开 Xcode 项目**
   ```bash
   open TomatoTimer.xcodeproj
   ```

2. **在 Xcode 中，右键点击项目导航器中的 `TomatoTimer` 文件夹**

3. **选择 "Add Files to TomatoTimer..."**

4. **导航到项目根目录，选择以下文件夹：**
   - `TomatoTimer/Models/` 中的新文件（Book.swift、WebDAVAccount.swift、ReaderSettings.swift）
   - `TomatoTimer/Core/` 中的新文件（WebDAVManager.swift、EncodingDetector.swift、ChapterParser.swift）
   - `TomatoTimer/Stores/BookStore.swift`
   - `TomatoTimer/Views/Reader/` 整个文件夹

5. **确保勾选以下选项：**
   - ✅ "Copy items if needed"（如果需要）
   - ✅ "Create groups"（创建组）
   - ✅ "Add to targets: TomatoTimer"（添加到目标）

6. **点击 "Add"**

### 方法 2：逐个添加

如果批量添加有问题，可以逐个添加：

#### 添加 Models

1. 在项目导航器中找到 `TomatoTimer/Models` 文件夹
2. 右键点击 → "Add Files to TomatoTimer..."
3. 选择 `Book.swift`，确保勾选 "TomatoTimer" target
4. 重复步骤添加 `WebDAVAccount.swift` 和 `ReaderSettings.swift`

#### 添加 Core

1. 在项目导航器中找到 `TomatoTimer/Core` 文件夹
2. 右键点击 → "Add Files to TomatoTimer..."
3. 依次添加：
   - `WebDAVManager.swift`
   - `EncodingDetector.swift`
   - `ChapterParser.swift`

#### 添加 Stores

1. 在项目导航器中找到 `TomatoTimer/Stores` 文件夹
2. 右键点击 → "Add Files to TomatoTimer..."
3. 添加 `BookStore.swift`

#### 添加 Views/Reader

1. 在项目导航器中找到 `TomatoTimer/Views` 文件夹
2. 右键点击 → "Add Files to TomatoTimer..."
3. 选择整个 `Reader` 文件夹
4. 或者逐个添加：
   - `ReaderMainView.swift`
   - `WebDAVFileListView.swift`
   - `AddWebDAVAccountView.swift`
   - `BookReaderView.swift`
   - `EncodingPickerView.swift`

## ✅ 验证步骤

### 1. 检查文件是否已添加

在 Xcode 项目导航器中，你应该能看到：

```
TomatoTimer/
├── Models/
│   ├── Book.swift ✅
│   ├── WebDAVAccount.swift ✅
│   ├── ReaderSettings.swift ✅
│   └── ... (其他现有文件)
├── Core/
│   ├── WebDAVManager.swift ✅
│   ├── EncodingDetector.swift ✅
│   ├── ChapterParser.swift ✅
│   └── ... (其他现有文件)
├── Stores/
│   ├── BookStore.swift ✅
│   └── ... (其他现有文件)
└── Views/
    ├── Reader/ ✅
    │   ├── ReaderMainView.swift
    │   ├── WebDAVFileListView.swift
    │   ├── AddWebDAVAccountView.swift
    │   ├── BookReaderView.swift
    │   └── EncodingPickerView.swift
    └── ... (其他现有文件)
```

### 2. 检查 Target Membership

1. 在项目导航器中选择任意新添加的文件
2. 在右侧的 File Inspector 中查看 "Target Membership"
3. 确保 "TomatoTimer" 被勾选 ✅

### 3. 编译测试

1. 在 Xcode 中按 `Cmd + B` 编译项目
2. 确保没有编译错误
3. 如果有错误，检查：
   - 所有文件是否都已添加
   - Target Membership 是否正确
   - 文件路径是否正确

## 🔍 常见问题

### Q1: 找不到某些文件？

**A:** 确保你在正确的分支上：
```bash
git checkout feature/txt-reader-integration
git pull origin feature/txt-reader-integration
```

### Q2: 文件显示为红色（找不到）？

**A:** 这意味着文件路径不正确。解决方法：
1. 在项目导航器中删除该文件引用（右键 → Delete → Remove Reference）
2. 重新添加文件（确保选择正确的物理路径）

### Q3: 编译时提示 "Duplicate symbol"？

**A:** 这意味着文件被添加了多次。解决方法：
1. 选择项目根节点
2. 选择 "TomatoTimer" target
3. 进入 "Build Phases" → "Compile Sources"
4. 查找重复的文件并删除多余的

### Q4: 提示 "Cannot find 'XXX' in scope"？

**A:** 这意味着文件没有被正确添加到 target。解决方法：
1. 选择该文件
2. 在 File Inspector 中勾选 "TomatoTimer" target
3. 重新编译

## 📝 提交更新

添加完文件后，需要提交 Xcode 项目文件的更改：

```bash
# 查看更改
git status

# 应该看到 TomatoTimer.xcodeproj/project.pbxproj 被修改

# 添加并提交
git add TomatoTimer.xcodeproj/project.pbxproj
git commit -m "chore: 将阅读器文件添加到 Xcode 项目"
git push origin feature/txt-reader-integration
```

## 🎯 完成后

1. ✅ 所有文件都在项目导航器中可见
2. ✅ 所有文件的 Target Membership 包含 "TomatoTimer"
3. ✅ 项目可以成功编译（Cmd + B）
4. ✅ GitHub Actions 构建通过

## 🆘 需要帮助？

如果遇到问题：

1. 检查 Xcode 控制台的错误信息
2. 确保所有文件都在正确的物理位置
3. 尝试清理构建（Cmd + Shift + K）
4. 重启 Xcode

---

**完成这些步骤后，GitHub Actions 应该能够成功构建项目！** 🎉
