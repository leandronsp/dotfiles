colorscheme desert
filetype plugin indent on
call pathogen#infect()
syntax on

set sw=2 ts=2 sts=2
autocmd FileType java :setlocal sw=4 ts=4 sts=4

set expandtab
set number
set ruler

set wildignore+=*.class,*.jar,*/target/*,*/coverage/*

autocmd BufWritePre * :%s/\s\+$//e

