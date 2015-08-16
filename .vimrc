set encoding=utf-8
scriptencoding utf-8

let s:bundle = 0
let s:bundle_root = expand('~/.vim/bundle')
let s:neobundle_root = s:bundle_root . '/neobundle.vim'

if has('vim_starting')
  execute "set runtimepath+=" . s:neobundle_root
endif

if !isdirectory(s:neobundle_root) || v:version < 702
  filetype plugin indent on
else
  let s:bundle = 1
  call neobundle#begin(s:bundle_root)

  NeoBundleFetch 'Shougo/neobundle.vim'

  NeoBundle 'Shougo/vimproc.vim', {
        \ 'build' : {
        \     'windows' : 'tools\\update-dll-mingw',
        \     'cygwin' : 'make -f make_cygwin.mak',
        \     'mac' : 'make -f make_mac.mak',
        \     'unix' : 'make -f make_unix.mak',
        \    },
        \ }

  NeoBundle 'Shougo/neomru.vim'
  NeoBundle 'YankRing.vim'
" NeoBundle 'LeafCage/yankround.vim'
  NeoBundle 'itchyny/lightline.vim'
  NeoBundle 'jonathanfilip/vim-lucius'
  NeoBundle 'tyru/caw.vim.git'
  NeoBundle 'tueda/form.vim'

  function! s:meet_neocomplete_requirements()
    return has('lua') && (v:version > 703 || (v:version == 703 && has('patch885')))
  endfunction

  if s:meet_neocomplete_requirements()
    NeoBundleLazy  'Shougo/neocomplete.vim', {"autoload":{"insert":1}}
    NeoBundleFetch 'Shougo/neocomplcache.vim'
  else
    NeoBundleFetch 'Shougo/neocomplete.vim'
    NeoBundleLazy  'Shougo/neocomplcache.vim', {"autoload":{"insert":1}}
  endif

  function! s:meet_unite_requirements()
    return v:version >= 703
  endfunction

  if s:meet_unite_requirements()
    NeoBundle 'Shougo/unite.vim'
    NeoBundle 'Shougo/unite-outline'
  else
    NeoBundleFetch 'Shougo/unite.vim'
    NeoBundleFetch 'Shougo/unite-outline'
  endif

  call neobundle#end()
  filetype plugin indent on
  NeoBundleCheck
endif

function! s:is_sourced(bundle_name)
  return s:bundle && neobundle#is_sourced(a:bundle_name)
endfunction

"-------------------------------------------------------------------------------
" unite
"-------------------------------------------------------------------------------

if s:is_sourced("unite.vim")
  nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
  nnoremap <silent> ,uf :<C-u>Unite file<CR>
  if s:is_sourced("neomru.vim")
    nnoremap <silent> ,um :<C-u>Unite file_mru<CR>
  endif
  if s:is_sourced("unite-outline")
    nnoremap <silent> ,uo :<C-u>Unite outline<CR>
  endif
  if s:is_sourced("yankround.vim")
    nnoremap <silent> ,uy :<C-u>Unite yankround<CR>
  endif
endif

"-------------------------------------------------------------------------------
" lightline
"-------------------------------------------------------------------------------

