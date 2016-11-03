# File mode creation mask.
umask 022

# Ensure $TMPDIR.
[ -z "$TMPDIR" ] && export TMPDIR=/tmp

# Loading other files.
[ -f ~/bin/path-manip.bash ] && . ~/bin/path-manip.bash
[ -f ~/.bashrc.local ] && . ~/.bashrc.local
[ -n "$LOCAL_BUILD_ROOT" ] && [ -d "$LOCAL_BUILD_ROOT" ] && \
  [ -f "$LOCAL_BUILD_ROOT/bashrc.local" ] && . "$LOCAL_BUILD_ROOT/bashrc.local"

# PATHs.
prepend_path_c PATH ~/bin
clean_path

# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

# Stop terminal flow controls ^S and ^Q.
stty stop undef start undef

# Bash completion.
if [ -z "$BASH_COMPLETION" ]; then
  if [ -f "$LOCAL_BUILD_ROOT/linuxbrew/etc/bash_completion" ]; then
    . "$LOCAL_BUILD_ROOT/linuxbrew/etc/bash_completion"
  elif [ -f "~/.linuxbrew/etc/bash_completion" ]; then
    . "~/.linuxbrew/etc/bash_completion"
  fi
fi

# Define __git_ps1.
if __git_ps1 > /dev/null 2>&1; then :;else
  for f in /usr/share/git-core/contrib/completion/git-prompt.sh; do
    if [ -f "$f" ]; then
      . "$f"
      break
    fi
  done
fi
if __git_ps1 > /dev/null 2>&1; then :;else
  __git_ps1() { :; }
fi

# Prompts
#
# \[...\]              - Sequence for non-printing characters, which allows bash
#                        to calculate word wapping correctly.
# \e]2;...\a           - Title bar for xterm.
# \ek...\e\\           - Screen's title.
# \e[31;1m             - Red bold.
# \e[32;1m             - Green bold.
# \e[34;1m             - Blue bold.
# \e[0m                - Default color.
# $(__git_ps1 " (%s)") - Current Git branch.
#
case "$TERM" in
  linux)
    # prompt:
    #   [user@host Wd]
    #   $ ...
    export PS1='[\[\e[32;1m\]\u@\h \[\e[34;1m\]\W\[\e[31;1m\]$(__git_ps1 " (%s)")\[\e[0m\]]\n\$ '
    ;;
  xterm*|putty*)
    # titlebar:
    #   user@host:wd
    # prompt:
    #   [user@host Wd]
    #   $ ...
    export PS1='\[\e]2;\u@\h:\w\a\][\[\e[32;1m\]\u@\h \[\e[34;1m\]\W\[\e[31;1m\]$(__git_ps1 " (%s)")\[\e[0m\]]\n\$ '
    ;;
  screen*)
    # titlebar:
    #   user@host:wd
    # prompt:
    #   [user@host Wd]
    #   $ ...
    export PS1='\[\ek\e\\\e]2;\u@\h:\w\a\][\[\e[32;1m\]\u@\h \[\e[34;1m\]\W\[\e[31;1m\]$(__git_ps1 " (%s)")\[\e[0m\]]\n\$ '
    ;;
  *)
    # prompt:
    #   [user@host Wd]
    #   $ ...
    export PS1='[\u@\h \W$(__git_ps1 " (%s)")]\n\$ '
    ;;
esac

case "$TERM" in
  xterm)
    case "$COLORTERM" in
      gnome-terminal)
        export TERM=xterm-256color
        ;;
    esac
    ;;
esac

screen-update-env() {
  case "$1" in
    xterm*)
      export VIM_256COLOR=1
      export VIM_BACKGROUND=light
      export VIM_POWERLINE=
      \screen -X setenv VIM_256COLOR 1
      \screen -X setenv VIM_BACKGROUND light
#      \screen -X setenv VIM_POWERLINE ''
      ;;
    putty*)
      export VIM_256COLOR=1
      export VIM_BACKGROUND=dark
      export VIM_POWERLINE=1
      \screen -X setenv VIM_256COLOR 1
      \screen -X setenv VIM_BACKGROUND dark
#      \screen -X setenv VIM_POWERLINE 1
      ;;
    *)
      echo 'Usage: screen-update-env [xterm|putty]' 2>&1
      return 1
      ;;
  esac
}

# Other Bash settings.

shopt -u histappend
shopt -s checkwinsize
if [ -z "$PROMPT_COMMAND_HISTORY_A" ]; then
  export PROMPT_COMMAND_HISTORY_A=1
  if [ -n "$PROMPT_COMMAND" ]; then
    export PROMPT_COMMAND="$PROMPT_COMMAND;history -a"
  else
    export PROMPT_COMMAND='history -a'
  fi
fi
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth
export HISTIGNORE='&:fg:bg:exit:history'

# Aliases.

alias ls='ls -hF --show-control-chars --color'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

alias df='df -h'
alias du='du -h'
alias grep='grep -n --color'
alias less='less -R -w -XXX'
alias screen='screen -D -RR'
alias ssh='ssh -X -2 -C'

if type vim >/dev/null 2>&1; then
  alias vi='vim'
  alias view='vim -R'
  alias uvi='vim -c ":e ++enc=utf8"'
  export EDITOR=`which vim`
  export GIT_EDITOR=$EDITOR
fi

if type colordiff >/dev/null 2>&1; then
  alias diff='colordiff -u'
else
  alias diff='diff -u'
fi

alias top='nice top'
alias htop='nice htop'

# Process Status Tree: shows the currently-running processes in the tree format.
#   Usage: pst
alias pst='ps f -o user,pid,ppid,pgid,tty,stat,stime,time,%cpu,%mem,command'

# Disk Usage Directory: shows file space usage in the current directory.
#   Usage: dud
alias dud='du --max-depth=1 --block-size=1M --total | sort -n'

# Screen Directory: sets the starting directory of GNU screen.
#   Usage: sd [<dir>]
sd() {
  \screen -X chdir "`pwd`/$*"
}

# Screen Title: sets the session name in GNU screen.
#   Usage: st [[<oldname>] <newname>]
st() {
  if [ -z "$1" ]; then
    \screen -X sessionname `basename "$PWD"`
  elif [ -z "$2" ]; then
    \screen -X sessionname "$1"
  else
    \screen -S "$1" -X sessionname "$2"
  fi
}

# CLear: clears the terminal window. Doesn't work under GNU screen.
#   Usage: cl
cl() {
  resize -s 43 132
  clear
}

[ -f ~/bin/copyd.sh ] &&  . ~/bin/copyd.sh

[ -d ~/bin/enhancd ] && { type fzf >/dev/null 2>&1 || \
                          type peco >/dev/null 2>&1 || \
                          type percol >/dev/null 2>&1; } && {
  . ~/bin/enhancd/init.sh
}
