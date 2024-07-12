### SHELL OPTIONS ###
setopt autocd correct globdots extendedglob nomatch notify
unsetopt beep
bindkey -e

### AUTOCOMPLETION ###
autoload -Uz compinit
compinit
zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion:*' menu select

### HISTORY ###
setopt share_history inc_append_history hist_expire_dups_first hist_reduce_blanks hist_find_no_dups
HISTFILE=~/.histfile
HISTSIZE=10000000
SAVEHIST=100000
HISTCONTROL=ignorespace

# History search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

### PROMPT ###
autoload -Uz promptinit
promptinit

if [[ $USER == "root" ]]; then
    user_color="red"
else
    user_color="white"
fi

# Work in default toolbox (no hostname set)
if [[ -v TOOLBOX_PATH ]]; then
    host_color=magenta
else
  case $HOSTNAME in;
    laptop)
      host_color=green
      ;;
    workstation)
      host_color=red
      ;;
    bryan-pc)
      host_color=cyan
      ;;
    time4vps)
      host_color=blue
      ;;
    racknerd)
      host_color=yellow
      ;;
    htpc)
      host_color=blue
      ;;
    hartmanlab)
      host_color=magenta
      ;;
  esac
fi

PS1="[%F{${user_color}}%n%F{white}@%{%F{${host_color}}%}%m%F{white}]%~$ "
case $TERM in
    xterm*)
        precmd () {print -Pn "\e]0;${PWD/$HOME/\~}\a"}
        ;;
esac
### PATH ###
typeset -U PATH path
BINPATH="$HOME/bin"
GOPATH="$HOME/go"
path+=("${GOPATH//://bin:}/bin" "$HOME/Documents/develop/scripts/shell" "$HOME/.local/bin" "$HOME/.local/bin/*")
export PATH

### ALIASES ###
alias vmd='vmd -nt'
alias -g dnf-list-files='dnf repoquery -l'
alias -g gedit='gnome-text-editor'
alias -g dnf='dnf5'
# alias xclip="xclip -selection c" # shouldn't need this on wayland, use wl-copy instead
alias -g pdoman="podman"
alias virtualenv-workon="workon"
alias git-list="git ls-tree -r master --name-only"

### KEYBINDINGS ###
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[ShiftTab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-buffer-or-history
[[ -n "${key[ShiftTab]}"  ]] && bindkey -- "${key[ShiftTab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start {
		echoti smkx
	}
	function zle_application_mode_stop {
		echoti rmkx
	}
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# Functions
function podman-update-images () {
    podman images |grep -v REPOSITORY|awk '{print $1}'|xargs -L1 podman pull
}

function extract()
{
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xvjf $1     ;;
             *.tar.gz)    tar xvzf $1     ;;
             *.bz2)       bunzip2 $1      ;;
             *.rar)       unrar x $1      ;;
             *.gz)        gunzip $1       ;;
             *.tar)       tar xvf $1      ;;
             *.tbz2)      tar xvjf $1     ;;
             *.tgz)       tar xvzf $1     ;;
             *.zip)       unzip $1        ;;
             *.Z)         uncompress $1   ;;
             *.7z)        7z x $1         ;;
             *)           echo "'$1' cannot be extracted via >extract<" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

function buildah-prune() {
    buildah containers | cut -d" " -f 1 | tail -n +2| xargs buildah rm
}