if s:is_sourced("lightline.vim")
  set   laststatus=2
  set noshowmode

  let g:lightline = {
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ], [ 'filename' ], [ 'bufhist' ] ],
        \ },
        \ 'component_function': {
        \   'readonly': 'MyReadonly',
        \   'modified': 'MyModified',
        \   'filename': 'MyFilename',
        \   'bufhist' : 'Mline_bufhist',
        \ },
        \ }

  if $VIM_POWERLINE != "" && &encoding == 'utf-8'
    let s:SYM_RO = '⭤'
    let g:lightline.separator = {
          \   'left'  : '⮀',
          \   'right' : '⮂' ,
          \ }
    let g:lightline.subseparator = {
          \   'left'  : '⮁',
          \   'right' : '⮃',
          \ }
  else
    let s:SYM_RO = 'x'
    let g:lightline.separator = {
          \   'left'  : '',
          \   'right' : '' ,
          \ }
    let g:lightline.subseparator = {
          \   'left'  : '|',
          \   'right' : '|',
          \ }
  endif

  if &encoding == 'utf-8'
    let s:SYM_ELLIPSIS = '…'
  else
    let s:SYM_ELLIPSIS = '..'
  endif

  function! MyModified()
    if &filetype == 'help'
      return ''
    elseif &modified
      return '+'
    elseif &modifiable
      return ''
    else
      return '-'
    endif
  endfunction

  function! MyReadonly()
    if &filetype == 'help'
      return ''
    elseif &readonly
      return s:SYM_RO
    else
      return ''
    endif
  endfunction

  function! MyFilename()
    return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
         \ printf('[%d]:%s', bufnr('%'),
              \ ('' != expand('%:t') ? expand('%:t') : '[No Name]')) .
         \ ('' != MyModified() ? ' ' . MyModified() : '')
  endfunction

  let g:mline_bufhist_queue = []
  let g:mline_bufhist_limit = 20
  let g:mline_bufhist_width = 15
  let g:mline_bufhist_exclution_pat = '^$\|.jax$\|vimfiler:\|\[unite\]\|tagbar'

  let g:mline_bufhist_enable = 1
  command! Btoggle :let g:mline_bufhist_enable = g:mline_bufhist_enable ? 0 : 1
        \ | :redrawstatus!

  function! Mline_bufhist()
    if &filetype =~? 'unite\|vimfiler\|tagbar' || !&modifiable ||
            \ len(g:mline_bufhist_queue) == 0 || g:mline_bufhist_enable == 0
      return ''
    endif

    let max_len = winwidth(0) - 80 + g:mline_bufhist_width -
          \ strlen(s:SYM_ELLIPSIS)

    let current_buf_nr = bufnr('%')
    let buf_names_str = ''
    let last = g:mline_bufhist_queue[-1]

    for file in g:mline_bufhist_queue
      let f = fnamemodify(file, ':t')
      let n = bufnr(f)

      if n != current_buf_nr
        let str = buf_names_str .
                \ printf('[%d]:%s', n, f) . (file == last ? '' : ' | ')
        let len = strlen(str)
        if len > max_len
          if buf_names_str != ''
            let buf_names_str .= s:SYM_ELLIPSIS
          endif
          break
        endif
        let buf_names_str = str
      endif
    endfor

    return buf_names_str
  endfunction

  function! s:update_recent_buflist(file)
    if a:file =~? g:mline_bufhist_exclution_pat
      " exclusion from queue
      return
    endif

    if len(g:mline_bufhist_queue) == 0
      " init
      for i in range(min( [ bufnr('$'), g:mline_bufhist_limit + 1 ] ))
        let t = bufname(i)
        if bufexists(i) && t !~? g:mline_bufhist_exclution_pat
          call add(g:mline_bufhist_queue, fnamemodify(t, ':p'))
        endif
      endfor
    endif

    " update exist buffer
    let idx = index(g:mline_bufhist_queue, a:file)
    if 0 <= idx
      call remove(g:mline_bufhist_queue, idx)
    endif

    call insert(g:mline_bufhist_queue, a:file)

    if g:mline_bufhist_limit + 1 < len(g:mline_bufhist_queue)
      call remove(g:mline_bufhist_queue, -1)
    endif
  endfunction

  augroup mygroup
    autocmd!
    autocmd TabEnter,BufWinEnter * call s:update_recent_buflist(expand('<amatch>'))
  augroup END
endif

"-------------------------------------------------------------------------------
" YankRing
"-------------------------------------------------------------------------------

if s:is_sourced("YankRing.vim")
  let g:yankring_history_file = ".yankring_history"
endif

"-------------------------------------------------------------------------------
" yankround
"-------------------------------------------------------------------------------

if s:is_sourced("yankround.vim")
  nmap p <Plug>(yankround-p)
  xmap p <Plug>(yankround-p)
  nmap P <Plug>(yankround-P)
  nmap gp <Plug>(yankround-gp)
  xmap gp <Plug>(yankround-gp)
  nmap gP <Plug>(yankround-gP)
  nmap <C-p> <Plug>(yankround-prev)
  nmap <C-n> <Plug>(yankround-next)
endif

"-------------------------------------------------------------------------------
" neocomplete/neocomplcache
"-------------------------------------------------------------------------------

if s:bundle
  if s:meet_neocomplete_requirements()
    let s:neocomplete_hooks = neobundle#get_hooks("neocomplete.vim")
    function! s:neocomplete_hooks.on_source(bundle)
      let g:neocomplete#enable_at_startup = 1
      let g:neocomplete#enable_smart_case = 1
      " <TAB>: completion.
      inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
      " For cursor moving in insert mode
      let g:neocomplete#enable_insert_char_pre = 1
    endfunction
  else
    let s:neocomplcache_hooks = neobundle#get_hooks("neocomplcache.vim")
    function! s:neocomplcache_hooks.on_source(bundle)
      let g:neocomplcache_enable_at_startup = 1
      let g:neocomplcache_enable_smart_case = 1
      " <TAB>: completion.
      inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
      " For cursor moving in insert mode
      inoremap <expr><Left>  neocomplcache#close_popup() . "\<Left>"
      inoremap <expr><Right> neocomplcache#close_popup() . "\<Right>"
      inoremap <expr><Up>    neocomplcache#close_popup() . "\<Up>"
      inoremap <expr><Down>  neocomplcache#close_popup() . "\<Down>"
    endfunction
  endif
