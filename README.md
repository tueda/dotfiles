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

**The followings are rather deprecated.**


### Install Linuxbrew

**NOTE**: The following should work even without the above installation.
The script `install.sh` is modulalized and independent of the private settings.

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
brew install gcc --without-glibc  # installing glibc may make a mess
```

Development tools might be also updated:
```
brew install make gdb valgrind
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
# brew install pyenv
. $LOCAL_BUILD_ROOT/bashrc.local # set $PYENV_ROOT and initialize pyenv
brew install --only-dependencies python python3
CPPFLAGS="-I$(brew --prefix)/include" LDFLAGS="-L$(brew --prefix)/lib -Wl,-rpath,$(brew --prefix)/lib" pyenv install 2.7.13
CPPFLAGS="-I$(brew --prefix)/include" LDFLAGS="-L$(brew --prefix)/lib -Wl,-rpath,$(brew --prefix)/lib" pyenv install 3.6.1
pyenv install pypy2-5.7.1
pyenv install pypy3.5-5.8.0

pyenv global 2.7.13 3.6.1 pypy2-5.7.1  pypy3.5-5.8.0

pip install --upgrade pip
pip3 install --upgrade pip

pip install numpy sympy matplotlib ipython
pip3 install numpy sympy matplotlib ipython
pyenv rehash

pip install cython
pip3 install cython

pip install flake8 flake8_docstrings pep8-naming flake8-import-order
pyenv rehash
```
```
# Vim
brew install vim --with-luajit
```
```
# Neovim
brew install neovim/neovim/neovim
pip install neovim
pip3 install neovim
gem install neovim
```
```
# Gnuplot
# brew install fontconfig --without-docs  # If docbook2pdf is not available.
brew install gnuplot --with-cairo --with-pdflib-lite --with-x11
```
```
# FORM
brew install tueda/form/form --HEAD --with-debug --with-mpi  # Put --ignore-dependencies for preinstalled mpi
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
pypy3 -m pip install python-snappy
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
# opam
brew install opam
. $LOCAL_BUILD_ROOT/bashrc.local  # set $OPAMROOT
opam init
eval `opam config env`

opam install cpdf
```
```
# rust
brew install rust --with-racer
. $LOCAL_BUILD_ROOT/bashrc.local  # set $CARGO_HOME
cargo install rustfmt
```
```
# PARI/GP
brew install pari
pip install cypari
pip3 install cypari
# pypy -m pip install pip cypari  # error
# pypy3 -m pip install pip cypari  # error
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

```
# To upgrade a brewed library (e.g., gmp) on which the brewed gcc depends.
# The library is built with the system gcc.
brew unlink gcc
mv $(brew --prefix)/opt/gcc $(brew --prefix)/opt/gcc.bak
brew upgrade gmp
mv $(brew --prefix)/opt/gcc.bak $(brew --prefix)/opt/gcc
brew link gcc
```
```
# To upgrade the brewed ruby with a ruby installed by install.sh.
PATH=$(echo $LOCAL_BUILD_ROOT/ruby-*/bin):$PATH brew upgrade ruby
```
```
# To upgrade the brewed openssl, on which the brewed ruby depends.
brew fetch openssl
brew upgrade openssl
```

### SSH URL

```
cd ~/.dotfiles
git remote set-url origin git@github.com:tueda/dotfiles.git
```
