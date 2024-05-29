# For profiling. http://stackoverflow.com/a/20855353
if [ -n "$BASH_STARTUPTIME" ]; then
  exec 3>&2 2> >( tee ~/bash-startup.tmp1 |
                  sed -u 's/^.*$/now/' |
                  date -f - +%s.%N >~/bash-startup.tmp2)
  set -x
fi

# File mode creation mask.
umask 022

# Ensure $TMPDIR.
[ -z "$TMPDIR" ] && export TMPDIR=/tmp

# Loading other files.
[ -f ~/bin/path-manip.bash ] && . ~/bin/path-manip.bash
[ -f ~/.bashrc.local ] && . ~/.bashrc.local
[ -n "$LOCAL_BUILD_ROOT" ] && [ -f "$LOCAL_BUILD_ROOT/bashrc.local" ] && \
  . "$LOCAL_BUILD_ROOT/bashrc.local"
[ -n "$EASYBUILD_PREFIX" ] && [ -d "$EASYBUILD_PREFIX/modules/all" ] && \
  { module use "$EASYBUILD_PREFIX/modules/all"; module load EasyBuild; }

# Linuxbrew
if [ -z "$DISABLE_HOMEBREW" ]; then
  if [ -d ~/.linuxbrew ]; then
    eval $(~/.linuxbrew/bin/brew shellenv)
  elif [ -d /home/linuxbrew/.linuxbrew ]; then
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  fi
fi

# cargo
prepend_path_c PATH ~/.cargo/bin

# pip --user / pipx
prepend_path_c PATH ~/.local/bin

# bin directory
prepend_path_c PATH ~/bin

# direnv
if type direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

# Stop terminal flow controls ^S and ^Q.
stty stop undef start undef

# Fish or not.
if [ -n "$FORCE_BASH" ]; then
  unset FORCE_BASH
  alias bash='FORCE_BASH=1 command bash'
else
  [ -n "$I_LIKE_FISH" ] && type fish >/dev/null 2>&1 && exec fish
fi

# pipx
if command -v register-python-argcomplete pipx >/dev/null; then
  eval "$(register-python-argcomplete pipx)"
fi

# Bash completion.
if [ -z "$BASH_COMPLETION" ]; then
  for f in "$LOCAL_BUILD_ROOT/linuxbrew/etc/bash_completion" \
           "$HOME/.linuxbrew/etc/bash_completion" \
           "/home/linuxbrew/.linuxbrew/etc/bash_completion" \
           "/etc/bash_completion"; do
    if [ -f $(echo "$f") ]; then
      . "$f"
      break
    fi
  done
fi

# Ensure __git_ps1.
if __git_ps1 >/dev/null 2>&1; then :;else
  if type git >/dev/null 2>&1; then
    for f in $(dirname $(dirname $(command -v git)))/{share/git-core/contrib/completion,etc/bash_completion.d}/git-prompt.sh; do
      if [ -f "$f" ]; then
        . "$f"
        break
      fi
    done
  fi
fi
if __git_ps1 > /dev/null 2>&1; then :;else
  __git_ps1() { :; }
fi

# Prompt.
#
# \[...\]              - Sequence for non-printing characters, which allows bash
#                        to calculate word wrapping correctly.
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

# Prompt for direnv + virtualenv
if type direnv >/dev/null 2>&1; then
  show_virtual_env() {
    if [ -n "$VIRTUAL_ENV" ]; then
      echo "($(basename $VIRTUAL_ENV))"
    fi
  }
  export -f show_virtual_env
  PS1='$(show_virtual_env)'$PS1
fi

# Terminal.
case "$TERM" in
  xterm)
    case "$COLORTERM" in
      gnome-terminal)
        export TERM=xterm-256color
        ;;
    esac
    ;;
esac

# Light color scheme.
light() {
  export VIM_BACKGROUND=light
  case "$TERM" in
    screen*)
      \screen -X setenv VIM_BACKGROUND light
      ;;
  esac
}

# Dark color scheme.
dark() {
  export VIM_BACKGROUND=dark
  case "$TERM" in
    screen*)
      \screen -X setenv VIM_BACKGROUND dark
      ;;
  esac
}

# Other Bash settings.

shopt -u histappend
shopt -s checkwinsize
if [ -z "$PROMPT_COMMAND_HISTORY_A" ]; then
  export PROMPT_COMMAND_HISTORY_A=1
  if [ -n "$PROMPT_COMMAND" ]; then
    if [ ";" = "${PROMPT_COMMAND: -1}" ]; then
      export PROMPT_COMMAND="${PROMPT_COMMAND}history -a"
    else
      export PROMPT_COMMAND="$PROMPT_COMMAND;history -a"
    fi
  else
    export PROMPT_COMMAND='history -a'
  fi
fi
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth
export HISTIGNORE='&:fg:bg:exit:history'

# Aliases.

alias c='command'

alias ls='ls --classify --color --group-directories-first --human-readable --show-control-chars'
alias ll='ls -l'
alias la='ls --almost-all'
alias l='ls'

alias df='df -h'
alias du='du -h'
alias grep='grep -n --color'
alias less='less -R -w -XXX'
alias screen='screen -D -RR -U'
alias ssh='ssh -X -2 -C'

if type vim >/dev/null 2>&1; then
  alias vi='vim'
  alias view='vim -R'
  alias uvi='vim -c ":e ++enc=utf8"'
  export EDITOR=`which vim`
  export GIT_EDITOR=$EDITOR
fi

if type colordiff >/dev/null 2>&1; then
  if type diff-highlight >/dev/null 2>&1; then
    function diff() { colordiff -u "$@" | diff-highlight; }
  else
    alias diff='colordiff -u'
  fi
else
  if type diff-highlight >/dev/null 2>&1; then
    function diff() { command diff -u "$@" | diff-highlight; }
  else
    alias diff='diff -u'
  fi
fi

# "eza" as a modern replacement for "ls".
if type eza >/dev/null 2>&1; then
  alias ls='eza --classify --git --group-directories-first --header'
elif type exa >/dev/null 2>&1; then
  alias ls='exa --classify --git --group-directories-first --header'
fi
alias la='ls --all'

# Process Status Tree: shows the currently-running processes in the tree format.
#   Usage: pst
alias pst='ps f -o user,pid,ppid,pgid,tty,stat,stime,time,%cpu,%mem,command'

# Screen Directory: sets the starting directory of GNU screen.
#   Usage: sd [<dir>]
sd() {
  \screen -X chdir "`pwd`/$*"
}

alias s='sd'

# Screen List: lists sessions of GNU screen.
alias sl='screen -ls'

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

# "nice" for system monitors.
alias top='nice top'
alias htop='nice htop'
alias btm='nice btm'

[ -f ~/.bashrc.local-after ] && . ~/.bashrc.local-after

# For profiling.
if [ -n "$BASH_STARTUPTIME" ]; then
  set +x
  exec 2>&3 3>&-
  paste <(
    while read tim ;do
      [ -z "$last" ] && last=${tim//.} && first=${tim//.}
      crt=000000000$((${tim//.}-10#0$last))
      ctot=000000000$((${tim//.}-10#0$first))
      printf "%12.9f %12.9f\n" ${crt:0:${#crt}-9}.${crt:${#crt}-9} \
                               ${ctot:0:${#ctot}-9}.${ctot:${#ctot}-9}
      last=${tim//.}
    done <~/bash-startup.tmp2
  ) <(
    echo START
    head -n -1 ~/bash-startup.tmp1
  ) >~/bash-startup.log
  rm -f ~/bash-startup.tmp1 ~/bash-startup.tmp2
fi
