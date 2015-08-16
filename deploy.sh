#! /bin/sh
set -e

backupdir=backup/`date +'%Y%m%d%H%M%S'`

cd `dirname $0`

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
  if [ -e "$HOME/$file" ]; then
    if [ -L "$HOME/$file" ] && [ `readlink "$HOME/$file"` == `pwd`/"$file" ]; then
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
