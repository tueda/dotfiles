" A macro may not be followed by a space.
"  syn region gnuplotMacro         start="@" end=" "

syntax match gnuplotMacro /@\<\w*\>/

" Logical negation/factorial operators mess up the rest of the line.
"  syn region gnuplotExternal      start="!" end="$"

syntax match gnuplotOperator "!"
