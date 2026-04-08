# my-env

一套用于新 Mac 快速恢复 CLI 开发环境的仓库，面向 Apple Silicon。

目标：

- 安装最新版常用 CLI 工具
- 恢复统一的 shell / PATH / Git / GPG / Android / Flutter 配置
- 让 AI 或脚本可以在新电脑上按固定清单自动完成初始化

## 仓库内容

- `CLI_ENV_SETUP.md`
  - 人类可读的完整安装说明
- `Brewfile`
  - Homebrew 包清单
- `scripts/bootstrap-macos-cli.sh`
  - 一键化 bootstrap 脚本
- `dotfiles/.zshrc`
  - 推荐保留的核心 shell 配置
- `dotfiles/.zshenv`
  - Cargo 环境入口
- `dotfiles/.profile`
  - Cargo 环境入口
- `dotfiles/.gitconfig.example`
  - Git / GPG 配置示例

## 推荐使用方式

### 1. 先安装 Xcode Command Line Tools

```bash
xcode-select --install
```

### 2. 拉取仓库

```bash
git clone https://github.com/haozi/my-env.git
cd my-env
```

### 3. 执行 bootstrap

```bash
bash scripts/bootstrap-macos-cli.sh
```

### 4. 按文档完成人工步骤

主要是这些：

- 安装 Android Studio
- 安装 Docker Desktop
- 安装 VS Code，并启用 `code` 命令
- 导入 GPG 私钥
- 重启 shell

## 设计原则

- 以最新版为默认目标，不锁定旧机器版本
- 只保留少量必要的固定路径约定
- 尽量把机器可执行步骤落进脚本
- 需要人工决策或 GUI 的步骤放进文档

## 注意

- `JAVA_HOME` 默认指向 Android Studio 自带 JBR
- `Flutter` 默认安装到 `~/flutter`
- `conda` 默认安装到 `~/.conda`
- 不要在 Android SDK 下保留重复的 `cmdline-tools/latest-*` 目录
