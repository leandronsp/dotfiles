set nocompatible
call pathogen#infect()

syntax enable
set background=dark
colorscheme solarized
call togglebg#map("<F5>")

filetype plugin indent on

set sw=2 ts=2 sts=2

set showmode
set hidden
set expandtab
set number
set ruler
set nowrap
set ignorecase
set smartcase
set incsearch
set history=1000
set undolevels=1000
set title
set nobackup
set noswapfile
set showmatch
set ttyfast
set cursorline
set scrolloff=10

set wildignore+=*.class,*.jar,*.sql,*/vendor/bundle/*,*/target/*,*/coverage/*,*/yacat-repos/*,*/tmp/*,*/log/*

autocmd BufWritePre * :%s/\s\+$//e
autocmd filetype java :setlocal sw=4 ts=4 sts=4
autocmd filetype ruby map <F9> :w<CR>:!ruby -c %<CR>
autocmd filetype xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null

