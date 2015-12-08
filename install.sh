#! /bin/sh
set -e
cd `dirname $0`

# Currently the user has to explicitly specify
#   MAKEFLAGS=-j4 ./install.sh <package>
# for parallel make.
#
#JOBS=0
#if [ -e /proc/cpuinfo ]; then
#  JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
#  MAKEFLAGS="-j$JOBS $MAKEFLAGS"
#fi

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

# Wraps "wget $1"
download() {
  if type curl >/dev/null 2>&1; then
    curl -O -L "$1"
  elif type wget >/dev/null 2>&1; then
    wget "$1"
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

# Adds the given path in .bashrc.local.
prepend_path() {
  bashrc_local=
  if [ -n "$LOCAL_BUILD_ROOT" ]; then
    bashrc_local="$LOCAL_BUILD_ROOT/bashrc.local"
  else
    bashrc_local="$HOME/.bashrc.local"
  fi
  if grep -q -F "$2" $bashrc_local 2>/dev/null; then :; else
    echo "prepend_path $1 \"$2\"" >>"$bashrc_local"
  fi
}

show_help() {
  cat << 'END'
Usage: install.sh <package>

Available packages:
END
ls packages
}

install_package() {
# XXX: No lock mechanism.
  pkgname=$1
  pkgver=
  prefix=
  . "packages/$1"
  if [ -z "$prefix" ]; then
    if [ -n "$LOCAL_BUILD_ROOT" ]; then
      prefix="$LOCAL_BUILD_ROOT/$pkgname"
    else
      prefix="$HOME/opt/$pkgname"
    fi
    if [ -n "$pkgver" ]; then
      prefix="$prefix-$pkgver"
    fi
  fi
  if [ -e "$prefix" ]; then
    echo "error: $prefix already exists" >&2
    exit 1
  fi
  cat << END
This script will install $1 to
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
  if (cd "$tmpdir" && do_install); then
    echo "Succeeded to install $1."
    echo "You may need to reload PATH"
    echo "  reload_path"
  else
    echo "error: failed to install $1." >&2
    return 1
  fi
}

if [ $# -eq 0 ]; then
  show_help
fi

for a; do
  case $a in
    --help)
      show_help
      exit
      ;;
    *)
      if [ -f "packages/$a" ]; then
        install_package "$a"
      else
        echo "error: package $1 not available" >&2
        show_help
        exit 1
      fi
      ;;
  esac
done

## Gives the default installation directory.
#opt_dir() {
#  if [ -n "$LOCAL_BUILD_ROOT" ]; then
#    echo "$LOCAL_BUILD_ROOT"
#  else
#    echo "$HOME/opt"
#  fi
#}

#tempdir=`mktemp_d "${TMPDOR:-/tmp}/tmp"`
#echo $tempdir
