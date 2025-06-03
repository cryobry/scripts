# Shell options
setopt autocd correct globdots extendedglob nomatch notify \
  share_history inc_append_history hist_expire_dups_first hist_reduce_blanks \
  hist_find_no_dups hist_verify extended_history auto_pushd pushd_ignore_dups \
  prompt_subst
unsetopt beep
bindkey -e

# Load secrets
if [[ -f "$HOME/develop/scripts/dotfiles/zsh/.env" ]]; then
  set -a # automatically export all variables
  source "$HOME/develop/scripts/dotfiles/zsh/.env"
  set +a
fi

# Completions
local compdump=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${HOST}-${ZSH_VERSION}
[[ -d ${compdump:h} ]] || mkdir -p ${compdump:h}
zstyle ':completion:*' menu select
zstyle ':completion:*' gain-privileges 1
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zmodload zsh/complist
autoload -Uz compinit && compinit -d "$compdump"

# History
HISTFILE=${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history
[[ -d $HISTFILE:h ]] || mkdir -p $HISTFILE:h
HISTSIZE=100000
SAVEHIST=100000
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Colors
autoload -Uz colors && colors

# Prompt
if [[ $EUID -eq 0 ]]; then
  user_color=red
else
  user_color=white
fi

# Assign colors based on the hostname
if [[ -v TOOLBOX_PATH ]]; then
  host_color=magenta
elif [[ -v DISTROBOX_ENTER_PATH ]]; then
  host_color=15
else
  case $HOSTNAME in
    laptop)       host_color=green ;;
    workstation)  host_color=red ;;
    bryan-pc)     host_color=cyan ;;
    time4vps)     host_color=blue ;;
    racknerd)     host_color=yellow ;;
    htpc)         host_color=214 ;;
    hartmanlab)   host_color=magenta ;;
    router)       host_color=blue ;;
    ax6000)       host_color=87 ;;
    home-router)  host_color=218 ;;
    vm-fedora*)   host_color=57 ;;
    *)            host_color=white ;;
  esac
fi

_git_prompt() {
  local br
  if br=$(git symbolic-ref --short HEAD 2>/dev/null); then
    print -n " %F{242}($br)%f"
  fi
}

PROMPT='[%F{'$user_color'}%n%f@%F{'$host_color'}%m%f]%~$(_git_prompt)%(!.#.$) '
RPROMPT='%*'
precmd() { print -Pn "\e]0;%n@%m: ${PWD/#$HOME/~}\a" }

# Set hostname on OpenWRT
[[ -z $HOSTNAME ]] && HOSTNAME=$(noglob uci get system.@system[0].hostname 2>/dev/null)

# Paths
typeset -U path PATH
path=(
  $HOME/bin
  $HOME/.local/bin
  $HOME/documents/develop/scripts/shell
  $path
)
export PATH
export R_LIBS_USER="$HOME/R/qhtcp-workflow"

# Aliases
alias ll='ls -lh'
alias la='ls -A'
alias vmd='vmd -nt'
alias dnf-list-files='dnf repoquery -l'
alias gedit='gnome-text-editor'
alias xclip='xclip -selection c'
alias pdoman='podman'
alias workon='virtualenv-workon'
alias git-list='git ls-tree -r HEAD --name-only'
alias chatgpt='chatgpt --model gpt-4o'

# Keybindings
typeset -g -A key
for k v in \
  Home khome End kend Insert kich1 Backspace kbs Delete kdch1 \
  Up kcuu1 Down kcud1 Left kcub1 Right kcuf1 PageUp kpp PageDown knp ShiftTab kcbt; do
  [[ -n ${terminfo[$v]} ]] && key[$k]=${terminfo[$v]}
 done
bindkey -- ${key[Home]-}      beginning-of-line
bindkey -- ${key[End]-}       end-of-line
bindkey -- ${key[Insert]-}    overwrite-mode
bindkey -- ${key[Backspace]-} backward-delete-char
bindkey -- ${key[Delete]-}    delete-char
bindkey -- ${key[Left]-}      backward-char
bindkey -- ${key[Right]-}     forward-char
bindkey -- ${key[PageUp]-}    beginning-of-buffer-or-history
bindkey -- ${key[PageDown]-}  end-of-buffer-or-history
bindkey -- ${key[ShiftTab]-}  reverse-menu-complete
bindkey -- ${key[Up]-}        up-line-or-beginning-search
bindkey -- ${key[Down]-}      down-line-or-beginning-search

if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  autoload -Uz add-zle-hook-widget
  zle_app_start()  { echoti smkx; }
  zle_app_finish() { echoti rmkx; }
  add-zle-hook-widget zle-line-init    zle_app_start
  add-zle-hook-widget zle-line-finish  zle_app_finish
fi

# Functions
podman-update-images() {
  podman images --format '{{.Repository}}' | grep -v '^<none>$' | xargs -r -L1 podman pull
}

buildah-prune() { buildah rm --all; }