endif

"-------------------------------------------------------------------------------
" View
"-------------------------------------------------------------------------------

syntax on
set nocursorline
set nolist
set   number
set   ruler
set   title
set nowrap
"autocmd InsertEnter,InsertLeave * set cursorline!

if &encoding == "utf-8"
  set list
" 00AB(«) 00A0( ) 00AD(­) 00BB(») 2025(‥) 2026(…) 203A(›) 21B2(↲)
" 21B5(↵) 21C2(⇂) 21C4(⇄) 21C6(⇆) 21C7(⇇) 21C9(⇉) 21CB(⇋) 21CC(⇌)
" execute "set listchars=tab:\u203A\u00A0,trail:\u00AD,eol:\u21C2,extends:\u00BB,precedes:\u00AB"
  execute "set listchars=tab:\u203A\u00A0,eol:\u21C2,extends:\u00BB,precedes:\u00AB"
endif

if exists('&ambiwidth')
  set ambiwidth=double
endif

"-------------------------------------------------------------------------------
" Colors
"-------------------------------------------------------------------------------

if $VIM_256COLOR != ""
  set t_Co=256
endif

if $VIM_BACKGROUND != ""
  let &background = $VIM_BACKGROUND
endif

let form_enhanced_color = 0

if exists('+colorcolumn')
  set colorcolumn=81
endif

function! FixColorScheme()
  highlight Normal ctermbg=NONE
  highlight LineNr ctermbg=NONE
  if exists("g:colors_name")
    if g:colors_name == 'lucius'
      if &background == 'dark'
        highlight ColorColumn ctermbg=239
      elseif &background == 'light'
        highlight ColorColumn ctermbg=255
      endif
    endif
  endif
endfunction

autocmd ColorScheme * call FixColorScheme()
let g:lucius_contrast = 'high'
try
  colorscheme lucius
catch /^Vim\%((\a\+)\)\=:E185/
endtry

" Whitespaces
highlight link ExtraWhitespace Error
match ExtraWhitespace /\s\+$\| \+\ze\t/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$\| \+\ze\t/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$\| \+\ze\t/
autocmd BufWinLeave * call clearmatches()

"-------------------------------------------------------------------------------
" Searching
"-------------------------------------------------------------------------------

set   hlsearch
set   incsearch
set   ignorecase
set   smartcase
set nowrapscan
" Hide search highlights.
nmap <silent> <Esc><Esc> :nohlsearch<CR><Esc>

"-------------------------------------------------------------------------------
" Spell checking
"-------------------------------------------------------------------------------

set nospell

"-------------------------------------------------------------------------------
" Indent
"-------------------------------------------------------------------------------

set   autoindent
set nocindent
set   smartindent
set nosmarttab

command -nargs=1 TabIndent setlocal noexpandtab shiftwidth=<args> softtabstop=0 tabstop=<args>
command -nargs=1 SpaceIndent setlocal expandtab shiftwidth=<args> softtabstop=<args> tabstop=8

" Default indent (SpaceIndent 2)
set expandtab shiftwidth=2 softtabstop=2 tabstop=8

"-------------------------------------------------------------------------------
" General behaviour
"-------------------------------------------------------------------------------

set   autoread
set   hidden
set   mouse=a
set   showcmd
set   showmatch

if ! has('gui_running')
  set ttimeoutlen=10
  augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0
    au InsertLeave * set timeoutlen=1000
  augroup END
endif

set viewoptions=cursor,folds,options
augroup SaveView
  autocmd!
  autocmd BufWinLeave ?* silent mkview
  autocmd BufWinEnter ?* silent loadview
augroup END

"-------------------------------------------------------------------------------
" Keyboard
"-------------------------------------------------------------------------------

set   backspace=2
set   whichwrap=b,s,<,>,[,]

" C-A -> Start of line, C-E -> End of line
map <C-a> <Home>
map <C-e> <End>
map! <C-a> <Home>
map! <C-e> <End>

"-------------------------------------------------------------------------------
" GNU screen
"-------------------------------------------------------------------------------

if &term =~ 'screen'
  set t_ts=]2;       " set window title start (to status line)
  set t_fs=          " set window title end (from status line)
  set ttymouse=xterm2
endif

" Fix keycodes under GNU screen
map OH <Home>
map OF <End>
map! OH <Home>
map! OF <End>

