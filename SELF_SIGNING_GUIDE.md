# 自签名安装指南

本指南说明如何使用 GitHub Actions 构建的未签名 IPA，在本地进行签名和安装。

## 📋 前置条件

- Apple 开发者账号（免费或付费均可）
- 开发者证书和 Provisioning Profile
- 签名工具（选择一种）：
  - **Sideloadly**（推荐，最简单）
  - **AltStore**
  - **Xcode**（需要 Mac）
  - **iOS App Signer**（Mac）

## 🚀 方式 1：Sideloadly（推荐，最简单）

### 优点
- ✅ 支持 Windows 和 macOS
- ✅ 图形界面，操作简单
- ✅ 自动处理签名
- ✅ 支持免费和付费开发者账号

### 步骤

#### 1. 下载未签名 IPA

1. 在 GitHub 仓库点击 **Actions**
2. 选择最新的成功构建
3. 滚动到底部 **Artifacts**
4. 下载 **TomatoTimer-Unsigned-IPA**
5. 解压得到 `TomatoTimer-unsigned.ipa`

#### 2. 安装 Sideloadly

- **Windows/Mac**：[sideloadly.io](https://sideloadly.io/)
- 下载并安装

#### 3. 签名并安装

1. 启动 Sideloadly
2. **连接 iPad**：
   - 通过 USB 连接到电脑
   - 信任电脑（如果提示）
3. **选择 IPA**：
   - 点击或拖拽 `TomatoTimer-unsigned.ipa` 到窗口
4. **输入 Apple ID**：
   - 输入您的 Apple ID 邮箱和密码
5. **高级选项**（可选）：
   - Bundle ID：保持默认或自定义（如 `com.yourname.tomatotimer`）
   - App Name：番茄计时器
6. **点击 Start**：
   - 等待签名和安装（约 1-3 分钟）
7. **信任证书**：
   - iPad：设置 → 通用 → VPN 与设备管理
   - 找到您的 Apple ID
   - 点击信任

#### 4. 启动应用

在主屏幕找到番茄计时器图标，点击启动。

### 自动刷新（7 天签名）

免费账号：
1. 保持 Sideloadly 在电脑上运行
2. 每 7 天前会自动提醒刷新
3. 或手动重新签名安装

## 🍎 方式 2：AltStore

### 步骤

#### 1. 安装 AltServer

**Windows**：
1. 安装 [iTunes](https://www.apple.com/itunes/)
2. 安装 [iCloud](https://www.apple.com/icloud/setup/pc.html)
3. 下载 [AltServer](https://altstore.io/)

**macOS**：
1. 下载 [AltServer](https://altstore.io/)
2. 拖到应用程序文件夹

#### 2. 安装 AltStore 到 iPad

1. iPad 通过 USB 连接电脑
2. 确保 iPad 和电脑在同一 WiFi
3. 点击系统托盘/菜单栏的 AltServer 图标
4. **Install AltStore** → 选择 iPad
5. 输入 Apple ID 和密码
6. 等待安装完成
7. iPad 信任证书（设置 → 通用 → VPN 与设备管理）

#### 3. 安装未签名 IPA

1. 打开 iPad 上的 **AltStore** 应用
2. 点击顶部 **+** 号
3. 选择 **Files**
4. 找到 `TomatoTimer-unsigned.ipa`
5. 等待签名和安装

#### 4. 自动刷新

1. 保持 AltServer 在电脑上运行
2. iPad 打开 AltStore → Settings
3. 开启 **Background Refresh**

## 💻 方式 3：Xcode（仅 Mac）

### 使用 xcarchive

#### 1. 下载 xcarchive

从 GitHub Actions Artifacts 下载 **TomatoTimer-xcarchive**

#### 2. 在 Xcode 中导出

1. 打开 **Xcode**
2. **Window** → **Organizer**
3. 拖拽 `TomatoTimer.xcarchive` 到 Organizer
4. 选中 Archive，点击 **Distribute App**
5. 选择 **Development** 或 **Ad Hoc**
6. 选择签名方式：
   - **Automatically manage signing**（推荐）
   - 或 **Manually manage signing**（需要导入证书）
7. 选择您的开发团队
8. 导出 IPA

#### 3. 安装

**方式 A：Xcode 直接安装**
1. iPad 通过 USB 连接 Mac
2. **Window** → **Devices and Simulators**
3. 选择您的 iPad
4. 点击 **+** → 选择导出的 IPA
5. 等待安装完成

**方式 B：使用 Finder（macOS Catalina+）**
1. iPad 连接 Mac
2. 打开 Finder，侧边栏选择 iPad
3. 拖拽 IPA 到设备上

## 🔧 方式 4：iOS App Signer（Mac）

### 步骤

#### 1. 安装 iOS App Signer

- 下载：[dantheman827/ios-app-signer](https://github.com/DanTheMan827/ios-app-signer/releases)

#### 2. 准备证书和 Provisioning Profile

1. **证书**：
   - 打开 **钥匙串访问**
   - 找到您的开发者证书
   - 导出为 `.p12` 文件（设置密码）

2. **Provisioning Profile**：
   - 访问 [developer.apple.com](https://developer.apple.com)
   - Certificates, Identifiers & Profiles
   - Profiles → + → iOS App Development
   - 选择 App ID、证书、设备
   - 下载 `.mobileprovision` 文件

#### 3. 签名

1. 打开 iOS App Signer
2. **Input File**：选择 `TomatoTimer-unsigned.ipa`
3. **Signing Certificate**：选择您的证书
4. **Provisioning Profile**：选择对应的 Profile
5. 点击 **Start**
6. 保存签名后的 IPA

#### 4. 安装

使用 Xcode 或 Apple Configurator 安装签名后的 IPA。

## 📱 方式 5：命令行签名（高级）

### 使用 codesign

```bash
# 1. 解压未签名 IPA
unzip TomatoTimer-unsigned.ipa -d unsigned

# 2. 签名
codesign -f -s "iPhone Developer: Your Name (TEAM_ID)" \
  unsigned/Payload/TomatoTimer.app

# 3. 重新打包
cd unsigned
zip -r ../TomatoTimer-signed.ipa Payload
cd ..

# 4. 安装（使用 ios-deploy）
npm install -g ios-deploy
ios-deploy --bundle TomatoTimer-signed.ipa
```

### 使用 fastlane（自动化）

创建 `Fastfile`：

```ruby
lane :sign_and_install do
  resign(
    ipa: "TomatoTimer-unsigned.ipa",
    signing_identity: "iPhone Developer: Your Name",
    provisioning_profile: "path/to/profile.mobileprovision"
  )
  
  install_on_device(
    ipa: "TomatoTimer.ipa"
  )
end
```

运行：
```bash
fastlane sign_and_install
```

## 🔐 证书管理

### 免费开发者账号

**限制**：
- 7 天签名有效期
- 最多 3 台设备
- 本地通知可能受限

**获取证书**：
- Xcode 自动生成
- 或使用 Sideloadly/AltStore 自动处理

### 付费开发者账号（$99/年）

**优势**：
- 1 年签名有效期
- 无设备数量限制
- 完整功能支持

**获取证书**：
1. 访问 [developer.apple.com](https://developer.apple.com)
2. Certificates, Identifiers & Profiles
3. Certificates → + → iOS App Development
4. 按步骤创建并下载

## 🎯 推荐方案

| 场景 | 推荐工具 | 难度 |
|------|----------|------|
| 日常使用（免费账号） | **Sideloadly** | ⭐ 简单 |
| 自动刷新（免费账号） | **AltStore** | ⭐⭐ 中等 |
| 有 Mac（开发者） | **Xcode** | ⭐⭐ 中等 |
| 批量设备部署 | **Apple Configurator** | ⭐⭐⭐ 复杂 |
| 完全自动化 | **fastlane** | ⭐⭐⭐ 复杂 |

## ❓ 常见问题

### Q1: 签名后无法安装
**A**: 
- 检查设备 UDID 是否添加到 Provisioning Profile
- 确保证书未过期
- Bundle ID 需要匹配

### Q2: "Unable to Verify App"
**A**: 
- 在设置中信任开发者证书
- 如果是免费账号，7 天后需要重新签名

### Q3: Sideloadly 报错
**A**: 
- 确保 iTunes/iCloud 已安装（Windows）
- 关闭防火墙重试
- 使用 App 专用密码（如果启用了双重认证）

### Q4: 通知不工作
**A**: 
- 免费账号的已知限制
- 升级到付费开发者账号可解决

### Q5: 构建失败
**A**: 
- 检查 Xcode 版本是否为 15.2
- 查看 GitHub Actions 日志
- 确保项目文件完整

## 📚 相关资源

- **Sideloadly 官网**：https://sideloadly.io/
- **AltStore 官网**：https://altstore.io/
- **Apple 开发者**：https://developer.apple.com/
- **iOS App Signer**：https://github.com/DanTheMan827/ios-app-signer

## 💡 小贴士

1. **免费账号用户**：建议使用 Sideloadly 或 AltStore，方便自动刷新
2. **付费账号用户**：可以使用 Xcode 一次签名，一年有效
3. **批量部署**：使用 Apple Configurator 或 MDM 方案
4. **开发调试**：使用 Xcode 直接运行，无需打包

## 🎉 总结

使用未签名 IPA 的好处：
- ✅ 无需在 GitHub 配置 Apple 凭证
- ✅ 更安全（凭证不离开本地）
- ✅ 灵活选择签名工具
- ✅ 支持多种分发方式

**推荐流程**：
1. GitHub Actions 自动构建未签名 IPA
2. 下载到本地
3. 使用 Sideloadly 签名并安装
4. 每 7 天自动刷新（免费账号）

---

**祝您签名顺利！** 🚀

