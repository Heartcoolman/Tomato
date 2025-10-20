# App 图标设计方案

番茄计时器的图标设计需要简洁、识别度高，并符合应用的番茄工作法主题。

## 🎨 设计规范

### 颜色方案
- **主色**：#B52B2D（番茄红）
- **辅助色**：#FFFFFF（白色）
- **点缀色**：#4CAF50（绿色，用于叶子）

### 设计原则
1. **极简**：图标元素不超过 3 个
2. **识别度**：即使缩小到 20x20 也能识别
3. **一致性**：与应用内 UI 风格保持一致
4. **圆角**：iOS 会自动应用圆角，设计时无需添加

## 💡 设计方案

### 方案 1：番茄轮廓（推荐）
```
┌─────────────────┐
│                 │
│   🍅 (轮廓)     │
│   番茄红背景     │
│   白色线条       │
│   绿色叶子       │
│                 │
└─────────────────┘
```

**优点**：
- 直观表达番茄工作法
- 视觉吸引力强
- 易于识别

**制作步骤**：
1. 1024x1024 画布，填充 #B52B2D
2. 绘制白色番茄轮廓（线宽 8-10px）
3. 顶部添加绿色叶子（#4CAF50）
4. 确保元素居中，四周留白 100px

### 方案 2：字母 T
```
┌─────────────────┐
│                 │
│       T         │
│   番茄红背景     │
│   白色粗体字母   │
│                 │
│                 │
└─────────────────┘
```

**优点**：
- 极简
- 快速识别
- 专业感

**制作步骤**：
1. 1024x1024 画布，填充 #B52B2D
2. 使用 San Francisco Bold 或 Helvetica Bold
3. 白色字母 "T"（字号 600-700px）
4. 居中对齐

### 方案 3：计时器圆环
```
┌─────────────────┐
│                 │
│    ◐            │
│   番茄红背景     │
│   白色圆环       │
│   中心数字 25    │
│                 │
└─────────────────┘
```

**优点**：
- 突出计时功能
- 现代感强
- 与应用内圆环进度一致

**制作步骤**：
1. 1024x1024 画布，填充 #B52B2D
2. 绘制白色圆环（环宽 60px，半径 350px）
3. 圆环填充 75%（表示进度）
4. 中心白色数字 "25"（字号 200px）

## 🛠️ 制作工具

### 在线工具（最简单）

1. **Canva**
   - 访问 [canva.com](https://www.canva.com)
   - 创建 1024x1024 自定义尺寸
   - 使用形状和文字工具
   - 导出为 PNG

2. **Figma**（推荐）
   - 访问 [figma.com](https://www.figma.com)
   - 免费账号即可
   - 精确控制
   - 导出为 PNG

3. **appicon.co**
   - 上传 1024x1024 图标
   - 自动生成所有尺寸
   - 下载 ZIP

### 本地软件

1. **Sketch**（macOS）
   - 专业设计工具
   - 有 iOS 图标模板

2. **Adobe Illustrator**
   - 矢量图形
   - 导出多种尺寸

3. **Affinity Designer**
   - 一次性购买
   - 功能完整

### AI 生成

使用 AI 生成番茄图标：

**DALL-E 提示词**：
```
A minimalist app icon for a Pomodoro timer app. 
Tomato red background (#B52B2D). 
Simple white tomato outline with green leaf. 
Clean, modern, iOS style. 
Flat design, no shadows.
```

**Midjourney 提示词**：
```
minimalist iOS app icon, red tomato silhouette, 
white outline, green leaf, flat design, 
tomato red background, simple, clean --ar 1:1
```

## 📐 快速制作步骤

### 使用 Figma（免费）

1. **创建画布**
   ```
   - 登录 Figma
   - 新建文件
   - 按 F 创建 Frame
   - 尺寸：1024 x 1024
   ```

2. **添加背景**
   ```
   - 选中 Frame
   - 右侧面板 → Fill
   - 输入颜色：B52B2D
   ```

3. **添加图标元素**
   
   **方案 1（番茄）：**
   ```
   - 使用钢笔工具 (P) 绘制番茄形状
   - 填充：白色 (FFFFFF)
   - 描边：无
   - 或使用矢量插图素材
   ```
   
   **方案 2（字母 T）：**
   ```
   - 按 T 创建文本框
   - 输入 "T"
   - 字体：SF Pro Bold 或 Helvetica Bold
   - 字号：600
   - 颜色：FFFFFF
   - 居中对齐
   ```
   
   **方案 3（圆环）：**
   ```
   - 按 O 创建圆形
   - 尺寸：700 x 700
   - 填充：无
   - 描边：白色，60px
   - 居中对齐
   - 添加文本 "25" 在中心
   ```

4. **导出**
   ```
   - 选中 Frame
   - 右下角 Export
   - 格式：PNG
   - 2x (2048x2048)
   - 导出
   ```

5. **生成所有尺寸**
   ```
   - 访问 appicon.co
   - 上传 PNG
   - 选择 iPad
   - 下载 ZIP
   - 解压到 Assets.xcassets/AppIcon.appiconset/
   ```

## 🎯 设计检查清单

制作完成后，检查以下项目：

- [ ] 1024x1024 尺寸正确
- [ ] 文件格式为 PNG
- [ ] 背景不透明（不能有透明度）
- [ ] 颜色准确（#B52B2D）
- [ ] 元素居中
- [ ] 四周留白充足（100px+）
- [ ] 缩小到 40x40 仍可识别
- [ ] 与应用主题一致
- [ ] 没有版权问题

## 📦 文件命名

使用 appicon.co 生成的文件已经自动命名，直接替换到：
```
TomatoTimer/Assets.xcassets/AppIcon.appiconset/
```

需要的文件：
- icon-20@2x.png (40x40)
- icon-29.png (29x29)
- icon-29@2x.png (58x58)
- icon-40.png (40x40)
- icon-40@2x.png (80x80)
- icon-76.png (76x76)
- icon-76@2x.png (152x152)
- icon-83.5@2x.png (167x167)
- icon-1024.png (1024x1024)

## 🚀 临时解决方案

如果您急需构建，可以暂时使用纯色占位符：

1. 创建 1024x1024 纯番茄红图片
2. 中心添加白色 "T" 字母
3. 使用 appicon.co 生成

这样应用可以正常构建和运行，后续再替换精美图标。

## 📚 参考资源

- [Apple Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [iOS Icon Gallery](https://www.iosicongallery.com/)
- [App Icon Generator](https://appicon.co/)

---

选择一个方案开始制作吧！🎨