map [1~ <Home>
map [4~ <End>
imap [1~ <Home>
imap [4~ <End>

"-------------------------------------------------------------------------------
" Bracketed Paste Mode
"-------------------------------------------------------------------------------

if &term =~ 'screen'
  let &t_SI = &t_SI . "\eP\e[?2004h\e\\"
  let &t_EI = "\eP\e[?2004l\e\\" . &t_EI
elseif &term =~ 'xterm' || &term =~ 'putty'
  let &t_SI .= &t_SI . "\e[?2004h"
  let &t_EI .= "\e[?2004l" . &t_EI
endif
let &pastetoggle = "\e[201~"

function XTermPasteBegin(ret)
    set paste
    return a:ret
endfunction

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin('')

"-------------------------------------------------------------------------------
" File format
"-------------------------------------------------------------------------------

set   fileformats=unix,dos,mac

"-------------------------------------------------------------------------------
" Encoding
"-------------------------------------------------------------------------------

if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  unlet s:enc_euc
  unlet s:enc_jis
endif

function! AU_ReCheck_FENC()
  if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
    let &fileencoding=&encoding
  endif
endfunction

autocmd BufReadPost * call AU_ReCheck_FENC()

"-------------------------------------------------------------------------------
" Binary mode
"-------------------------------------------------------------------------------

augroup BinaryXXD
  autocmd!
" autocmd BufReadPre  *.bin let &binary = 1
  autocmd BufReadPost * if &binary | silent %!xxd -g 1
  autocmd BufReadPost * set ft=xxd | endif
  autocmd BufWritePre * if &binary | %!xxd -r | endif
  autocmd BufWritePost * if &binary | silent %!xxd -g 1
  autocmd BufWritePost * set nomod | endif
augroup END

"-------------------------------------------------------------------------------
" File type specific settings
"-------------------------------------------------------------------------------

autocmd FileType gitcommit setlocal spell | setlocal colorcolumn=73
autocmd FileType unite highlight link ExtraWhitespace Normal
autocmd FileType python execute 'SpaceIndent 4'
autocmd FileType tex setlocal spell

autocmd BufNewFile,BufRead *.m setlocal filetype=mma

autocmd BufNewFile,BufRead */form*/sources/*.c  call FORMCSource()
autocmd BufNewFile,BufRead */form*/sources/*.cc call FORMCSource()
autocmd BufNewFile,BufRead */form*/sources/*.h  call FORMCSource()
autocmd BufNewFile,BufRead */form*/configure.ac execute 'TabIndent 4'
autocmd BufNewFile,BufRead */form*/Makefile*    execute 'TabIndent 4'

function! FORMCSource()
  execute 'TabIndent 4'
  setlocal foldmethod=marker foldmarker=#[,#] foldcolumn=4
endfunction

"-------------------------------------------------------------------------------
" File type detection
"-------------------------------------------------------------------------------

au BufNewFile,BufRead * call DetectFileType()

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

"-------------------------------------------------------------------------------
" Some commands
"-------------------------------------------------------------------------------

command RemoveCarriageReturn %s///g
command RemoveTrailingWhitespace %s/[ 	]\+$//g

command Dark    set background=dark
command Light   set background=light
command NoList  set nolist

command C       setlocal filetype=c
command CC      setlocal filetype=cpp
command F       setlocal filetype=fortran
command F77     let b:fortran_fixed_source=1|setlocal filetype=fortran
command F90     let b:fortran_fixed_source=0|setlocal filetype=fortran
command Fortran setlocal filetype=fortran
command FORM    setlocal filetype=form
command MMA     setlocal filetype=mma
command REDUCE  setlocal filetype=reduce
command TeX     setlocal filetype=tex

command ReopenAsUTF8 e ++enc=utf-8

function! FORMFold()
  if &foldmethod == "manual"
    setlocal foldmethod=marker foldmarker=#[,#] foldcolumn=4
  elseif &foldmethod == "marker"
    setlocal foldmethod=manual foldmarker={{{,}}} foldcolumn=0
  endif
endfunction

command Z call FORMFold()

function! AppendModeLine()
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
  elseif &filetype == "sh" || &filetype == "perl" || &filetype == "python"
    let l:modeline = printf("# vim: %s", l:modeline)
  elseif &filetype == "mma"  " strange &commentstring @ v7.3.62
    let l:modeline = printf("(* vim: set %s: *)", l:modeline)
  else
    let l:modeline = printf(" vim: set %s: ", l:modeline)
    let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
  endif
  call append(line("$"), l:modeline)
endfunction

command AppendModeLine call AppendModeLine()

" vim: ft=vim noet ts=8 sts=2 sw=2
