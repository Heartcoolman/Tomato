# WebDAV 连接故障排查指南

## 修复说明

**2025年10月22日更新**: WebDAV XML 解析功能已完整实现。如果之前连接不上，请更新代码后重试。

## 主要修复内容

### 1. 实现了完整的 WebDAV XML 解析器
- 之前 `parseWebDAVResponse` 只返回空数组
- 现在能正确解析 WebDAV PROPFIND 响应
- 支持多种命名空间（`d:` 前缀和无前缀）
- 支持文件和文件夹的完整属性解析

### 2. 优化了 URL 拼接逻辑
- 避免双斜杠问题（`//`）
- 正确处理服务器地址和路径的拼接
- 支持完整 URL 和相对路径的解析

### 3. 增强了服务器兼容性
- 添加了 `Content-Type: application/xml` 请求头
- 设置合理的超时时间（连接30秒，下载60秒）
- 支持多种日期格式解析
- 处理 URL 编码的路径

## 常见连接问题排查

### 问题 1: "连接失败" 或 "无效的服务器地址"

**可能原因**:
- 服务器地址格式不正确
- 网络连接问题
- 服务器不支持 WebDAV

**解决方法**:

1. **检查服务器地址格式**
   - 坚果云: `https://dav.jianguoyun.com/dav/`（注意末尾的 `/`）
   - Nextcloud: `https://your-server.com/remote.php/dav/files/username/`
   - 其他服务器: 咨询服务商的 WebDAV 地址

2. **确保以 `https://` 开头**
   ```
   ✅ 正确: https://dav.jianguoyun.com/dav/
   ❌ 错误: dav.jianguoyun.com/dav/
   ❌ 错误: http://dav.jianguoyun.com/dav/ (不安全)
   ```

3. **测试网络连接**
   - 在浏览器中打开服务器地址
   - 应该看到认证提示或 WebDAV 页面
   - 如果无法打开，可能是网络问题

### 问题 2: "用户名或密码错误"（401 错误）

**可能原因**:
- 密码输入错误
- 使用了错误的密码类型

**解决方法**:

1. **坚果云用户**: 必须使用应用密码，不是登录密码
   - 登录坚果云网页版
   - 进入 "账户信息" → "安全选项"
   - 找到 "第三方应用管理"
   - 生成新的应用密码
   - 使用应用密码而非登录密码

2. **Nextcloud 用户**: 可以使用登录密码或应用专用密码
   - 推荐创建应用专用密码（更安全）
   - 设置 → 安全 → 设备和会话 → 创建新的应用密码

3. **检查用户名**
   - 坚果云: 使用邮箱作为用户名
   - Nextcloud: 使用登录用户名（通常不是邮箱）

### 问题 3: "测试连接成功，但看不到文件"

**之前的原因**: WebDAV XML 解析器未实现（已修复）

**现在可能的原因**:
- 文件夹中确实没有文件
- 文件不是 `.txt` 格式
- 路径问题

**解决方法**:

1. **确认文件已上传**
   - 登录 WebDAV 网页版
   - 确认文件已成功上传
   - 确认文件扩展名是 `.txt`（小写）

2. **检查文件权限**
   - 确保账号有读取文件的权限
   - 某些 NAS 设备需要额外配置 WebDAV 权限

3. **检查路径**
   - 尝试从根目录开始浏览
   - 检查是否在正确的文件夹中

### 问题 4: "服务器响应无效"（207 状态码但解析失败）

**可能原因**:
- 服务器返回的 XML 格式不标准
- 编码问题

**解决方法**:

1. **联系开发者**
   - 提供你的 WebDAV 服务器类型
   - 我会添加特殊处理逻辑

2. **尝试其他 WebDAV 服务器**
   - 推荐使用坚果云（兼容性最好）
   - Nextcloud 也有很好的兼容性

### 问题 5: 文件下载失败

**可能原因**:
- 文件太大
- 网络超时
- 服务器限制

**解决方法**:

1. **检查文件大小**
   - 建议单个文件 < 50MB
   - 超大文件可能导致内存问题

2. **检查网络稳定性**
   - 使用稳定的 WiFi 网络
   - 避免使用移动网络（流量消耗大）

3. **重试下载**
   - 点击 "重试" 按钮
   - 如果多次失败，可能是服务器问题

## 支持的 WebDAV 服务器

### ✅ 已测试兼容

- **坚果云** - 推荐使用，国内速度快
- **Nextcloud** - 开源自建方案
- **ownCloud** - 类似 Nextcloud
- **Synology NAS** - 群晖 NAS WebDAV 服务
- **QNAP NAS** - 威联通 NAS WebDAV 服务

