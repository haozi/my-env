# CLI 环境安装说明

> 适用平台：`macOS`、`Linux`、`Windows WSL`
>
> 目标：在新机器上安装一套统一的最新版 CLI 开发环境，并按平台自动跳过不适用的软件。

## 1. 设计原则

- 优先安装最新版，不绑定旧机器版本
- 自动识别 `macOS / Linux / WSL`
- 不在 Linux / WSL 上安装 `brew`、Android Studio 之类 macOS 专属软件
- 尽量统一 shell、Node、Python、Rust、Bun、Git、GPG 的使用方式
- GUI 或强交互步骤单独列出，避免脚本半成功半失败

## 2. 统一入口

仓库统一入口：

```bash
bash scripts/bootstrap.sh
```

如果要让 AI 执行，推荐的任务描述是：

```text
Fetch and run the bootstrap script from github.com/haozi/my-env on this machine, detect whether the environment is macOS, Linux, or WSL, install only the software that applies to the current platform, and summarize any remaining manual GUI steps.
```

## 3. 通用安装项

这几类工具会尽量在所有平台上保持一致：

- `git`
- `curl`
- `wget`
- `jq`
- `gnupg`
- `zsh`
- `fnm`
- 最新 LTS `Node.js`
- npm 全局 CLI
- `Miniconda`
- `Rust` / `Cargo`
- `Bun`

默认会安装这些 npm 全局工具：

- `@anthropic-ai/claude-code`
- `@dotenvx/dotenvx`
- `@openai/codex`
- `@vibe-cafe/vibe-usage`
- `corepack`
- `eas-cli`
- `git-cz`
- `npm`
- `pnpm`
- `tldr`

额外安装：

- `@github/copilot` 通过 `pnpm add -g`

## 4. macOS 路径

### 4.1 包管理器

使用 `Homebrew`：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 4.2 Homebrew 包

```bash
brew install \
  ffmpeg \
  fnm \
  gnupg \
  jq \
  kubectl \
  pinentry \
  proxychains-ng \
  rmtrash \
  ruby \
  wget
```

### 4.3 macOS 额外能力

以下只在 macOS 路径下默认启用：

- `oh-my-zsh`
- `autojump`
- `Flutter`
- `Android Studio`
- `Android SDK`
- `CocoaPods`

### 4.4 shell 关键配置

```bash
export PATH="/opt/homebrew/bin:$PATH"
eval "$(fnm env --use-on-cd)"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export GPG_TTY=$(tty)
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/flutter/bin:$PATH"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PNPM_HOME="$HOME/Library/pnpm"
```

## 5. Linux / WSL 路径

### 5.1 包管理器

当前脚本默认支持 `apt`：

```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  ca-certificates \
  curl \
  ffmpeg \
  git \
  gnupg \
  jq \
  unzip \
  wget \
  zsh
```

### 5.2 Linux / WSL 不默认安装的内容

这些内容不会默认在 Linux / WSL 上安装：

- `brew`
- `rmtrash`
- `proxychains-ng`
- `ruby` / `cocoapods`
- `Android Studio`
- `Flutter`
- `Android SDK`

如果以后 Linux 端也确实需要这些组件，再单独加平台分支。

### 5.3 shell 关键配置

```bash
eval "$(fnm env --use-on-cd)"
export GPG_TTY=$(tty)
export PATH="$HOME/.cargo/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PNPM_HOME="$HOME/.local/share/pnpm"
```

## 6. Node / npm / pnpm

统一使用 `fnm`：

```bash
curl -fsSL https://fnm.vercel.app/install | bash
```

然后安装最新 LTS Node：

```bash
fnm install --lts
fnm default lts-latest
fnm use lts-latest
```

安装 npm 全局工具：

```bash
npm install -g \
  @anthropic-ai/claude-code \
  @dotenvx/dotenvx \
  @openai/codex \
  @vibe-cafe/vibe-usage \
  corepack \
  eas-cli \
  git-cz \
  npm \
  pnpm \
  tldr
```

安装 Copilot：

```bash
pnpm add -g @github/copilot
```

## 7. Python / conda

统一用 `Miniconda`，默认安装到 `~/.conda`。

macOS:

```bash
curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o miniconda.sh
```

Linux / WSL:

```bash
curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh
```

安装与初始化：

```bash
bash miniconda.sh -b -p "$HOME/.conda"
rm miniconda.sh
"$HOME/.conda/bin/conda" init zsh
"$HOME/.conda/bin/conda" config --set auto_activate true
"$HOME/.conda/bin/conda" config --set changeps1 false
```

## 8. Rust / Cargo

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
```

建议在 `~/.zshenv` 和 `~/.profile` 保留：

```bash
. "$HOME/.cargo/env"
```

## 9. Bun

```bash
curl -fsSL https://bun.sh/install | bash
```

## 10. macOS 专属扩展

这些步骤只在 macOS 上做：

### Flutter

```bash
git clone -b stable https://github.com/flutter/flutter.git "$HOME/flutter"
```

### Android Studio

下载并安装：

- https://developer.android.com/studio

### Android SDK

```bash
yes | sdkmanager --sdk_root="$HOME/Library/Android/sdk" --licenses
sdkmanager --sdk_root="$HOME/Library/Android/sdk" "cmdline-tools;latest"
sdkmanager --sdk_root="$HOME/Library/Android/sdk" "platform-tools" "emulator"
```

### CocoaPods

```bash
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
gem install cocoapods --no-document
```

## 11. Docker / VS Code / GPG

这部分跨平台都常用，但仍然有人工步骤。

### Docker Desktop

macOS:

- https://www.docker.com/products/docker-desktop/

Linux:

- 按发行版安装 Docker Engine 或 Docker Desktop

WSL:

- 通常通过 Windows 侧 Docker Desktop + WSL integration

### VS Code

- https://code.visualstudio.com/

安装后启用 `code` 命令。

### GPG

```bash
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=long
```

示例 Git 配置：

```ini
[alias]
  co = checkout
  br = branch
  ci = commit
  st = status
[user]
  name = haozi
  email = syntaxright@gmail.com
  signingkey = REPLACE_WITH_YOUR_GPG_KEY_ID
[commit]
  gpgsign = true
[gpg]
  program = gpg
```

## 12. 验证命令

安装完成后建议至少检查：

```bash
git --version
curl --version
jq --version
fnm --version
node -v
npm -v
pnpm -v
bun --version
conda --version
python3 --version
rustc --version
cargo --version
gpg --version
```

仅 macOS 建议再检查：

```bash
brew --version
ruby --version
gem --version
pod --version
flutter doctor
adb version
sdkmanager --version
kubectl version --client
```

## 13. 已知边界

- 当前自动化脚本已经支持 `macOS + apt-based Linux + WSL`
- 还没有覆盖 `dnf`、`yum`、`pacman` 等 Linux 发行版分支
- 原生 Windows PowerShell 不在当前支持范围内
- 私有仓库的一行执行默认依赖你已经 `gh auth login`
