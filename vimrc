colorscheme desert
filetype plugin indent on
call pathogen#infect()
syntax on

set softtabstop=2
set expandtab
set shiftwidth=2
set number

autocmd BufWritePre * :%s/\s\+$//e

noremap   <Up> ""
noremap!  <Up> <Esc>
noremap   <Down> ""
noremap!   <Down> <Esc>
noremap   <Right> ""
noremap!  <Right> <Esc>
noremap  <Left> ""
noremap!  <Left> <Esc>
