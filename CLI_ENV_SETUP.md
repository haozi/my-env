# Mac CLI 开发环境安装说明

> 目标：在一台全新的 Apple Silicon Mac 上，按统一清单安装最新版 CLI 开发环境，并恢复常用 shell 配置。
>
> 原则：优先安装最新版，不绑定旧机器上的具体版本号；保留少量与当前工作流强相关的固定路径约定。

## 1. 总体安装顺序

按这个顺序执行，依赖关系最少，PATH 也最稳定：

1. 安装 Xcode Command Line Tools
2. 安装 Homebrew
3. 用 Homebrew 安装基础 CLI 工具
4. 安装 Oh My Zsh
5. 安装 autojump
6. 安装 fnm，并用它安装最新 LTS Node.js
7. 安装全局 npm / pnpm CLI
8. 安装 Miniconda 到 `~/.conda`
9. 安装 Rust / Cargo
10. 安装 Bun
11. 安装 Flutter 到 `~/flutter`
12. 安装 Android Studio 和 Android SDK
13. 安装 Homebrew Ruby 下的 CocoaPods
14. 安装 Docker Desktop
15. 安装 kubectl
16. 安装 VS Code 和 `code` 命令
17. 安装并配置 GPG 签名
18. 恢复 `~/.zshrc`、`~/.zshenv`、`~/.profile`、`~/.gitconfig`

## 2. 基础系统工具

### Xcode Command Line Tools

```bash
xcode-select --install
```

### Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

把 Homebrew 放到 PATH 前面：

```bash
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
```

## 3. Homebrew 基础工具

安装当前工作流会用到的常用 CLI：

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

如果你还想尽量贴近当前机器的依赖面，也可以补装这一组：

```bash
brew install \
  ca-certificates \
  dav1d \
  gettext \
  gmp \
  gnutls \
  lame \
  libassuan \
  libevent \
  libgcrypt \
  libgpg-error \
  libidn2 \
  libksba \
  libnghttp2 \
  libtasn1 \
  libunistring \
  libusb \
  libvpx \
  libyaml \
  nettle \
  npth \
  openssl@3 \
  opus \
  p11-kit \
  readline \
  sdl2 \
  svt-av1 \
  unbound \
  x264 \
  x265
```

用途概览：

- `fnm`: Node.js 版本管理
- `ruby`: 独立 Ruby，避免依赖系统 Ruby
- `gnupg` + `pinentry`: Git 提交签名
- `jq`: JSON 处理
- `ffmpeg`: 音视频处理
- `proxychains-ng`: 代理链
- `rmtrash`: 用废纸篓替代直接删除
- `kubectl`: Kubernetes CLI
- `wget`: 下载工具

## 4. Shell 环境

### Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

默认保留：

- Theme: `robbyrussell`
- Plugins: `git`

### autojump

建议继续沿用现在的安装方式：

```bash
git clone https://github.com/wting/autojump.git ~/Downloads/autojump
cd ~/Downloads/autojump
python3 install.py
```

## 5. Node.js / npm / pnpm

### fnm

`fnm` 已由 Homebrew 安装。把它接入 shell：

```bash
echo 'eval "$(fnm env --use-on-cd)"' >> ~/.zshrc
```

安装最新 LTS Node：

```bash
fnm install --lts
fnm default lts-latest
fnm use lts-latest
```

如果以后有兼容性需求，再补装旧版本：

```bash
fnm install 16
fnm install 20
fnm install 22
```

### npm 全局 CLI

安装当前工作流里的常用全局工具，全部拉最新版：

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

### pnpm

如果希望独立安装 pnpm，也可以执行：

```bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

### pnpm 全局 CLI

```bash
pnpm add -g @github/copilot
```

## 6. Python / conda

用 Miniconda 安装到 `~/.conda`：

```bash
curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o miniconda.sh
bash miniconda.sh -b -p "$HOME/.conda"
rm miniconda.sh
```

初始化并设置行为：

```bash
"$HOME/.conda/bin/conda" init zsh
conda config --set auto_activate true
conda config --set changeps1 false
```

说明：

- 路径约定保留为 `~/.conda`
- 默认进入 shell 时自动激活 `base`
- 不修改 shell prompt 样式

## 7. Rust / Cargo

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
```

`~/.zshenv` 和 `~/.profile` 里都保留：

```bash
. "$HOME/.cargo/env"
```

如果你希望在 `~/.zshrc` 也显式补 PATH：

```bash
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
```

## 8. Ruby / CocoaPods

使用 Homebrew Ruby，不依赖系统 Ruby：

```bash
brew install ruby
```

把 Homebrew Ruby 放到 PATH 前面：

```bash
echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.zshrc
```

安装 CocoaPods：

```bash
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
gem install cocoapods --no-document
```

如果之后 Ruby 主版本变化，用户 gem bin 路径也会变化，所以不要把旧机器的 `~/.gem/ruby/<ruby-version>/bin` 硬编码到说明里；按安装后的实际版本补 PATH 即可。

