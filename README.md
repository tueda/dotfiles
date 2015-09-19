# dotfiles

## Installation

### via curl

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/tueda/dotfiles/go/install)"
```

### via wget

```
sh -c "$(wget https://raw.githubusercontent.com/tueda/dotfiles/go/install -O -)"
```

### via git

```
git clone https://github.com/tueda/dotfiles.git ~/.dotfiles && ~/.dotfiles/deploy.sh
```

### Local settings

Optionally make/edit `.bashrc.local` and `.gitconfig.local`:

```
export LOCAL_BUILD_ROOT=/path/to/local/build/directory/for/linuxbrew/etc
prepend_path PATH /additional/path/to/bin
```

```
# Git (>=1.7.10) supports include directive.
[user]
    name = "My Name"
    email = myemail@example.com
```

### Install Linuxbrew

Make sure `LOCAL_BUILD_ROOT` is set as in the previous step if you don't want to
install software in your home directory.

If Ruby (>=1.8.6) is not installed:
```
~/.dotfiles/install.sh ruby
reload_path
```
Some features may be missing (e.g., openssl) and you may still need to reinstall
Ruby via Linuxbrew.

Install Linuxbrew:
```
~/.dotfiles/install.sh linuxbrew
reload_path
```

### SSH URL

```
cd ~/.dotfiles
git remote set-url origin git@github.com:tueda/dotfiles.git
```
