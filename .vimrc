set number
set shiftwidth=4
set tabstop=4
syntax on
set smartindent
set mouse=a

filetype plugin on

" viminfo
" '10 	: files to remember marks 
" "100 	: lines per register
" :20	: lines of command line history
" %		: saves and restores buffer list
" n...	: where to save 

set viminfo='10,\"100,:20,%,n~/.viminfo

" Last known cursor pos, vim tip 80
	autocmd BufReadPost * 
	\	if line("'\"") > 0 |
	\		if line("'\"") <= line("$") |
	\			exe "normal '\"" |
	\		else |
	\			exe "normal $" |
	\		endif |
	\ 	endif

au BufNewFile,BufRead *.rb,*.erb call RubySettings()
 
function RubySettings()
  set tabstop=2
  set shiftwidth=2
endfunction
