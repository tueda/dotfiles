set encoding=utf-8
scriptencoding utf-8

augroup vimrc
  autocmd!
augroup END

" Shell "{{{

if &shell =~# 'fish$'
  set shell=sh
endif

" Shell "}}}
" Terminal "{{{

" Modern terminals must be able to print UTF-8 characters!
let g:term_utf8 = 1
if &term == 'dumb' || &term == 'linux'
  let g:term_utf8 = 0
endif

" T_RBG passing though screen/tmux.
if exists('&t_RB')
  if exists('$TMUX')
    " https://github.com/vim/vim/issues/7867#issuecomment-781799099
    let &t_RB = "\ePtmux;\e\e]11;?\007\e\\"
  elseif $TERM =~ "screen"
    let &t_RB = "\eP\e]11;?\x07\e\\"
  endif
endif

" Usually, the color mode and background color are guessed correctly, but when
" it doesn't work, we use $VIM_256COLOR and $VIM_BACKGROUND to adjust them.

if exists('$VIM_256COLOR')
  set t_Co=256
endif

if exists('$VIM_BACKGROUND')
  let &background = $VIM_BACKGROUND
endif

" GNU screen.
if &term =~ 'screen'
  set ttymouse=xterm2
  set t_ts=]2;       " set window title start (to status line)
  set t_fs=          " set window title end (from status line)

  " Fix keycods.
  map OH <Home>
  map OF <End>
  map! OH <Home>
  map! OF <End>

  map [1~ <Home>
  map [4~ <End>
  imap [1~ <Home>
  imap [4~ <End>
endif

"}}}
" General behaviour "{{{

set   backspace=indent,eol,start
set   fileformats=unix,dos,mac
set   hidden
set   mouse=a
set   showcmd
set   showmatch
set   visualbell t_vb=  " no beep or flash
set   whichwrap=b,s,<,>,[,]

set   wildmenu
set   wildmode=full
set   wildignore+=*.o,*.exe
set   wildignore+=*.pyc,*.pyo,*/__pycache__/*
set   wildignore+=CMakeCache.txt,*/CMakefiles/*,CTestTestfile.cmake,cmake_install.cmake
set   wildignore+=gradlew,gradlew.bat
set   wildignore+=*.aux,*.ax1,*.ax2,*.bbl,*.blg,*.fls,*.spl,*.toc
set   wildignore+=*.nav,*.spl,*.snm,*.vrb
set   wildignore+=*.dvi,*.pdf

" Automatically reload files.
" https://stackoverflow.com/a/50476532/9105334
" https://stackoverflow.com/a/48296697/9105334
set   autoread

function! Checktime() abort
  let l:winview = winsaveview()
  checktime
  call winrestview(l:winview)
endfunction

augroup vimrc
  autocmd CursorHold,FocusGained,BufEnter * call Checktime() | call feedkeys('lh')
augroup END

" Prevent a delay when pressing ESC.
if !has('gui_running')
  set notimeout
  set ttimeout
  set timeoutlen=10
  augroup vimrc
    autocmd InsertEnter * set timeout
    autocmd InsertLeave * set notimeout
  augroup END
endif

" Close Quickfix window when no other windows.
" http://hail2u.net/blog/software/vim-auto-close-quickfix-window.html
autocmd vimrc WinEnter * if (winnr('$') == 1) && (getbufvar(winbufnr(0), '&buftype')) == 'quickfix' | quit | endif

" Automatically change the current directory
"autocmd BufEnter * silent! lcd %:p:h

"}}}
" View "{{{

set nocursorline
set   number
set   ruler
set   title
set nowrap

if g:term_utf8
  set list
  execute "set listchars=tab:› ,eol:⇂,extends:»,precedes:«"
else
  set nolist
endif

if exists('&ambiwidth')
  set ambiwidth=double
endif

if exists('+colorcolumn')
  set colorcolumn=81
endif

if exists('&breakindent')
  set breakindent
endif

"}}}
" Searching "{{{

set   hlsearch
set   incsearch
set   ignorecase
set   smartcase
set nowrapscan

" Hide search highlights when ESC pressed twice.
nmap <silent> <Esc><Esc> :nohlsearch<CR><Esc>

"}}}
" Indent "{{{

set   autoindent
set nocindent
set   smartindent
set nosmarttab

" TabIndent <tabwidth>
" SpaceIndent <tabwidth>
command! -nargs=1 TabIndent setlocal noexpandtab shiftwidth=<args> softtabstop=0 tabstop=<args>
command! -nargs=1 SpaceIndent setlocal expandtab shiftwidth=<args> softtabstop=<args> tabstop=8

" Default indent (SpaceIndent 2)
set expandtab shiftwidth=2 softtabstop=2 tabstop=8

"}}}
" Spell checking "{{{

set   spell

" Disable the spell checker for Japanese.
if v:version > 704 || (v:version == 704 && has('patch89'))
  set spelllang+=cjk
endif

" Disable the spell checker for Japanese.
function! DisableSpellCheckCJK()
  if v:version > 704 || (v:version == 704 && has('patch89'))
    setlocal spelllang+=cjk
  endif
endfunction

" Slow, but accurate.
function! SpellPrecisely()
  syntax sync fromstart
endfunction

" Sort *.add files.
function! SpellFileSort()
  for f in glob('~/.vim/spell/*.add', 1, 1)
    if filereadable(f)
      execute '!sort -u -o ' . fnameescape(f) . ' ' . fnameescape(f)
    endif
  endfor
endfunction

" Rebuild *.add.spl files.
function! SpellFileRebuild()
  for f in glob('~/.vim/spell/*.add', 1, 1)
    if filereadable(f) && (!filereadable(f . '.spl') || getftime(f) > getftime(f . '.spl'))
      execute 'mkspell! ' . fnameescape(f)
    endif
  endfor
endfunction

command! SpellCheck call SpellPrecisely()

command! SpellCheckGB setlocal spell spelllang=en_gb
      \ | call DisableSpellCheckCJK()
      \ | call SpellPrecisely()

command! SpellCheckUS setlocal spell spelllang=en_us
      \ | call DisableSpellCheckCJK()
      \ | call SpellPrecisely()

"}}}
" Key mappings "{{{

" C-A -> Start of line, C-E -> End of line
map <C-a> <Home>
map <C-e> <End>
map! <C-a> <Home>
map! <C-e> <End>

" C-S: Save the file.
nmap <c-s> :update<CR>
imap <c-s> <Esc>:update<CR>a

"}}}
" File type detection "{{{

augroup vimrc
  autocmd BufNewFile,BufRead *.m setlocal filetype=mma
  autocmd BufNewFile,BufRead * call DetectFileType()
augroup end

function! DetectFileType()
  let l = getline(1)
  " Shebang
  if l =~ '^#!'
    if l =~ '\<sh\>'
      for i in range(2, 10)
        let l = getline(i)
        if l =~ 'exec \+perl'
          setlocal filetype=perl
          return
        endif
        if l =~ 'exec \+python'
          setlocal filetype=python
          return
        endif
        if l =~ 'exec \+ruby'
          setlocal filetype=ruby
          return
        endif
      endfor
      setlocal filetype=sh
      return
    endif
    if l =~ '\<bash\>'
      setlocal filetype=sh
      return
    endif
    if l =~ '\<perl\>'
      setlocal filetype=perl
      return
    endif
    if l =~ '\<python\>'
      setlocal filetype=python
      return
    endif
    if l =~ '\<ruby\>'
      setlocal filetype=ruby
      return
    endif
  endif
  " Emacs file mode
  if l =~ '-\*-.*-\*-'
    if l =~ '-\*-.*\<c\>.*-\*-'
      set filetype=c
      return
    endif
    if l =~ '-\*-.*\<fortran\>.*-\*-'
      set filetype=fortran
      return
    endif
    if l =~ '-\*-.*\<form\>.*-\*-'
      set filetype=form
      return
    endif
    if l =~ '-\*-.*\<reduce\>.*-\*-'
      set filetype=reduce
      return
    endif
  endif
endfunction

"}}}
" File type specific settings "{{{

augroup vimrc
  autocmd FileType automake execute 'TabIndent 4'
  autocmd FileType fortran setlocal colorcolumn=73
  autocmd FileType gitcommit setlocal colorcolumn=73
  autocmd FileType java setlocal colorcolumn=101
  autocmd FileType make execute 'TabIndent 4'
  autocmd FileType python execute 'SpaceIndent 4' | setlocal colorcolumn=80 | setlocal foldcolumn=4
  autocmd FileType qf setlocal colorcolumn=0
  autocmd FileType rust setlocal colorcolumn=101
  autocmd FileType tex setlocal colorcolumn=81 | setlocal foldcolumn=4
  autocmd FileType unite highlight link ExtraWhitespace Normal

  autocmd BufNewFile,BufRead *.tex setlocal filetype=tex
  autocmd BufNewFile,BufRead *.dtx setlocal colorcolumn=73
  autocmd BufNewFile,BufRead *.ins setlocal colorcolumn=73

" FORM sources
  autocmd BufNewFile,BufRead */form*/sources/*.c  call FORMCSource()
  autocmd BufNewFile,BufRead */form*/sources/*.cc call FORMCSource()
  autocmd BufNewFile,BufRead */form*/sources/*.h  call FORMCSource()
  autocmd BufNewFile,BufRead */form*/configure.ac execute 'TabIndent 4'
augroup end

function! FORMCSource()
  execute 'TabIndent 4'
  setlocal foldmethod=marker foldmarker=#[,#] foldcolumn=4
endfunction

"}}}
" Some commands "{{{

command! RemoveCarriageReturn %s///g
command! RemoveTrailingWhitespace %s/[ 	]\+$//g

command! Dark    set background=dark
command! Light   set background=light
command! NoList  set nolist

command! C       setlocal filetype=c
command! CC      setlocal filetype=cpp
command! F       setlocal filetype=fortran
command! F77     let b:fortran_fixed_source=1 | setlocal filetype=fortran | setlocal colorcolumn=73
command! F90     let b:fortran_fixed_source=0 | setlocal filetype=fortran | setlocal colorcolumn=133
command! Fortran setlocal filetype=fortran
command! FORM    setlocal filetype=form
command! MMA     setlocal filetype=mma
command! REDUCE  setlocal filetype=reduce
command! TeX     setlocal filetype=tex

command! ReopenAsEUCJP e ++enc=euc-jp
command! ReopenAsSJIS e ++enc=sjis
command! ReopenAsUTF8 e ++enc=utf-8

" Use FORM foldings.
function! FORMFold()
  if &foldmethod == "manual"
    setlocal foldmethod=marker foldmarker=#[,#] foldcolumn=4
  elseif &foldmethod == "marker"
    setlocal foldmethod=manual foldmarker={{{,}}} foldcolumn=0
  else
    if &foldcolumn == 0
      setlocal foldcolumn=4
    elseif &foldcolumn == 4
      setlocal foldcolumn=0
    endif
  endif
endfunction

command! Z call FORMFold()

" Add the mode line to the file.
function! s:AppendModeLine()
  if &expandtab == 0
    let l:et = "noet"
  else
    let l:et = "et"
  endif
  let l:modeline = printf("ft=%s %s ts=%d sts=%d sw=%d",
                        \ &filetype, l:et, &tabstop, &softtabstop, &shiftwidth)
  if &filetype == "cpp"
    let l:modeline = printf("// vim: %s", l:modeline)
  elseif &filetype == "form"
    let l:modeline = printf("* vim: %s", l:modeline)
  elseif &filetype == "tex"
    let l:modeline = printf("%% vim: %s", l:modeline)
  elseif &filetype == "sh" || &filetype == "perl" || &filetype == "python" || &filetype == "ruby"
    let l:modeline = printf("# vim: %s", l:modeline)
  elseif &filetype == "vim"
    let l:modeline = printf("\" vim: %s", l:modeline)
  elseif &filetype == "mma"  " strange &commentstring @ v7.3.62
    let l:modeline = printf("(* vim: set %s: *)", l:modeline)
  else
    let l:modeline = printf(" vim: set %s: ", l:modeline)
    let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
  endif
  call append(line("$"), l:modeline)
endfunction

command! AppendModeLine call s:AppendModeLine()

" CD = Change to the directory of the current file
command! CD cd %:p:h

"}}}
" Plugins "{{{

if v:version >= 800
  let s:dein_dir = expand('~/.cache/dein')
  let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

  " Clone dein.vim if not found.
  if &runtimepath !~# '/dein.vim'
    if !isdirectory(s:dein_repo_dir)
      execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
    endif
    execute 'set runtimepath+=' . fnamemodify(s:dein_repo_dir, ':p')
  endif

  if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)

    let s:rc_dir    = expand('~/.vim')
    let s:toml      = s:rc_dir . '/dein.toml'
    let s:lazy_toml = s:rc_dir . '/dein_lazy.toml'

    call dein#load_toml(s:toml,      {'lazy': 0})
    call dein#load_toml(s:lazy_toml, {'lazy': 1})

    " For developing plugins.
    " call dein#local(s:rc_dir . '/bundle')

    call dein#end()
    call dein#save_state()
  endif

  if has('vim_starting') && dein#check_install()
    call dein#install()
  endif
endif

"}}}

filetype plugin indent on
syntax on

set secure

" vim: ft=vim et ts=8 sts=2 sw=2 fdm=marker fmr={{{,}}} fdc=4
