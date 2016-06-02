" Define the default highlighting. {{{1
" by default, enable all region-based highlighting
let s:tex_fast= "bcmMprsSvV"
if exists("g:tex_fast")
 if type(g:tex_fast) != 1
  " g:tex_fast exists and is not a string, so
  " turn off all optional region-based highighting
  let s:tex_fast= ""
 else
  let s:tex_fast= g:tex_fast
 endif
 let s:tex_no_error= 1
else
 let s:tex_fast= "bcmMprsSvV"
endif

" Sections, subsections, etc: {{{1
if s:tex_fast =~ 'p'
  if !exists("g:tex_nospell") || !g:tex_nospell
   if exists("g:tex_fold_enabled") && g:tex_fold_enabled && has("folding")
    syn region texTitle			matchgroup=texSection start='\\abstract\>\s*{' end='}'													fold contains=@texFoldGroup,@Spell
   else
    syn region texTitle			matchgroup=texSection start='\\abstract\>\s*{' end='}'													contains=@texFoldGroup,@Spell
   endif
  else
   if exists("g:tex_fold_enabled") && g:tex_fold_enabled && has("folding")
    syn region texTitle			matchgroup=texSection start='\\abstract\>\s*{' end='}'													fold contains=@texFoldGroup
   else
    syn region texTitle			matchgroup=texSection start='\\abstract\>\s*{' end='}'													contains=@texFoldGroup
   endif
  endif
endif
" vim: ts=8 fdm=marker
