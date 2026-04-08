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

BREW_FORMULAE=(
  ffmpeg
  fnm
  gnupg
  jq
  kubectl
  p11-kit
  pinentry
  proxychains-ng
  rmtrash
  ruby
  wget
)

NPM_GLOBALS=(
  @anthropic-ai/claude-code
  @dotenvx/dotenvx
  @openai/codex
  @vibe-cafe/vibe-usage
  corepack
  eas-cli
  git-cz
  npm
  pnpm
  tldr
)

ZSH_SNIPPET='
# >>> bitff cli bootstrap >>>
alias rm='\''rmtrash'\''

export PATH="/opt/homebrew/bin:$PATH"
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
# <<< bitff cli bootstrap <<<
'

log "Install Xcode Command Line Tools manually first if not already present."

if ! need_cmd brew; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

log "Installing Homebrew formulae"
brew install "${BREW_FORMULAE[@]}"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing oh-my-zsh"
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

log "Ensuring shell snippets exist"
append_if_missing "$HOME/.zshrc" "# >>> bitff cli bootstrap >>>" "$ZSH_SNIPPET"
append_if_missing "$HOME/.zshenv" '. "$HOME/.cargo/env"' '. "$HOME/.cargo/env"'
append_if_missing "$HOME/.profile" '. "$HOME/.cargo/env"' '. "$HOME/.cargo/env"'

export PATH="/opt/homebrew/bin:/opt/homebrew/opt/ruby/bin:$PATH"

log "Installing latest LTS Node via fnm"
eval "$(fnm env --use-on-cd)"
fnm install --lts
fnm default lts-latest
fnm use lts-latest

log "Installing npm global packages"
npm install -g "${NPM_GLOBALS[@]}"
pnpm add -g @github/copilot

if ! need_cmd conda; then
  log "Installing Miniconda into \$HOME/.conda"
  curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o /tmp/miniconda.sh
  bash /tmp/miniconda.sh -b -p "$HOME/.conda"
  rm -f /tmp/miniconda.sh
fi

"$HOME/.conda/bin/conda" init zsh
"$HOME/.conda/bin/conda" config --set auto_activate true
"$HOME/.conda/bin/conda" config --set changeps1 false

if [ ! -f "$HOME/.cargo/env" ]; then
  log "Installing Rust via rustup"
  curl https://sh.rustup.rs -sSf | sh -s -- -y
fi

if [ ! -x "$HOME/.bun/bin/bun" ]; then
  log "Installing Bun"
  curl -fsSL https://bun.sh/install | bash
fi

if [ ! -d "$HOME/flutter" ]; then
  log "Installing Flutter"
  git clone -b stable https://github.com/flutter/flutter.git "$HOME/flutter"
fi

log "Installing CocoaPods with Homebrew Ruby"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
gem install cocoapods --no-document

cat <<'EOF'

Manual follow-up still required:
1. Install Android Studio.
2. Open Android Studio once so bundled JBR exists at:
   /Applications/Android Studio.app/Contents/jbr/Contents/Home
3. Install Android SDK cmdline-tools/platform-tools/emulator.
4. Then run:
   yes | sdkmanager --sdk_root="$HOME/Library/Android/sdk" --licenses
   sdkmanager --sdk_root="$HOME/Library/Android/sdk" "cmdline-tools;latest"
   sdkmanager --sdk_root="$HOME/Library/Android/sdk" "platform-tools" "emulator"
5. Install and import your GPG secret key if you want signed commits.
6. Restart the shell.

Verification commands:
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
EOF
