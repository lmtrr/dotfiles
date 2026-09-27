" Vim filetype plugin file
" Language:	C++
" Maintainer:	Theo P.
" Last Change:	2023-10-15

setlocal expandtab tabstop=2 softtabstop=2 shiftwidth=2
setlocal colorcolumn=80 textwidth=79
setlocal matchpairs+==:;

" This command is to compile a single C++ file with debug symbols using clang++.
" For more complex project (that is, any project with more than one .cc file),
" you should consider making a Makefile and use `:make` command
command! RunCpp !clang++ -g -O0 -std=c++20 %:p -o %:p:r
