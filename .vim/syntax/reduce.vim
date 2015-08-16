" Vim syntax file
" Language:     Reduce
" Last Change:  22 Aug 2013
" Filenames:    *.red

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
	syntax clear
elseif exists("b:current_syntax")
	finish
endif

syntax case ignore

syntax keyword reduceCommand     array bye clear end factor for if in index let match matrix nospur off on operator out procedure quit remind scalar shut spur vector write
"	syntax keyword reduceBooleanOp
syntax keyword reduceInfixOp     and eq neq or
"	syntax keyword reduceNumberOp
syntax keyword reducePrefixOp    linelength varname
"	syntax keyword reduceReservedVar
"	syntax keyword reduceSwitches
syntax keyword reduceReservedId  begin do while
syntax keyword reduceCommandEx   all then else

syntax match  reduceComment      "%.*$"
syntax region reduceString       start=+"+ skip=+\\"+ end=+"+
syntax match  reduceNumber       "\<\d\+\>"
"	syntax match  reduceNumber       "-\d" contains=Number

if version >= 508 || !exists("did_reduce_syn_inits")
	if version < 508
		let did_reduce_syn_inits = 1
		command -nargs=+ HiLink hi link <args>
	else
		command -nargs=+ HiLink hi def link <args>
	endif

	HiLink reduceNumber        Number
	HiLink reduceCommand       Statement
	HiLink reduceInfixOp       Statement
	HiLink reducePrefixOp      Statement
	HiLink reduceReservedId    Statement
	HiLink reduceCommandEx     Statement
	HiLink reduceComment       Comment
	HiLink reduceString        String

	delcommand HiLink
endif

let b:current_syntax = "reduce"
