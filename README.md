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

Make sure `LOCAL_BUILD_ROOT` is set if you don't want to install software
in your home directory. Disk usage may become huge.
```
export LOCAL_BUILD_ROOT=/path/to/local/build
```

The `bashrc.local` file, to be generated in `$LOCAL_BUILD_ROOT`, must be called
in your `.bashrc`:
```
[ -f $LOCAL_BUILD_ROOT/bashrc.local ] && . $LOCAL_BUILD_ROOT/bashrc.local
```

If Ruby (>=1.8.6) is not installed:
```
~/.dotfiles/install.sh openssl
~/.dotfiles/install.sh ruby
. $LOCAL_BUILD_ROOT/bashrc.local
```
Some features of Ruby may be missing (e.g., readline) and you may need to
reinstall it via Linuxbrew later.

Install Linuxbrew:
```
~/.dotfiles/install.sh linuxbrew
. $LOCAL_BUILD_ROOT/bashrc.local
```

Install the latest GCC:
```
wget https://gmplib.org/download/gmp/gmp-6.1.0.tar.xz -O $HOMEBREW_CACHE/gmp-6.1.0.tar.xz  # avoid "curl: (35) SSL connect error"
brew install gcc --without-glibc
```

Reinstall Ruby via Linuxbrew:
```
brew install ruby
```

Install the latest Git:
```
brew install git --without-tcl-tk  # if no Xlib
# brew install git --with-tcl-tk   # gitk
```

Install other software packages via Linuxbrew:
```
# Python via pyenv
brew install pyenv
# set $PYENV_ROOT
brew install bzip2 sqlite gdbm
CPPFLAGS="-I$(brew --prefix)/include" LDFLAGS="-L$(brew --prefix)/lib -Wl,-rpath,$(brew --prefix)/lib" pyenv install 2.7.11
CPPFLAGS="-I$(brew --prefix)/include" LDFLAGS="-L$(brew --prefix)/lib -Wl,-rpath,$(brew --prefix)/lib" pyenv install 3.5.1
pyenv install pypy-5.0.1
pyenv install pypy3-2.4.0
pyenv global 2.7.11 3.5.1 pypy-5.0.1 pypy3-2.4.0

pip install --upgrade pip
pip3 install --upgrade pip
pypy -m pip install --upgrade pip
pypy3 -m pip install --upgrade pip

pip install numpy
pip3 install numpy
pypy -m pip install git+https://bitbucket.org/pypy/numpy.git

pip install ipython
pip3 install ipython
pyenv rehash

pip install flake8 flake8-pep257 pep8-naming flake8-import-order
```
```
# Vim
brew install lua luajit vim --without-perl --ignore-dependencies  # Use the installed Python
```
```
# Gnuplot
brew install gnuplot --with-pdflib-lite --with-x11
```
```
# FORM
brew install tueda/loops/form --HEAD --with-debug --with-mpi  # Put --ignore-dependencies for preinstalled mpi
```
```
# Misc.
brew install bash-completion
brew install colordiff
```

### SSH URL

```
cd ~/.dotfiles
git remote set-url origin git@github.com:tueda/dotfiles.git
```
