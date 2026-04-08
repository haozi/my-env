#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

append_if_missing() {
  local target_file="$1"
  local marker="$2"
  local content="$3"

  mkdir -p "$(dirname "$target_file")"
  touch "$target_file"

  if ! grep -Fq "$marker" "$target_file"; then
    printf '\n%s\n' "$content" >>"$target_file"
  fi
}

detect_platform() {
  if [ "${FORCE_PLATFORM:-}" != "" ]; then
    printf '%s\n' "$FORCE_PLATFORM"
    return
  fi

  case "$(uname -s)" in
    Darwin)
      printf 'macos\n'
      ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        printf 'wsl\n'
      else
        printf 'linux\n'
      fi
      ;;
    *)
      printf 'unsupported\n'
      ;;
  esac
}

install_homebrew() {
  if ! need_cmd brew; then
    log "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

install_apt_packages() {
  log "Installing apt packages"
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
}

install_macos_packages() {
  install_homebrew
  log "Installing Homebrew packages"
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
}

install_fnm() {
  if ! need_cmd fnm; then
    log "Installing fnm"
    curl -fsSL https://fnm.vercel.app/install | bash
  fi
}

setup_node() {
  log "Installing latest LTS Node"
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "$(fnm env --use-on-cd)"
  fnm install --lts
  fnm default lts-latest
  fnm use lts-latest
}

install_npm_globals() {
  log "Installing npm global packages"
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

  pnpm add -g @github/copilot
}

install_miniconda() {
  if [ -x "$HOME/.conda/bin/conda" ]; then
    log "Miniconda already installed"
  else
    log "Installing Miniconda"
    case "$PLATFORM" in
      macos)
        curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o /tmp/miniconda.sh
        ;;
      linux|wsl)
        curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh
        ;;
    esac
    bash /tmp/miniconda.sh -b -p "$HOME/.conda"
    rm -f /tmp/miniconda.sh
  fi

  "$HOME/.conda/bin/conda" init zsh || true
  "$HOME/.conda/bin/conda" config --set auto_activate true
  "$HOME/.conda/bin/conda" config --set changeps1 false
}

install_rust() {
  if [ ! -f "$HOME/.cargo/env" ]; then
    log "Installing Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
}

install_bun() {
  if ! need_cmd bun && [ ! -x "$HOME/.bun/bin/bun" ]; then
    log "Installing Bun"
    curl -fsSL https://bun.sh/install | bash
  fi
}

setup_macos_extras() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Installing oh-my-zsh"
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  if [ ! -d "$HOME/.autojump" ]; then
    log "Installing autojump"
    rm -rf /tmp/autojump
    git clone https://github.com/wting/autojump.git /tmp/autojump
    python3 /tmp/autojump/install.py
    rm -rf /tmp/autojump
  fi

  if [ ! -d "$HOME/flutter" ]; then
    log "Installing Flutter"
    git clone -b stable https://github.com/flutter/flutter.git "$HOME/flutter"
  fi

  if need_cmd gem; then
    log "Installing CocoaPods"
    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    gem install cocoapods --no-document || true
  fi
}

write_shell_files() {
  local zshrc="$HOME/.zshrc"
  local zshenv="$HOME/.zshenv"
  local profile="$HOME/.profile"

  append_if_missing "$zshenv" '. "$HOME/.cargo/env"' '. "$HOME/.cargo/env"'
  append_if_missing "$profile" '. "$HOME/.cargo/env"' '. "$HOME/.cargo/env"'

  case "$PLATFORM" in
    macos)
      append_if_missing "$zshrc" "# >>> my-env bootstrap >>>" '
# >>> my-env bootstrap >>>
export PATH="/opt/homebrew/bin:$PATH"
alias rm='"'"'rmtrash'"'"'
eval "$(fnm env --use-on-cd)"
export PATH="$HOME/.autojump/bin:$PATH"
[[ -s "$HOME/.autojump/etc/profile.d/autojump.sh" ]] && source "$HOME/.autojump/etc/profile.d/autojump.sh"
autoload -U compinit && compinit -u
export METACODE_HOME="$HOME/.local/bin"
export PATH="$METACODE_HOME:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export GPG_TTY=$(tty)
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/flutter/bin:$PATH"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# <<< my-env bootstrap <<<
'
      ;;
    linux|wsl)
      append_if_missing "$zshrc" "# >>> my-env bootstrap >>>" '
# >>> my-env bootstrap >>>
eval "$(fnm env --use-on-cd)"
export GPG_TTY=$(tty)
export PATH="$HOME/.cargo/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# <<< my-env bootstrap <<<
'
      ;;
  esac
}

print_manual_steps() {
  case "$PLATFORM" in
    macos)
      cat <<'EOF'

Manual follow-up still required on macOS:
1. Install Android Studio and open it once.
2. Install Android SDK cmdline-tools/platform-tools/emulator if needed.
3. Install Docker Desktop.
4. Install VS Code and enable the `code` command.
5. Import your GPG secret key if you use signed commits.
6. Restart the shell.
EOF
      ;;
    linux|wsl)
      cat <<'EOF'

Manual follow-up still required on Linux / WSL:
1. Install Docker or Docker Desktop if needed.
2. Install VS Code and enable the `code` command if desired.
3. Import your GPG secret key if you use signed commits.
4. Restart the shell.
EOF
      ;;
  esac
}

FORCE_PLATFORM=""
while [ $# -gt 0 ]; do
  case "$1" in
    --platform)
      FORCE_PLATFORM="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

PLATFORM="$(detect_platform)"
if [ "$PLATFORM" = "unsupported" ]; then
  echo "Unsupported platform" >&2
  exit 1
fi

log "Detected platform: $PLATFORM"

case "$PLATFORM" in
  macos)
    log "macOS path selected"
    install_macos_packages
    ;;
  linux|wsl)
    log "Linux/WSL path selected"
    install_apt_packages
    ;;
esac

install_fnm
write_shell_files
setup_node
install_npm_globals
install_miniconda
install_rust
install_bun

if [ "$PLATFORM" = "macos" ]; then
  setup_macos_extras
fi

cat <<EOF

Verification commands:
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
EOF

if [ "$PLATFORM" = "macos" ]; then
  cat <<'EOF'
  brew --version
  ruby --version
  gem --version
  pod --version
  flutter doctor
  adb version
  sdkmanager --version
  kubectl version --client
EOF
fi

print_manual_steps
