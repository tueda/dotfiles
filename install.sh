#! /bin/bash
set -eu
set -o pipefail

cd `dirname $0`

# Environment variables.

if [ -z ${LOCAL_BUILD_ROOT+x} ]; then
  LOCAL_BUILD_ROOT=
fi

# Check the OS.
uname=`uname -s`
if [ "$uname" = Darwin ]; then
  osname=osx
elif [ `expr substr "$uname" 1 5` = Linux ]; then
  osname=linux
else
  osname=unknown_os
fi

# MAKEFLAGS for multi-core machines.
JOBS=0
if [ -e /proc/cpuinfo ]; then
  JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
  if [ $JOBS -ge 1 ]; then
    MAKEFLAGS="-j $JOBS ${MAKEFLAGS:-}"
    export MAKEFLAGS
  fi
fi

# Portable "echo -n"
echo_n() {
  echo $ECHO_N "$@"$ECHO_C
}

ECHO_C=
ECHO_N=

case `echo -n x` in
  -n*)
    case `echo 'x\c'` in
      *c*)
        ;;
      *)
        ECHO_C='\c'
        ;;
    esac
    ;;
  *)
    ECHO_N='-n'
    ;;
esac

# Wraps "mktemp -d $1XXXXXXXXXX"
mktemp_d() {(
  umask 077
  {
    # Use mktemp if available.
    dir=`mktemp -d "$1XXXXXXXXXX" 2>/dev/null` && [ -d "$dir" ]
  } || {
    # Fall back on mkdir.
    dir=
    i=0
    while [ $i -lt 100 ]; do
      next_dir=$1$$$i$RANDOM$RANDOM
      if mkdir "$next_dir" >/dev/null 2>&1; then
        dir=$next_dir
        break
      fi
      i=`expr $i + 1`
    done
    [ "x$dir" != x ] && [ -d "$dir" ]
  } || {
    echo "mktemp_d: failed to create a temporary directory" >&2
    return 1
  }
  echo "$dir"
)}

curl_enabled=:
wget_enabled=:

# Even if curl fails, wget may work.
[ -z ${INSTALL_SH_DISABLE_CURL+x} ] || [ "$INSTALL_SH_DISABLE_CURL" == 1 ] && \
  curl_enabled=false

# Wraps "wget $1"
download() {
  if $curl_enabled && type curl >/dev/null 2>&1; then
    curl -O -L "$1"
  elif $wget_enabled && type wget >/dev/null 2>&1; then
    wget -O `basename "$1"` "$1"
  else
    echo "error: curl or wget required" >&2
    return 1
  fi
  case "$1" in
    *.tar.gz)
      gzip -dc `basename "$1"` | tar xvf -
      ;;
    *.tar.bz2)
      bzip2 -dc `basename "$1"` | tar xvf -
      ;;
  esac
}

make_bin=`type -p make`  # requires bash

# Wraps "make ..."
make() {
  $make_bin $* || exit 1
}

# Prints bashrc.local file.
get_bashrc_local() {
  if [ -n "$LOCAL_BUILD_ROOT" ]; then
    echo "$LOCAL_BUILD_ROOT/bashrc.local"
  else
    echo "$HOME/.bashrc.local"
  fi
}

_rc_first=:
_rc_indentation=
_rc_indent_level=0

_rc_write() {
  _rc_out=`get_bashrc_local`
  # _rc_out=/dev/stdout  # for debugging
  if $_rc_first; then
    _rc_first=false
    echo "# $prefix" >>$_rc_out
  fi
  echo "$_rc_indentation$1" >>$_rc_out
}

_rc_indent() {
  _rc_indent_level=$(($_rc_indent_level+1))
  _rc_update_identation
}

_rc_dedent() {
  _rc_indent_level=$(($_rc_indent_level-1))
  _rc_update_identation
}

