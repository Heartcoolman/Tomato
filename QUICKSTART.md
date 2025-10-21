# 快速开始指南

5 分钟内完成番茄计时器的构建和安装。

## ⚡ 快速流程

```
推送代码到 GitHub → 自动构建 → 下载未签名 IPA → 用 Sideloadly 签名安装
```

估计时间：15-20 分钟（首次）

✅ **无需配置 Apple 凭证到 GitHub！更安全！**

## 📋 准备清单

在开始之前，确保您有：

- [ ] GitHub 账号
- [ ] Apple ID（任何 Apple ID，免费）
- [ ] iPad（iPadOS 26+）
- [ ] 电脑（Windows/Mac）
- [ ] USB 数据线

## 🚀 步骤 1：推送代码到 GitHub（1 分钟）

### 1.1 创建 GitHub 仓库

1. 访问 https://github.com
2. 点击 **New repository**
3. 仓库名：`TomatoTimer`
4. 选择 **Public** 或 **Private**
5. 点击 **Create repository**

### 1.2 推送代码

```bash
# 在本地项目目录
cd TomatoTimer

# 初始化 Git（如果还没有）
git init
git add .
git commit -m "Initial commit - 番茄计时器应用"

# 关联远程仓库
git remote add origin https://github.com/yourusername/TomatoTimer.git

# 推送代码
git branch -M main
git push -u origin main
```

✅ **无需配置任何 Secrets！**

## 🏗️ 步骤 2：自动构建（10-15 分钟）

### 2.1 触发构建

代码推送后会自动触发构建，或手动触发：

1. GitHub 仓库页面点击 **Actions** 标签
2. 左侧选择 **Build Unsigned Archive**
3. 右上角 **Run workflow** → **Run workflow**

### 2.2 等待完成

- 在 Actions 页面查看进度
- 整个过程约 10-15 分钟
- 可以实时查看日志
- ✅ 无需任何配置，完全自动化

### 2.3 下载未签名 IPA

构建成功后：
1. 滚动到页面底部
2. **Artifacts** 区域
3. 点击 **TomatoTimer-Unsigned-IPA** 下载
4. 解压 ZIP 文件
5. 得到 `TomatoTimer-unsigned.ipa`

## 📱 步骤 3：签名并安装（5 分钟）

### 推荐：使用 Sideloadly（最简单）

**优点**：
- ✅ 支持 Windows 和 Mac
- ✅ 图形界面，一键签名
- ✅ 自动处理所有复杂步骤
- ✅ 支持免费和付费账号

### 3.1 安装 Sideloadly

1. 访问 https://sideloadly.io/
2. 下载对应系统的版本
3. 安装并启动

### 3.2 签名并安装

1. **连接 iPad**：
   - 通过 USB 连接到电脑
   - 信任电脑（如果 iPad 提示）

2. **加载 IPA**：
   - 将 `TomatoTimer-unsigned.ipa` 拖入 Sideloadly 窗口
   - 或点击选择文件

3. **输入 Apple ID**：
   - Apple ID 邮箱
   - 密码

4. **点击 Start**：
   - 等待签名和安装（1-3 分钟）
   - 显示 "Done!" 表示完成

5. **信任证书**：
   - iPad 打开 **设置** → **通用** → **VPN 与设备管理**
   - 找到您的 Apple ID
   - 点击 **信任**

### 3.3 启动应用

1. 在主屏幕找到番茄计时器图标
2. 点击启动
3. 允许通知权限（如果提示）
4. 开始使用！🍅

### 其他签名方式

查看 **[SELF_SIGNING_GUIDE.md](SELF_SIGNING_GUIDE.md)** 了解更多签名方式：
- AltStore
- Xcode
- iOS App Signer
- 命令行工具

## ✅ 验证安装

安装成功后，检查：

- [ ] 应用图标显示正常
- [ ] 可以启动应用
- [ ] 计时器可以开始/暂停
- [ ] 圆环进度正常显示
- [ ] 设置可以保存

## 🔄 自动刷新设置（重要！）

免费账号签名 7 天后过期，需要定期刷新：

### 使用 Sideloadly 自动刷新

1. **保持 Sideloadly 运行**：
   - 在电脑后台运行 Sideloadly
   - 应用会在过期前自动提醒

2. **重新签名**：
   - iPad 连接电脑
   - 打开 Sideloadly
   - 再次签名安装即可

### 使用 AltStore 自动刷新

1. **安装 AltStore**（参考 [SELF_SIGNING_GUIDE.md](SELF_SIGNING_GUIDE.md)）

2. **启用后台刷新**：
   - iPad 打开 AltStore
   - 进入 Settings
   - 开启 Background Refresh

3. **保持条件**：
   - 电脑运行 AltServer
   - iPad 和电脑在同一网络
   - 自动在过期前刷新

## 🎉 开始使用

### 基本操作

1. **开始番茄**：点击"开始"或按空格键
2. **暂停**：点击"暂停"
3. **重置**：点击"重置"或按 R 键
4. **切换模式**：顶部分段控制器

### 推荐设置

第一次使用建议：

1. 进入"设置"页面
2. 开启"自动切换"
3. 开启"触觉反馈"
4. 开启"保持屏幕常亮"
5. 根据个人习惯调整时长

### 查看统计

1. 切换到"历史"页面
2. 查看今日、本周完成的番茄数
3. 查看连续天数
4. 可以导出 CSV 查看详细数据

## 🐛 常见问题快速解决

### Q: 构建失败
**A**: 检查 GitHub Secrets 是否正确配置，特别是 Team ID。

### Q: 应用无法打开
**A**: 在设置中信任证书：设置 → 通用 → VPN 与设备管理 → 信任。

### Q: AltStore 自动刷新不工作
**A**: 
1. 确保 iPad 和电脑在同一 WiFi
2. 确保 AltServer 在电脑上运行
3. 在 AltStore 中开启后台刷新

### Q: 7 天后应用无法打开
**A**: 签名过期，在 AltStore 中点击刷新按钮。

### Q: 通知不工作
**A**: 这是免费账号的限制，声音和触觉反馈仍可使用。

## 📞 需要帮助？

- 查看详细文档：[FREE_ACCOUNT_GUIDE.md](FREE_ACCOUNT_GUIDE.md)
- AltStore 帮助：https://altstore.io/faq/
- 创建 Issue：在 GitHub 仓库中提问

## 🎯 下一步

现在您可以：

- ✅ 使用番茄工作法提升效率
- ✅ 查看每日/周统计
- ✅ 导出数据分析
- ✅ 自定义时长和设置
- ✅ 使用键盘快捷键（外接键盘）

## 💡 小贴士

1. **每天检查**：在 AltStore 中查看剩余天数
2. **备份数据**：定期导出 CSV 保存统计数据
3. **保持连接**：iPad 和电脑尽量在同一网络，方便自动刷新
4. **升级账号**：如果长期使用，考虑升级到付费开发者账号（$99/年）

---

**恭喜！您已成功安装番茄计时器！** 🎉🍅

开始您的高效工作之旅吧！

