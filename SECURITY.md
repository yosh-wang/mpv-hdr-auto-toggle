# 🔒 安全政策

## 🚨 报告安全漏洞

如果你发现本项目的安全漏洞，**请不要公开 Issue**。

请通过以下方式私密报告：

- 🛡️ 在 GitHub 上创建 [安全公告](https://github.com/yosh-wang/mpv-hdr-auto-toggle/security/advisories/new)
- 📧 或通过 GitHub Issue 联系维护者（设为私密）

## ⚠️ 安全注意事项

本项目涉及调用外部可执行文件（`HDRCmd.exe`），请确保：

1. 📦 从官方来源 [HDRTray/releases](https://github.com/res2k/HDRTray/releases) 下载 HDRCmd.exe
2. 🔧 配置文件中的路径不要包含不可信的用户输入
3. 🛡️ 不要以管理员权限运行 mpv，除非必要

## 📍 受支持版本

| 版本 | 支持状态 |
|:---|:---|
| latest | ✅ 支持 |
| 其他 | ❌ 不支持 |