### ⚠️ 可能需要额外配置

- **阿里云盘** - 不支持 WebDAV（需第三方工具）
- **百度网盘** - 不支持 WebDAV
- **OneDrive** - 需要特殊适配（暂不支持）
- **Google Drive** - 需要特殊适配（暂不支持）

## 坚果云快速配置指南

### 步骤 1: 获取应用密码

1. 访问 https://www.jianguoyun.com/
2. 登录账号
3. 点击右上角头像 → 账户信息
4. 点击 "安全选项"
5. 找到 "第三方应用管理"
6. 点击 "添加应用" 或 "生成密码"
7. 输入应用名称（如 "番茄阅读器"）
8. 复制生成的应用密码

### 步骤 2: 在番茄中添加账号

打开番茄 App:
```
账号名称: 我的坚果云
服务器地址: https://dav.jianguoyun.com/dav/
用户名: your-email@example.com
密码: [粘贴应用密码]
```

### 步骤 3: 测试连接

1. 点击 "测试连接" 按钮
2. 应该显示 "连接成功 ✓"
3. 点击 "保存"

### 步骤 4: 上传文件

1. 在电脑上安装坚果云客户端
2. 将 `.txt` 文件放入同步文件夹
3. 等待自动同步
4. 在番茄 App 中刷新文件列表

## Nextcloud 快速配置指南

### 服务器地址格式

```
https://[你的域名]/remote.php/dav/files/[用户名]/
```

例如:
```
https://cloud.example.com/remote.php/dav/files/admin/
```

### 注意事项

1. 服务器地址必须以 `/` 结尾
2. 用户名是 Nextcloud 登录用户名
3. 可以使用应用专用密码（推荐）

## 调试技巧

### 启用详细日志（开发者）

如果你是开发者，可以添加调试输出：

1. 在 `WebDAVManager.swift` 的 `listFiles` 方法中添加:
```swift
print("🔍 请求 URL: \(fullURL)")
print("📊 响应状态码: \(httpResponse.statusCode)")
print("📄 响应数据大小: \(data.count) bytes")
```

2. 在 `WebDAVXMLParser` 的 `parse` 方法中添加:
```swift
print("📦 解析到 \(items.count) 个项目")
items.forEach { print("  - \($0.name) [\($0.isDirectory ? "文件夹" : "文件")]") }
```

### 使用 Charles/Proxyman 抓包

1. 安装 Charles 或 Proxyman
2. 配置 iOS 设备代理
3. 安装 HTTPS 证书
4. 观察 WebDAV 请求和响应
5. 检查 XML 响应格式

## 技术细节

### WebDAV PROPFIND 请求

```http
PROPFIND /dav/ HTTP/1.1
Host: dav.jianguoyun.com
Depth: 1
Content-Type: application/xml
Authorization: Basic [base64 credentials]
```

### XML 响应格式

```xml
<?xml version="1.0" encoding="utf-8"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>/dav/文件.txt</d:href>
    <d:propstat>
      <d:prop>
        <d:getcontentlength>12345</d:getcontentlength>
        <d:getlastmodified>Mon, 22 Oct 2025 09:00:00 GMT</d:getlastmodified>
        <d:resourcetype/>
      </d:prop>
    </d:propstat>
  </d:response>
  <d:response>
    <d:href>/dav/文件夹/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype>
          <d:collection/>
        </d:resourcetype>
      </d:prop>
    </d:propstat>
  </d:response>
</d:multistatus>
```

### 解析器特性

- 支持 `d:` 命名空间前缀和无前缀
- 自动解码 URL 编码（%E6%96%87等）
- 处理完整 URL 和相对路径
- 过滤掉当前目录本身
- 支持多种日期格式

## 联系支持

如果以上方法都无法解决问题，请提供以下信息：

1. **WebDAV 服务器类型** (坚果云/Nextcloud/NAS等)
2. **错误信息** (完整的错误提示)
3. **服务器地址格式** (隐藏敏感信息)
4. **测试结果** (能否在浏览器中访问)
5. **App 版本** 和 **iOS 版本**

## 更新日志

### v1.1 - 2025-10-22

✅ **修复**: WebDAV XML 解析器完整实现
✅ **修复**: URL 拼接逻辑优化
✅ **优化**: 增强服务器兼容性
✅ **优化**: 添加超时设置
✅ **优化**: 支持多种日期格式

---

**祝您阅读愉快！** 📚✨

