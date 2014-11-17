set encoding=utf-8
set nocompatible
call pathogen#infect()

syntax enable
set background=dark
colorscheme solarized
call togglebg#map("<F6>")

filetype plugin indent on

au FocusLost * :wa

set sw=2 ts=2 sts=2

set showmode
set hidden
set expandtab
set number
set ruler
set nowrap
"set wrap
set textwidth=79
set formatoptions=qrn1
set colorcolumn=85
set ignorecase
set smartcase
set incsearch
set history=1000
set undolevels=1000
set title
set nobackup
set noswapfile
set undofile
set showmatch
set ttyfast
set cursorline
set scrolloff=10
set laststatus=2
"set cindent

set wildignore+=*.beam,*.class,*.jar,*.sql,*/vendor/bundle/*,*/target/*,*/coverage/*,*/yacat-repos/*,*/tmp/*,*/log/*,*/_site/*
let g:netrw_list_hide= '.*\.beam$'

autocmd BufWritePre * :%s/\s\+$//e
autocmd filetype java :setlocal sw=4 ts=4 sts=4
autocmd filetype ruby map <F9> :w<CR>:!ruby -c %<CR>
autocmd filetype xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null
autocmd FileType python setlocal sw=4 ts=4 sts=4

nnoremap <expr> gb '`[' . strpart(getregtype(), 0, 1) . '`]'
map   <silent> <F5> mmgg=G'm
imap  <silent> <F5> <Esc> mmgg=G'm
