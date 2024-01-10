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

# Check the OS.
osname=`uname -s`
if [ `expr substr "$osname" 1 5` = Linux ]; then
  if uname -v | grep -q 'Microsoft'; then
    osname=linux_on_windows  # WSL1
  elif uname -r | grep -q 'microsoft'; then
    osname=linux_on_windows  # WSL2
  else
    osname=linux
  fi
elif [ `expr substr "$osname" 1 6` = CYGWIN ]; then
  osname=cygwin
elif [ "$osname" = Darwin ]; then
  osname=osx
else
  osname=unknown_os
fi

# Lists dot files.
list_dotfiles() {
  for file in .*; do
    case $file in
      .|..|.git|.gitignore|.gitmodules|*.swp|.nfs*)
        continue
        ;;
      .config)
        (
          cd $file
          for subfile in *; do
            case $subfile in
              .|..|.git|.gitignore|.gitmodules|*.swp|.nfs*)
                continue
                ;;
            esac
            echo $file/$subfile
          done
        )
        continue
        ;;
    esac
    echo $file
  done
}

# Check submodules.
if [ -d .git ] && [ -f .gitmodules ]; then
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
  case "$file" in
    .config/*)
      mkdir -p "$HOME/.config"
      ;;
  esac
  ln -s `pwd`/"$file" "$HOME/$file"
done

# Download utilities.
mkdir -p "$HOME/bin"
(
  cd "$HOME/bin"

  download https://gist.githubusercontent.com/tueda/6718638/raw/path-manip.bash

  download https://gist.githubusercontent.com/tueda/8146d9a44b5b1ec18fee/raw/ndiff
  chmod +x ndiff

  download https://gist.githubusercontent.com/tueda/7777291/raw/tarb
  chmod +x tarb

  download https://gist.githubusercontent.com/tueda/6744aadd5b423c838b44/raw/git-wc
  chmod +x git-wc

  download https://gist.githubusercontent.com/tueda/d411b7ddc4167c5bb209040b637d5e2d/raw/git-graph
  chmod +x git-graph

  download https://gist.githubusercontent.com/tueda/f4b13084345cb6576688066d92198a2c/raw/git-recommit
  chmod +x git-recommit

  download https://raw.githubusercontent.com/tueda/git-onedrive/main/git-onedrive
  chmod +x git-onedrive

  download https://gist.githubusercontent.com/tueda/caeb67bd8d5e3b0697f8fd6e8b8a79ae/raw/disk-blame
  chmod +x disk-blame

  download https://raw.githubusercontent.com/tueda/formset/master/formset.py
  chmod +x formset.py

  download https://gist.githubusercontent.com/tueda/3e1b2bec8545c48737c7/raw/formprof.py
  chmod +x formprof.py

  download https://gist.githubusercontent.com/hSATAC/1095100/raw/256color.pl
  chmod +x 256color.pl

  download https://raw.githubusercontent.com/git/git/3dbfe2b8ae94cbdae5f3d32581aedaa5510fdc87/contrib/diff-highlight/diff-highlight
  chmod +x diff-highlight

  if [ $osname = linux ]; then
    download https://gist.githubusercontent.com/tueda/9529c8d3c06252386c3e9c4ca521f391/raw/open-linux
    chmod +x open-linux
    mv open-linux open
  fi

  if [ $osname = linux_on_windows ]; then
    download https://gist.githubusercontent.com/tueda/eed84b738613761f1146de95ca0817d7/raw/open-wsl
    chmod +x open-wsl
    mv open-wsl open

    download https://gist.githubusercontent.com/tueda/dda525296a4a35f857d698af971cd704/raw/dup-wsl
    chmod +x dup-wsl
    mv dup-wsl dup
  fi

  if [ $osname = cygwin ]; then
    download https://gist.githubusercontent.com/tueda/fc8c3eba9606479308d88b6e38c9aeca/raw/open-cygwin
    chmod +x open-cygwin
    mv open-cygwin open

    download https://gist.githubusercontent.com/tueda/2be1caa5c8051c2d0ab06cec394d5ed1/raw/dup-cygwin
    chmod +x dup-cygwin
    mv dup-cygwin dup
  fi

# download https://gist.githubusercontent.com/tueda/9253579/raw/copyd.sh

# download https://gist.githubusercontent.com/tueda/139acbc4d354633d42c5c2f022d650ae/raw/git-lsearch
# chmod +x git-lsearch

# download http://particle.uni-wuppertal.de/harlander/software/sortref/sortref
# chmod +x sortref
)

echo "info: Succeeded."
if $backup; then
  echo "info: backup files are in `pwd`/$backupdir"
fi

# vim: ft=sh et ts=8 sts=2 sw=2
