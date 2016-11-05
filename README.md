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
. $LOCAL_BUILD_ROOT/bashrc.local  # add ruby to PATH
```
Some features of Ruby may be missing (e.g., readline) and you may need to
reinstall it via Linuxbrew later.

Install Linuxbrew:
```
~/.dotfiles/install.sh linuxbrew
. $LOCAL_BUILD_ROOT/bashrc.local  # add brew to PATH
```

Install the latest GCC:
```
# brew install binutils  # if any problem for new CPU instructions
brew install gcc --without-glibc  # installing glibc always makes a mess
```

Debugging tools might be also updated:
```
brew install gdb valgrind
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
brew install pyenv --HEAD
# brew install pyenv
. $LOCAL_BUILD_ROOT/bashrc.local # set $PYENV_ROOT and initialize pyenv
brew install berkeley-db4 bzip2 gdbm openssl readline sqlite
CPPFLAGS="-I$(brew --prefix)/include" LDFLAGS="-L$(brew --prefix)/lib -Wl,-rpath,$(brew --prefix)/lib" pyenv install 2.7.12
CPPFLAGS="-I$(brew --prefix)/include" LDFLAGS="-L$(brew --prefix)/lib -Wl,-rpath,$(brew --prefix)/lib" pyenv install 3.5.2
pyenv install pypy-5.4.1
pyenv install pypy3.3-5.5-alpha

pyenv global 2.7.12 3.5.2 pypy-5.4.1 pypy3.3-5.5-alpha

pip install --upgrade pip
pip3 install --upgrade pip
pypy -m pip install --upgrade pip
pypy3 -m pip install --upgrade pip

pip install numpy
pip3 install numpy
pypy -m pip install numpy
pypy3 -m pip install numpy
# pypy -m pip install git+https://bitbucket.org/pypy/numpy.git  # alternatively

pip install sympy
pip3 install sympy
pypy -m pip install sympy
pypy3 -m pip install sympy

pip install matplotlib
pip3 install matplotlib
pypy -m pip install matplotlib
# pypy3 -m pip install matplotlib  # error

pip install cython
pip3 install cython
pypy -m pip install cython
pypy3 -m pip install cython

pip install ipython
pip3 install ipython
pyenv rehash

pip install flake8 flake8_docstrings pep8-naming flake8-import-order
```
```
# Vim
brew install lua luajit vim --ignore-dependencies  # Use the installed Python
# brew install lua luajit vim --without-perl --ignore-dependencies  # Use the installed Python
```
```
# Gnuplot
brew install gnuplot --with-cairo --with-pdflib-lite --with-x11
```
```
# FORM
brew install tueda/loops/form --HEAD --with-debug --with-mpi  # Put --ignore-dependencies for preinstalled mpi
pip install python-form
pip3 install python-form
pypy -m pip install python-form
pypy3 -m pip install python-form
```
```
# igraph
brew install homebrew/science/openblas  # OS X has own blas but Linux not
# brew install libxml2  # if missing
brew install homebrew/science/igraph
pip install python-igraph
pip3 install python-igraph
pypy -m pip install python-igraph
pypy3 -m pip install python-igraph
```
```
# GiNaC
brew install ginac
```
```
# Snappy
brew install snappy
pip install python-snappy
pip3 install python-snappy
pypy -m pip install python-snappy
# pypy3 -m pip install python-snappy  # error
```
```
# PPL
brew install ppl
pip install pplpy
# pip3 install pplpy  # error
# pypy -m pip install pplpy  # error
# pypy3 -m pip install pplpy  # error
```
```
# Misc.
brew install bash-completion
brew install colordiff
brew install htop
```

### Caveats

After installing `gcc` in the above procedure, upgrading one of the libraries
which `gcc` depends on, for example `gmp`, requires to make Linuxbrew believe
that the brewed-`gcc` is not installed: upgrading `gmp` first removes the
brewed-`gmp`, so that the brwed-`gcc` does not work. Unlinking `brew unlink gcc`
is not enough because Linuxbrew checks executables in
`${HOMEBREW_PREFIX}/opt/gcc/bin`. So this directory has to be temporarily
renamed, or some code in `developement_tools.rb` has to be modified.

`fontconfig` may need to be configured with `--disable-docs`. See
https://github.com/Linuxbrew/legacy-linuxbrew/issues/824.

### SSH URL

```
cd ~/.dotfiles
git remote set-url origin git@github.com:tueda/dotfiles.git
```
