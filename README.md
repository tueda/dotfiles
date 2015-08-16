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
LOCAL_BUILD_ROOT=/path/to/local/build/directory/for/linuxbrew/etc
prepend_path PATH /additional/path/to/bin
```

```
# Git (>=1.7.10) supports include directive.
[user]
    name = "My Name"
    email = myemail@example.com
```

### SSH URL

```
cd ~/.dotfiles
git remote set-url origin git@github.com:tueda/dotfiles.git
```
