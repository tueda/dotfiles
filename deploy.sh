#! /bin/sh
set -e
cd `dirname $0`

backupdir=backup/`date +'%Y%m%d%H%M%S'`

if [ -f .gitmodules ]; then
  if type git >/dev/null 2>&1; then
    git submodule update --init
  else
    echo "info: initializing/updating submodules requires git"
  fi
fi

list_dotfiles() {
  for file in .*; do
    case $file in
      .|..|.git|.gitignore|.gitmodules|*.swp)
        continue
    esac
    echo $file
  done
}

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

if $backup; then
  echo "info: backup files are in `pwd`/$backupdir"
fi

# vim: ft=sh et ts=8 sts=2 sw=2