## 9. Bun

```bash
curl -fsSL https://bun.sh/install | bash
```

安装脚本通常会自动写入配置；如果没有，就补上：

```bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
```

## 10. Flutter / Android

### Flutter

保留现在的目录约定：

```bash
git clone -b stable https://github.com/flutter/flutter.git "$HOME/flutter"
```

加入 PATH：

```bash
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
```

### Android Studio

从官网下载并安装：

- https://developer.android.com/studio

### Android SDK 环境变量

把下面这些配置加入 `~/.zshrc`：

```bash
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"
```

### Android SDK 命令行工具

首次安装 Android Studio 后，执行：

```bash
yes | sdkmanager --sdk_root="$HOME/Library/Android/sdk" --licenses
sdkmanager --sdk_root="$HOME/Library/Android/sdk" "cmdline-tools;latest"
sdkmanager --sdk_root="$HOME/Library/Android/sdk" "platform-tools" "emulator"
```

注意：

- 不要保留重复的 `cmdline-tools/latest-2` 之类目录
- 只保留标准的 `cmdline-tools/latest`
- 当前工作流依赖 Android Studio 自带 JBR，所以 `JAVA_HOME` 指向 Android Studio 安装目录

## 11. Docker / Kubernetes

### Docker Desktop

从官网下载：

- https://www.docker.com/products/docker-desktop/

安装完成后确认：

```bash
docker --version
docker compose version
```

### kubectl

如果前面没装过：

```bash
brew install kubectl
```

## 12. VS Code

从官网下载：

- https://code.visualstudio.com/

安装后在 VS Code 内执行：

1. `Cmd+Shift+P`
2. 运行 `Shell Command: Install 'code' command in PATH`

然后确认：

```bash
code --version
```

## 13. GPG / Git 提交签名

### GPG

```bash
brew install gnupg pinentry
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=long
```

在 `~/.zshrc` 加入：

```bash
export GPG_TTY=$(tty)
```

### Git 配置

把 `~/.gitconfig` 恢复为你的个人配置，例如：

```ini
[alias]
  co = checkout
  br = branch
  ci = commit
  st = status
[user]
  name = haozi
  email = syntaxright@gmail.com
  signingkey = 1DCD7EF36E215599
[commit]
  gpgsign = true
[gpg]
  program = gpg
```

如果需要继续使用提交签名，别忘了导入旧机器上的 GPG 私钥。

## 14. 建议保留的 `~/.zshrc` 关键配置

下面这份是推荐保留的核心片段，已经改成“装最新版”思路，不再绑定旧版本号：

```bash
# Homebrew
export PATH="/opt/homebrew/bin:$PATH"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# rm -> rmtrash
alias rm='rmtrash'

# fnm
eval "$(fnm env --use-on-cd)"

# autojump
export PATH="$HOME/.autojump/bin:$PATH"
[[ -s "$HOME/.autojump/etc/profile.d/autojump.sh" ]] && source "$HOME/.autojump/etc/profile.d/autojump.sh"
autoload -U compinit && compinit -u

# conda
# 由 conda init 自动注入

# local bin
export METACODE_HOME="$HOME/.local/bin"
export PATH="$METACODE_HOME:$PATH"

# Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# GPG
export GPG_TTY=$(tty)

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Flutter
export PATH="$HOME/flutter/bin:$PATH"

# Android
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
```

`~/.zshenv` 和 `~/.profile` 建议都保留：

```bash
. "$HOME/.cargo/env"
```

## 15. 安装完成后的验证命令

全部装完后，至少跑一遍这些命令：

```bash
brew --version
fnm --version
node -v
npm -v
pnpm -v
bun --version
conda --version
python3 --version
rustc --version
cargo --version
ruby --version
gem --version
pod --version
flutter doctor
adb version
sdkmanager --version
docker --version
docker compose version
kubectl version --client
gpg --version
code --version
```

## 16. 这份清单里补齐了什么

相对旧文档，这份已经补上并统一了这些点：

- 改成“安装最新版”，不再强调旧机器版本
- 加入 `jq`
- 加入 `kubectl`
- 加入 VS Code 和 `code` 命令
- 加入 `@dotenvx/dotenvx`
- 加入 `@github/copilot`
- 保留 `autojump`
- 保留 GPG 提交签名配置
- 保留 Android Studio JBR 路径约定
- 去掉旧 Ruby 用户目录里的硬编码版本号
- 明确 Android SDK 不要保留重复 `latest-2` 目录

## 17. 后续建议

如果你准备让 AI 在其他机器上全自动执行，下一步最值得做的是把这份说明再拆成 3 个文件：

1. `Brewfile`
2. `bootstrap-macos.sh`
3. `dotfiles/.zshrc`

这样 AI 不需要读整篇文档再拼命令，直接执行脚本即可。
