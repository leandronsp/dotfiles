colorscheme desert
filetype plugin indent on
call pathogen#infect()
syntax on

set softtabstop=2
set expandtab
set shiftwidth=2
set number
set ruler

set wildignore+=*.class,*.jar,*/target/*

autocmd BufWritePre * :%s/\s\+$//e

