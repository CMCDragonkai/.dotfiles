# This .zshrc is sourced only on interactive sessions.
# This script sets up interactive utilities.

# Global options

HISTFILE='~/.zsh_history'
HISTSIZE=10000
SAVEHIST=10000

setopt \
    appendhistory \
    autocd \
    extendedglob \
    nomatch \
    interactivecomments \
    hist_ignore_all_dups \
    hist_ignore_space \
    auto_continue \
    check_jobs \
    hup \
    monitor \
    notify

unsetopt beep

# Completions

zstyle :compinstall filename "${HOME}/.zshrc"
autoload -Uz compinit
compinit

# ZSH Environment Variables

TTY="$(tty)"

ifelse(PH_SYSTEM, NIXOS, 
    HELPDIR="${HELPDIR:-/run/current-system/sw/share/zsh/${ZSH_VERSION}/help}"
, PH_SYSTEM, CYGWIN, 
    HELPDIR="${HELPDIR:-/usr/share/zsh/${ZSH_VERSION}/help}"
)

# ZSH Functions

include(shell_functions.conf.m4)

# ZSH Aliases

include(shell_aliases.conf.m4)

# Sets up `help` command similar to bash.
unalias run-help 2>/dev/null
autoload run-help
alias help='run-help'

# ZSH Prompt

PROMPT='%{$fg[green]%}%n%{$reset_color%} ➜ %{$fg[yellow]%}%m%{$reset_color%} ➜ %{$fg_bold[green]%}${PWD/#$HOME/~}%{$reset_color%} 
 ೱ ' 

RPROMPT='%{$fg[cyan]%}%D %*' 

# ZSH keys

# Enable Vi key bindings
bindkey -v

# Allows one to use Ctrl + Z to switch between foreground and background
_ctrl-z () {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line
    else
        zle push-input
        zle clear-screen
    fi
}
zle -N _ctrl-z
bindkey '^Z' _ctrl-z

# Shift + Tab will now always enter a literal tab
# Works on Cygwin and Konsole
# Also it does prevent reverse tabbing when autocomplete starts, but you can use arrow keys instead
bindkey -s '\e[Z' '^V^I'