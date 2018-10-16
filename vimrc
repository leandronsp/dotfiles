set encoding=utf-8
set nocompatible
call pathogen#infect()

syntax enable
set background=dark

let g:gruvbox_contrast_light=1
let g:gruvbox_italic=1
colorscheme gruvbox
call togglebg#map("<F6>")

filetype plugin indent on

set sw=2 ts=2 sts=2

set showmode
set hidden
set expandtab
set number
set ruler
set nowrap
set paste
set textwidth=80
set formatoptions=cro
set colorcolumn=80
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
set autoread
"set cindent

set wildignore+=*.beam,*.class,*.jar,*.sql,*/vendor/bundle/*,*/target/*,*/coverage/*,*/yacat-repos/*,*/tmp/*,*/log/*,*/_site/*,*/node_modules/*,*/dist/*,*/deps/*,*/__snapshots__/*,*/cypress/data/*
let g:netrw_liststyle=3
let g:netrw_list_hide= '.*\.beam$'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_max_files=0
let g:NERDTreeWinSize = 50
map <C-n> :NERDTreeToggle<CR>
map <C-k> :NERDTreeFind<CR>
let g:NERDTreeHijackNetrw=0
let NERDTreeIgnore=['\.o$', '\~$', 'node_modules', 'cypress/data']
"let vim_markdown_preview_hotkey='<C-m>'

autocmd BufWritePre * :%s/\s\+$//e
autocmd filetype java :setlocal sw=4 ts=4 sts=4
autocmd filetype ruby map <F9> :w<CR>:!ruby -c %<CR>
autocmd filetype xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null
autocmd FileType python setlocal sw=4 ts=4 sts=4
autocmd FileType ruby let b:dispatch = 'bundle exec rspec --drb %'
autocmd FileType gitcommit set colorcolumn=73
autocmd FileType gitcommit set textwidth=72
autocmd BufNewFile,BufReadPost *.coffee setl foldmethod=indent nofoldenable
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

nnoremap <expr> gb '`[' . strpart(getregtype(), 0, 1) . '`]'
map   <silent> <F5> mmgg=G'm
imap  <silent> <F5> <Esc> mmgg=G'm
nnoremap <F8> :Dispatch!<CR>
nnoremap <F8> :Dispatch!<CR>
