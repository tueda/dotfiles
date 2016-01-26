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

Install other software packages via Linuxbrew:
```
# You may want to install Ruby within Homebrew.
brew install ruby

# Latest git
brew install curl git
# brew install git --without-tcl-tk  # if no Xlib

# Python via pyenv
brew install pyenv
reload_path  # set $PYENV_ROOT
brew install bzip2 sqlite gdbm
CPPFLAGS="-I$(brew --prefix)/include" \
  LDFLAGS="-L$(brew --prefix)/lib -Wl,-rpath,$(brew --prefix)/lib" \
  pyenv install 2.7.11
CPPFLAGS="-I$(brew --prefix)/include" \
  LDFLAGS="-L$(brew --prefix)/lib -Wl,-rpath,$(brew --prefix)/lib" \
  pyenv install 3.5.1
pyenv install -v pypy3-2.4.0
pyenv install -v pypy-4.0.1
pyenv global 2.7.11 3.5.1 pypy-4.0.1 pypy3-2.4.0

pip install --upgrade pip
pip3 install --upgrade pip
pypy -m pip install --upgrade pip
pypy3 -m pip install --upgrade pip

pip install numpy
pip3 install numpy
pypy -m pip install git+https://bitbucket.org/pypy/numpy.git@pypy-4.0.1

pip install flake8 flake8-pep257 pep8-naming flake8-import-order

# IPython
pip install ipython
pip3 install ipython
pyenv rehash

# Latest Vim
brew install lua luajit vim --ignore-dependencies  # Use the installed Python

# Latest gnuplot
brew edit fontconfig  # Add "--disable-docs"
brew install gnuplot --with-pdflib-lite --with-x11

# FORM
brew tap tueda/loops
brew install form --HEAD --with-debug --with-mpi  # Put --ignore-dependencies for preinstalled mpi

# Misc.
brew install bash-completion
brew install colordiff
```

### SSH URL

```
cd ~/.dotfiles
git remote set-url origin git@github.com:tueda/dotfiles.git
```
