# file mode creation mask
umask 022

################################################################################

# append_path VAR PATH
append_path() {
  [ $# -lt 2 ] && return
  [ ! -d "$2" ] && echo "Warning: path $2 is not found on `hostname`" >&2
  remove_path $1 $2
  if eval '[ -z "$'$1'" ]'; then
    eval $1=$2
  else
    eval $1='$'$1:$2
  fi
  export $1
}

# prepend_path VAR PATH
prepend_path() {
  [ $# -lt 2 ] && return
  [ ! -d "$2" ] && echo "Warning: path $2 is not found on `hostname`" >&2
  remove_path $1 $2
  if eval '[ -z "$'$1'" ]'; then
    eval $1=$2
  else
    eval $1=$2:'$'$1
  fi
  export $1
}

# remove_path VAR PATH
remove_path() {
  [ $# -lt 2 ] && return
  eval $1'=${'$1'//:$2/}'
  eval $1'=${'$1'//$2:/}'
  eval '[ "$'$1'" == "'$2'" ]' && eval $1=
  export $1
}

# set_path VAR PATH
set_path() {
  [ ! -d "$2" ] && echo "Warning: path $2 is not found on `hostname`" >&2
  eval "$1=$2"
  export $1
}

# set_env VAR VALUE
set_env() {
  [ $# -lt 1 ] && return
  eval "$1=$2"
  export $1
}

# append_path_c VAR PATH
append_path_c() {
  [ -d "$2" ] && append_path "$1" "$2"
}

# prepend_path_c VAR PATH
prepend_path_c() {
  [ -d "$2" ] && prepend_path "$1" "$2"
}

# set_path_c VAR PATH
set_path_c() {
  [ -d "$2" ] && set_path "$1" "$2"
}

# split_path [VAR]
split_path() {
  local path='$'${1:-PATH}
  path=`eval "echo $path"`
  local IFS=':'
  for p in $path; do
    echo "$p"
  done
}

################################################################################

# init_plenv [ROOT_DIR]
init_plenv() {
  local dir=${1:-~/.plenv}
  if [ -d "$dir" ]; then
    prepend_path PATH "$dir/bin"
    export PLENV_ROOT=$dir
    eval "$(plenv init - --no-rehash)"
  fi
}

# init_pyenv [ROOT_DIR]
init_pyenv() {
  local dir=${1:-~/.pyenv}
  if [ -d "$dir" ]; then
    prepend_path PATH "$dir/bin"
    export PYENV_ROOT=$dir
    eval "$(pyenv init - --no-rehash)"
    if which pyenv-virtualenv-init > /dev/null; then
      eval "$(pyenv virtualenv-init -)"
    fi
  fi
}

# init_rbenv [ROOT_DIR]
init_rbenv() {
  local dir=${1:-~/.rbenv}
  if [ -d "$dir" ]; then
    prepend_path PATH "$dir/bin"
    export RBENV_ROOT=$dir
    eval "$(rbenv init - --no-rehash)"
  fi
}

# init_homebrew [ROOT_DIR]
init_homebrew() {
  local dir=$1
  if [ -z "$dir" ]; then
    local uname=`uname -s`
    if [ "$uname" = Darwin ]; then
      dir=/usr/local
    elif [ `expr substr "$uname" 1 5` = Linux ]; then
      dir=~/.linuxbrew
    else
      dir=~/homebrew
    fi
  fi
  if [ -d "$dir" ]; then
    export HOMEBREW_PREFIX=$dir
    export HOMEBREW_CACHE="$dir/Cache"
    export HOMEBREW_LOGS="$dir/Logs"
    prepend_path_c PATH "$dir/sbin"
    prepend_path PATH "$dir/bin"
    prepend_path MANPATH "$dir/share/man"
    prepend_path_c INFOPATH "$dir/share/info"
    prepend_path_c C_INCLUDE_PATH "$dir/include"
    prepend_path_c CPLUS_INCLUDE_PATH "$dir/include"
    prepend_path_c OBJC_INCLUDE_PATH "$dir/include"
    prepend_path_c LIBRARY_PATH "$dir/lib"
    prepend_path_c LD_RUN_PATH "$dir/lib"
    if [ -f "$dir/bin/plenv" ]; then
      export PLENV_ROOT="$dir/var/plenv"
      eval "$(plenv init - --no-rehash)"
    fi
    if [ -f "$dir/bin/pyenv" ]; then
      export PYENV_ROOT="$dir/var/pyenv"
      eval "$(pyenv init - --no-rehash)"
    fi
    if [ -f "$dir/bin/rbenv" ]; then
      export RBENV_ROOT="$dir/var/rbenv"
      eval "$(rbenv init - --no-rehash)"
    fi
  fi
}

# init_texlive [ROOT_DIR]
init_texlive() {
  local dir=${1:-~/texlive}
  if [ -d "$dir" ]; then
     for dir in `echo $dir/20??`; do :; done
     export TEXLIVE_ROOT=$dir
     prepend_path PATH "$dir"/bin/*
     prepend_path MANPATH "$dir"/texmf-dist/doc/man
     prepend_path INFOPATH "$dir"/texmf-dist/doc/info
  fi
}

################################################################################

[ -z "$TMPDIR" ] && set_path_c TMPDIR /tmp

if [ -z "$BASHRC_LOCAL_LOADED" ]; then
  # In the case that the quota for the home directory is small, it would be nice
  # to install software to another local storage.
  unset LOCAL_BUILD_ROOT

  # Local settings.
  [ -f ~/.bashrc.local ] && . ~/.bashrc.local
  [ -d "$LOCAL_BUILD_ROOT" ] && [ -f "$LOCAL_BUILD_ROOT/bashrc.local" ] && \
    . "$LOCAL_BUILD_ROOT/bashrc.local"

  prepend_path_c PATH ~/bin
  append_path_c FORMPATH ~/lib/form
  [ -z "$FORMTMP" ] && set_path_c FORMTMP $TMPDIR

  export BASHRC_LOCAL_LOADED=1
fi

reload_path() {
  # Reinitialize everything to keep the order of pathes.
  unset BASHRC_LOCAL_LOADED
  unset LOCAL_BUILD_ROOT
  unset HOMEBREW_PREFIX
  unset PLENV_ROOT
  unset PYENV_ROOT
  unset RBENV_ROOT
# unset TEXLIVE_ROOT
  . ~/.bashrc
}

################################################################################

if [ -d "$LOCAL_BUILD_ROOT" ]; then
  [ -z "$HOMEBREW_PREFIX" ] && [ -d "$LOCAL_BUILD_ROOT/linuxbrew" ] && \
    init_homebrew "$LOCAL_BUILD_ROOT/linuxbrew"
  [ -z "$PLENV_ROOT" ] && [ -d "$LOCAL_BUILD_ROOT/plenv" ] && \
    init_plenv "$LOCAL_BUILD_ROOT/plenv"
  [ -z "$PYENV_ROOT" ] && [ -d "$LOCAL_BUILD_ROOT/pyenv" ] && \
    init_pyenv "$LOCAL_BUILD_ROOT/pyenv"
  [ -z "$RBENV_ROOT" ] && [ -d "$LOCAL_BUILD_ROOT/rbenv" ] && \
    init_rbenv "$LOCAL_BUILD_ROOT/rbenv"
# [ -z "$TEXLIVE_ROOT" ] && [ -d "$LOCAL_BUILD_ROOT/texlive" ] && \
#   init_texlive "$LOCAL_BUILD_ROOT/texlive"
fi

[ -z "$HOMEBREW_PREFIX" ] && [ -d "~/.linuxbrew" ] && \
  init_homebrew "~/.linuxbrew"
[ -z "$PLENV_ROOT" ] && [ -d "~/.plenv" ] && \
  init_plenv "~/.plenv"
[ -z "$PYENV_ROOT" ] && [ -d "~/.pyenv" ] && \
  init_pyenv "~/.pyenv"
[ -z "$RBENV_ROOT" ] && [ -d "~/.rbenv" ] && \
  init_plenv "~/.rbenv"

################################################################################

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

# Terminal capabilities.
case "$TERM" in
  xterm*)
    case "$COLORTERM" in
      gnome-terminal)
        export TERM=xterm-256color
        ;;
      *)
        if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
          export VIM_256COLOR=1
        fi
        ;;
    esac
    ;;
  putty*)
    export VIM_256COLOR=1
    export VIM_BACKGROUND=dark
    # My Windows laptop has Powerline fonts :-)
    export VIM_POWERLINE=1
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
      \screen -X setenv VIM_POWERLINE ''
      ;;
    putty*)
      export VIM_256COLOR=1
      export VIM_BACKGROUND=dark
      export VIM_POWERLINE=1
      \screen -X setenv VIM_256COLOR 1
      \screen -X setenv VIM_BACKGROUND dark
      \screen -X setenv VIM_POWERLINE 1
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

# Process Status Tree: show the currently-running processes in the tree format.
#   Usage: pst
alias pst='ps f -o user,pid,ppid,pgid,tty,stat,stime,time,%cpu,%mem,command'

# Disk Usage Directory: show file space usage in the current directory.
#   Usage: dud
alias dud='du --max-depth=1 --block-size=1M --total | sort -n'

# Screen Directory: set the starting directory of GNU screen.
#   Usage: sd [<dir>]
sd() {
  \screen -X chdir "`pwd`/$*"
}

# Screen Title: set the session name in GNU screen.
#   Usage: st [<oldname>] <newname>
st() {
  if [ -n "$2" ]; then
    \screen -S "$1" -X sessionname "$2"
  else
    \screen -X sessionname "$1"
  fi;
}

# CLear: clear the terminal window. Doesn't work under GNU screen.
#   Usage: cl
cl() {
  resize -s 43 132
  clear
}

# copyd & pasted
[ -f ~/bin/copyd.sh ] &&  . ~/bin/copyd.sh
