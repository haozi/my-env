export PATH="/opt/homebrew/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

alias rm='rmtrash'

eval "$(fnm env --use-on-cd)"

export PATH="$HOME/.autojump/bin:$PATH"
[[ -s "$HOME/.autojump/etc/profile.d/autojump.sh" ]] && source "$HOME/.autojump/etc/profile.d/autojump.sh"
autoload -U compinit && compinit -u

# conda init block is managed by `conda init zsh`

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