_rc_update_identation() {
  _rc_indentation=
  for ((n=1; n<=$_rc_indent_level; n++)); do
    _rc_indentation="$_rc_indentation  "
  done
}

# Appends the given path in .bashrc.local.
rc_append_path() {
  _rc_write "$1=\"\$$1:$2\"; export $1"
}

# Prepends the given path in .bashrc.local.
rc_prepend_path() {
  _rc_write "$1=\"$2:\$$1\"; export $1"
}

# Sets the given path in .bashrc.local.
rc_set_path() {
  _rc_write "$1=\"$2\"; export $1"
}

# Evaluate the result of the command in .bashrc.lcaol.
rc_eval_cmd() {
  _rc_write "eval \"\$($1)\""
}

# "if"-statement in .bashrc.local.
rc_if() {
  _rc_write "if $1; then"
  _rc_indent
}

# "fi"-statement in .bashrc.local.
rc_fi() {
  _rc_dedent
  _rc_write 'fi'
}

show_help() {
  cat << END
Usage: install.sh [--postinstall] [--overwrite] <packages>...

Available packages:
END
ls packages
  cat << END

Environment variables:
LOCAL_BUILD_ROOT=$LOCAL_BUILD_ROOT
END
}

install_package() {
# XXX: No lock mechanism.
  pkgname=$1
  pkgver=
  prefix=
  . "packages/$pkgname"
  if [ -z "$prefix" ]; then
    if [ -n "$LOCAL_BUILD_ROOT" ]; then
      prefix="$LOCAL_BUILD_ROOT/$pkgname"
    else
      prefix="$HOME/opt/$pkgname"
    fi
    if [ -n "${pkgver:-}" ]; then
      prefix="$prefix-$pkgver"
    fi
  fi

  if $opt_postinstall; then :; else
    if do_install_package; then :; else
      echo "error: failed to install $pkgname." >&2
      $opt_overwrite || rm -rf "$prefix"
      exit 1
    fi
  fi

  if [ ! -d "$prefix" ]; then
    echo "error: empty installation by $pkgname." >&2
    exit 1
  fi

  do_postinstall_package

  echo "Succeeded to install $pkgname."
  bashrc_local=`get_bashrc_local`
  if [ -f "$bashrc_local" ]; then
    echo "Run/put the following line in .bashrc:"
    echo "  . $bashrc_local"
  fi
}

do_install_package() {
  if [ -e "$prefix" ]; then
    if $opt_overwrite; then
      echo "warning: $prefix already exists" >&2
    else
      echo "error: $prefix already exists" >&2
      exit 1
    fi
  fi
  cat << END
This script will install $pkgname to
  $prefix
END
  echo_n 'Okay? (y/n) : '
  read answer
  if [ "x$answer" != "xy" ] && [ "x$answer" != "xY" ]; then
    echo 'Exit. No installation.'
    exit
  fi

  tmpdir=`mktemp_d "${TMPDIR:-/tmp}/build-"`
  trap 'rm -rf "$tmpdir"' 0 1 2 13 15
  (cd "$tmpdir" && do_install)
}

do_postinstall_package() {
  if type do_postinstall >/dev/null 2>&1; then
    do_postinstall
  fi
}

# Main entry point.

opt_postinstall=false
opt_overwrite=false
opt_packages=

for a; do
  case $a in
    --help)
      show_help
      exit
      ;;
    --postinstall)
      opt_postinstall=:
      ;;
    --overwrite)
      opt_overwrite=:
      ;;
    -*)
      echo "error: unknown option $1" >&2
      show_help
      exit 1
      ;;
    *)
      if [ -f "packages/$a" ]; then
        opt_packages="$opt_packages $a"
      else
        echo "error: package $1 not available" >&2
        show_help
        exit 1
      fi
      ;;
  esac
done

if [ -z "$opt_packages" ]; then
  show_help
  exit
fi

for a in $opt_packages; do
  install_package "$a"
done

# vim: ft=sh et ts=8 sts=2 sw=2
