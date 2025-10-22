# GitHub 推送指南

## 认证问题

当你看到 `fatal: could not read Username for 'https://github.com'` 错误时，说明需要配置 GitHub 认证。

## 解决方案（3 种方式）

### 🔐 方式 1: Personal Access Token（推荐）

#### 步骤 1: 生成 Token

1. 访问 https://github.com/settings/tokens
2. 点击 "Generate new token" → "Generate new token (classic)"
3. 设置：
   - Note: `Tomato Project`
   - Expiration: 选择有效期（建议 90 days）
   - 勾选权限：
     - ✅ `repo`（完整仓库访问）
     - ✅ `workflow`（如果使用 GitHub Actions）
4. 点击 "Generate token"
5. **立即复制 Token**（只显示一次！）

#### 步骤 2: 使用 Token 推送

```bash
cd /Users/macchuzu/Documents/Tomeo/Tomato

# 方法 A: 在推送时输入（推荐）
git push origin main
# Username: Heartcoolman
# Password: [粘贴 Token]

# 方法 B: 在 URL 中包含 Token
git remote set-url origin https://YOUR_TOKEN@github.com/Heartcoolman/Tomato.git
git push origin main
```

#### 步骤 3: 保存凭据（可选）

让 macOS 记住 Token：
```bash
git config --global credential.helper osxkeychain
git push origin main
# 输入一次后，以后自动使用
```

---

### 🔑 方式 2: SSH 密钥（一劳永逸）

#### 步骤 1: 生成 SSH 密钥

```bash
# 检查是否已有密钥
ls -al ~/.ssh

# 如果没有，生成新密钥
ssh-keygen -t ed25519 -C "your-email@example.com"
# 按 Enter 使用默认路径，设置密码（可选）

# 启动 ssh-agent
eval "$(ssh-agent -s)"

# 添加私钥
ssh-add ~/.ssh/id_ed25519

# 复制公钥
pbcopy < ~/.ssh/id_ed25519.pub
```

#### 步骤 2: 添加到 GitHub

1. 访问 https://github.com/settings/keys
2. 点击 "New SSH key"
3. Title: `Mac - Tomato Project`
4. Key: 粘贴刚才复制的公钥
5. 点击 "Add SSH key"

#### 步骤 3: 切换到 SSH

```bash
cd /Users/macchuzu/Documents/Tomeo/Tomato

# 修改远程 URL
git remote set-url origin git@github.com:Heartcoolman/Tomato.git

# 测试连接
ssh -T git@github.com
# 应该看到: Hi Heartcoolman! You've successfully authenticated...

# 推送
git push origin main
```

---

### 🛠️ 方式 3: GitHub CLI（最简单）

#### 步骤 1: 安装 GitHub CLI

```bash
# 使用 Homebrew
brew install gh

# 或下载安装包
# https://cli.github.com/
```

#### 步骤 2: 认证

```bash
gh auth login
# 选择: GitHub.com
# 选择: HTTPS
# 选择: Login with a web browser
# 复制 code，在浏览器中授权
```

#### 步骤 3: 推送

```bash
cd /Users/macchuzu/Documents/Tomeo/Tomato
git push origin main
```

---

## 🚀 推送完整流程

### 1. 推送 WebDAV 修复（已 commit）

```bash
cd /Users/macchuzu/Documents/Tomeo/Tomato

# 配置认证后
git push origin main
```

### 2. 提交并推送新文档

```bash
# 添加新文档
git add FEATURE_RECOMMENDATIONS.md TEST_WEBDAV.md

# 提交
git commit -m "📝 文档: 添加功能建议和测试指南

新增文档:
- FEATURE_RECOMMENDATIONS.md - 15个功能建议清单
- TEST_WEBDAV.md - WebDAV 测试指南

内容包括:
- 数据可视化、白噪音、项目标签等功能建议
- 优先级排序和开发时间估算
- 详细的测试步骤和检查清单"

# 推送
git push origin main
```

### 3. 查看结果

```bash
# 查看推送历史
git log --oneline -5

# 访问 GitHub 仓库
open https://github.com/Heartcoolman/Tomato
```

---

## ⚠️ 常见问题

### Q1: Token 推送后还是要求输入密码

**A**: 确保已设置凭据助手：
```bash
git config --global credential.helper osxkeychain
```

### Q2: SSH 连接失败

**A**: 检查公钥是否正确添加：
```bash
ssh -T git@github.com
```

### Q3: 推送被拒绝（remote ahead）

**A**: 先拉取远程更改：
```bash
git pull origin main --rebase
git push origin main
```

### Q4: 权限被拒绝

**A**: 检查 Token 权限是否包含 `repo`

---

## 📊 推送状态检查

```bash
# 查看本地领先多少 commit
git status

# 查看将要推送的 commit
git log origin/main..HEAD

# 查看详细差异
git diff origin/main..HEAD
```

---

## 🎯 推荐方式

**新手**: 使用方式 3 (GitHub CLI) - 最简单  
**长期**: 使用方式 2 (SSH) - 最安全方便  
**临时**: 使用方式 1 (Token) - 快速上手

---

## 🔒 安全提示

1. ⚠️ **永远不要把 Token 提交到代码里**
2. ⚠️ **定期轮换 Token**
3. ⚠️ **不要分享 Token**
4. ⚠️ **使用最小权限原则**

---

**需要帮助？** 告诉我你选择哪种方式，我可以进一步指导！

