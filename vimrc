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
autocmd FileType ruby map <F9> :w<CR>:!ruby -c %<CR>
au FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null

