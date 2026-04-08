# my-env

一套面向 `macOS`、`Linux`、`Windows WSL` 的 CLI 开发环境仓库。

目标：

- 在新机器上安装一套统一的最新版开发工具链
- 自动识别当前平台，只安装该平台需要的软件
- 避免在 Linux / WSL 上安装 `brew` 这类 macOS 特有工具
- 让 AI 可以通过一条命令或一条任务说明直接执行初始化

## 一行执行

如果当前机器已经登录 GitHub，并且可以访问这个私有仓库，直接执行：

```bash
gh repo clone haozi/my-env "$HOME/my-env" && cd "$HOME/my-env" && bash scripts/bootstrap.sh
```

如果仓库已经在本地：

```bash
cd /path/to/my-env && bash scripts/bootstrap.sh
```

## 一行 AI 任务

把下面这行直接丢给 AI 即可：

```text
Clone the private repo haozi/my-env, run scripts/bootstrap.sh on this machine, detect whether the environment is macOS, Linux, or WSL, skip platform-specific software that does not apply, and report any remaining manual GUI steps.
```

## 仓库内容

- `README.md`
  - 仓库入口和一行执行方式
- `CLI_ENV_SETUP.md`
  - 跨平台安装说明
- `Brewfile`
  - macOS Homebrew 包清单
- `scripts/bootstrap.sh`
  - 跨平台统一安装入口
- `scripts/bootstrap-macos-cli.sh`
  - 兼容旧入口，内部转发到 `bootstrap.sh`
- `dotfiles/.zshrc`
  - 跨平台 shell 模板
- `dotfiles/.zshenv`
  - Cargo 环境入口
- `dotfiles/.profile`
  - Cargo 环境入口
- `dotfiles/.gitconfig.example`
  - Git / GPG 配置示例

## 平台策略

### macOS

- 使用 `Homebrew`
- 安装 `fnm`、`ruby`、`kubectl`、`ffmpeg`、`rmtrash` 等
- 支持 Flutter / Android Studio / CocoaPods 这类 Apple 生态相关工具

### Linux

- 使用系统包管理器，当前脚本支持 `apt`
- 不安装 `brew`
- 不默认安装 macOS 专属工具

### Windows WSL

- 按 Linux 路径执行，当前以 `apt` 为基础
- 不安装 macOS GUI 软件
- 不默认配置原生 Windows 工具链

## 主要会自动安装什么

- Git / curl / wget / jq / gnupg / zsh
- fnm + 最新 LTS Node.js
- npm 全局 CLI
- Miniconda
- Rust / Cargo
- Bun
- 可选安装的 Flutter
- 可选安装的 kubectl

## 仍需人工完成的步骤

这些步骤很难完全自动化，脚本会提示但不会强行代做：

- Android Studio 安装与首次打开
- Docker Desktop 安装
- VS Code 安装和 `code` 命令启用
- GPG 私钥导入
- Android SDK GUI 组件检查

## 推荐流程

1. 在目标机器上先确保有 `git` 和 `gh`
2. 执行上面的“一行执行”
3. 根据脚本输出完成剩余人工步骤
4. 重启 shell

## 注意

- 私有仓库推荐先执行 `gh auth login`
- `bootstrap.sh` 会按平台分流，不会在 Linux / WSL 上安装 `brew`
- `Flutter`、`Android`、`CocoaPods` 只在 macOS 路径下默认启用
