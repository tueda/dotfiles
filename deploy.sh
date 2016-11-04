#! /bin/sh
set -e
cd `dirname $0`

backupdir=backup/`date +'%Y%m%d%H%M%S'`

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

# Wraps "wget $1"
download() {
  echo "downloading `basename "$1"...`"
  if type curl >/dev/null 2>&1; then
    curl -O -L "$1"
  elif type wget >/dev/null 2>&1; then
    wget -O `basename "$1"` "$1"
  else
    echo "error: curl or wget required" >&2
    return 1
  fi
}

# Lists dot files.
list_dotfiles() {
  for file in .*; do
    case $file in
      .|..|.git|.gitignore|.gitmodules|*.swp)
        continue
    esac
    echo $file
  done
}

# Check submodules.
if [ -f .gitmodules ]; then
  if type git >/dev/null 2>&1; then
    git submodule update --init
  else
    echo "info: initializing/updating submodules requires git"
  fi
fi

# Confirmation.
cat << END
This script will (over)write dot files:
`list_dotfiles`
bin/
END
echo_n 'Okay? (y/n) : '
read answer
if [ "x$answer" != "xy" ] && [ "x$answer" != "xY" ]; then
  echo 'Exit. No writing.'
  exit
fi

# Copy dot files.
backup=false
for file in `list_dotfiles`; do
  if [ -e "$HOME/$file" ] || [ -h "$HOME/$file" ]; then
#   readlink is not in POSIX, but expected to work both on Linux and OS X.
    if [ -h "$HOME/$file" ] && [ `readlink "$HOME/$file"` = `pwd`/"$file" ]; then
      echo "skip: $file exists"
      continue
    fi
    mkdir -p "$backupdir"
    echo "info: backup $file"
    mv "$HOME/$file" "$backupdir"
    backup=:
  fi
  echo "info: link $file"
  ln -s `pwd`/"$file" "$HOME/$file"
done

# Download utilities.
mkdir -p "$HOME/bin"
(
  cd "$HOME/bin"

  download https://gist.githubusercontent.com/tueda/8146d9a44b5b1ec18fee/raw/ndiff
  chmod +x ndiff

  download https://gist.githubusercontent.com/tueda/7777291/raw/tarb
  chmod +x tarb

  download https://gist.githubusercontent.com/tueda/6744aadd5b423c838b44/raw/git-wc
  chmod +x git-wc

  download https://gist.githubusercontent.com/tueda/139acbc4d354633d42c5c2f022d650ae/raw/git-lsearch
  chmod +x git-lsearch

  download https://gist.githubusercontent.com/tueda/f44b42a12ac16c1966e9743e344615a1/raw/formset.py
  chmod +x formset.py

  download https://gist.githubusercontent.com/tueda/3e1b2bec8545c48737c7/raw/formprof.py
  chmod +x formprof.py

  download https://gist.githubusercontent.com/hSATAC/1095100/raw/256color.pl
  chmod +x 256color.pl

  download https://raw.githubusercontent.com/git/git/master/contrib/diff-highlight/diff-highlight
  chmod +x diff-highlight

# download https://gist.githubusercontent.com/tueda/6718638/raw/path-manip.bash

# download https://gist.githubusercontent.com/tueda/9253579/raw/copyd.sh

# download http://particle.uni-wuppertal.de/harlander/software/sortref/sortref
# chmod +x sortref
)

echo "info: Succeeded."
if $backup; then
  echo "info: backup files are in `pwd`/$backupdir"
fi

# vim: ft=sh et ts=8 sts=2 sw=2
