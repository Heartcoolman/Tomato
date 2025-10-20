# 免费开发者账号使用指南

本文档详细说明如何使用免费 Apple 开发者账号安装番茄计时器应用。

## 📋 前置条件

### 1. Apple ID
- 任何 Apple ID 均可（免费）
- 无需支付 $99/年的开发者会员费用

### 2. 开发者账号注册（可选）
访问 [developer.apple.com](https://developer.apple.com) 登录即可，无需额外注册。

## 🚀 新方案：自签名（推荐）

本项目采用**自签名方案**，**无需配置任何 GitHub Secrets**，更安全更简单！

### 优点

✅ **更安全**：Apple 凭证不离开本地  
✅ **更简单**：无需配置 GitHub Secrets  
✅ **更灵活**：可选多种签名工具  
✅ **自动构建**：GitHub Actions 自动构建未签名 IPA

## 📦 GitHub Actions 自动构建

### 步骤 1：推送代码

```bash
git clone https://github.com/yourusername/TomatoTimer.git
cd TomatoTimer
git push origin main
```

构建会自动触发，**无需任何配置**！

### 步骤 3：触发构建

#### 方式 1：推送代码触发
```bash
git add .
git commit -m "Initial commit"
git push origin main
```

#### 方式 2：手动触发
1. 在 GitHub 仓库页面点击 **Actions**
2. 左侧选择 **Build IPA** 工作流
3. 点击右上角 **Run workflow**
4. 选择分支（通常是 `main`）
5. 点击绿色的 **Run workflow** 按钮

### 步骤 4：监控构建

1. 构建开始后，可以实时查看日志
2. 整个过程约需 10-15 分钟
3. 如果出现错误，查看日志排查问题

### 步骤 5：下载 IPA

1. 构建成功后，页面底部会出现 **Artifacts** 区域
2. 点击 **TomatoTimer-IPA** 下载（ZIP 格式）
3. 解压后得到 `.ipa` 文件
4. Artifacts 保留 7 天，过期后需重新构建

## 📱 安装到 iPad

### 使用 AltStore（推荐）

#### Windows 安装步骤

1. **安装 iTunes**
   - 下载：[apple.com/itunes](https://www.apple.com/itunes/)
   - 确保是最新版本

2. **安装 iCloud**
   - 下载：[apple.com/icloud](https://www.apple.com/icloud/setup/pc.html)

3. **安装 AltServer**
   - 下载：[altstore.io](https://altstore.io/)
   - 运行安装程序
   - 完成后，系统托盘会出现 AltServer 图标

4. **iPad 准备**
   - iPad 通过 USB 连接到电脑
   - 在 iTunes 中信任设备
   - 确保 iPad 和电脑在同一 WiFi 网络

5. **安装 AltStore 到 iPad**
   - 点击托盘中的 AltServer 图标
   - 选择 **Install AltStore** → 选择您的 iPad
   - 输入 Apple ID 和密码
   - 等待安装完成

6. **信任 AltStore**
   - iPad 打开 **设置** → **通用** → **VPN 与设备管理**
   - 找到您的 Apple ID
   - 点击 **信任**

7. **安装 IPA**
   - 打开 iPad 上的 AltStore 应用
   - 点击顶部的 **+** 号
   - 选择 **Files**，找到下载的 `.ipa` 文件
   - 等待安装完成

#### macOS 安装步骤

1. 下载 AltServer：[altstore.io](https://altstore.io/)
2. 将 AltServer 拖到应用程序文件夹
3. 运行 AltServer（菜单栏出现图标）
4. 按照上述步骤 4-7 操作

### 使用 Sideloadly（备选方案）

1. 下载 Sideloadly：[sideloadly.io](https://sideloadly.io/)
2. 安装并运行
3. iPad 通过 USB 连接到电脑
4. 在 Sideloadly 中：
   - 选择 `.ipa` 文件
   - 输入 Apple ID
   - 点击 **Start**
5. 等待安装完成
6. 在 iPad 上信任证书

## 🔄 自动刷新（7 天签名）

免费账号的应用签名只有 7 天有效期。过期后应用将无法打开。

### AltStore 自动刷新

1. **保持 AltServer 运行**
   - Windows：保持电脑开机，AltServer 在后台运行
   - macOS：同上

2. **启用后台刷新**
   - iPad 打开 **AltStore**
   - 进入 **设置**
   - 开启 **Background Refresh**

3. **自动工作原理**
   - iPad 和电脑在同一 WiFi
   - AltStore 会在后台自动刷新签名
   - 通常在过期前 1-2 天自动完成
   - 刷新时无需手动操作

4. **查看剩余天数**
   - 在 AltStore 应用列表中可以看到每个应用的剩余天数

### 手动刷新

如果自动刷新失败：

1. 打开 AltStore
2. 找到番茄计时器应用
3. 点击 **Refresh**
4. 等待重新签名完成

## ⚠️ 免费账号限制

### 1. 7 天签名有效期
- **影响**：应用每 7 天需重新签名
- **解决**：使用 AltStore 自动刷新
- **备注**：付费账号签名有效期为 1 年

### 2. 设备数量限制
- **限制**：每个 Apple ID 最多 3 台设备
- **影响**：无法在超过 3 台设备上同时安装
- **解决**：升级到付费账号（无设备限制）

### 3. 通知功能限制
- **问题**：本地通知可能无法正常工作
- **原因**：免费账号缺少推送通知权限
- **影响**：完成时可能无法收到通知
- **备选**：声音和触觉反馈仍可正常工作
- **解决**：升级到付费账号（$99/年）

### 4. 应用功能限制
- ❌ 无法发布到 App Store
- ❌ 无法使用 iCloud、Apple Pay 等高级功能
- ✅ 所有基本功能正常工作
- ✅ 可以自用和分享给朋友（需要他们的设备 UDID）

## 🆙 升级到付费账号

如果您需要：
- 长期使用（无需每 7 天刷新）
- 完整的通知功能
- 无设备数量限制
- 发布到 App Store

建议升级到付费账号：

1. 访问 [developer.apple.com](https://developer.apple.com)
2. 点击 **Account**
3. 选择 **Enroll** → **Start Your Enrollment**
4. 选择 **Individual**（个人，$99/年）
5. 完成支付

## 🐛 常见问题

### Q1: 构建失败，提示 "No signing certificate"
**A**: 检查 GitHub Secrets 是否正确配置，特别是 Team ID。

### Q2: IPA 安装后无法打开
**A**: 在设置中信任开发者证书：设置 → 通用 → VPN 与设备管理 → 信任。

### Q3: AltStore 自动刷新不工作
**A**: 确保：
- iPad 和电脑在同一 WiFi
- AltServer 在电脑上运行
- iPad 已开启后台刷新权限

### Q4: 应用突然无法打开，提示 "Unable to Verify App"
**A**: 签名已过期（7 天），需使用 AltStore 重新刷新。

### Q5: 通知不工作
**A**: 这是免费账号的已知限制，声音和触觉反馈仍可使用。

### Q6: GitHub Actions 超时
**A**: GitHub 免费账号有每月 2000 分钟的限制，注意使用量。

## 📞 获取帮助

- **AltStore 帮助**：[altstore.io/faq](https://altstore.io/faq/)
- **Apple 开发者支持**：[developer.apple.com/support](https://developer.apple.com/support/)
- **项目 Issues**：在 GitHub 仓库中创建 Issue

## 🎉 总结

使用免费账号虽然有些限制，但对于个人使用完全足够：
- ✅ 免费
- ✅ 所有核心功能正常工作
- ✅ 通过 AltStore 可实现自动刷新
- ✅ 可分享给朋友使用

祝您使用愉快！🍅

