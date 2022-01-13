" Mostly stolen from Yan Pritzer's most excellent Yadr (github.com/skwp/dotfiles)

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
set encoding=utf-8

" ================ General Config ====================
"
"
set foldmethod=manual
set number                      "Line numbers are good
set backspace=indent,eol,start  "Allow backspace in insert mode
set history=1000                "Store lots of :cmdline history
set showcmd                     "Show incomplete cmds down the bottom
set showmode                    "Show current mode down the bottom
set gcr=a:blinkon0              "Disable cursor blink
set visualbell                  "No sounds
set autoread                    "Reload files changed outside vim
"set clipboard=unnamed

" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
set hidden

"turn on syntax highlighting
syntax on

" The mapleader has to be set before vundle starts loading all
" the plugins.
let mapleader = ";"

" ================ Turn Off Swap Files ==============

set noswapfile
set nobackup
set nowb

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" ================ Indentation ======================

set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab

" Auto indent pasted text
nnoremap p p=`]<C-o>
nnoremap P P=`]<C-o>

" Plugins
call plug#begin('~/.vim/plugged')

" Theme
Plug 'morhetz/gruvbox'
Plug 'jacoborus/tender.vim'

" Misc plugins
Plug 'ryanoasis/vim-devicons'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-startify'
Plug 'stephpy/vim-yaml'
Plug 'tpope/vim-surround'
Plug 'andymass/vim-matchup'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'

"Plug 'preservim/nerdcommenter'
"Plug 'mg979/vim-visual-multi', {'branch': 'master'}
"Plug 'ntpeters/vim-better-whitespace'
"Plug 'tpope/vim-repeat'
"Plug 'jiangmiao/auto-pairs'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'terryma/vim-multiple-cursors'

 "HTML
"Plug 'mattn/emmet-vim'

" Javascript/Typescript
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'

" Ruby
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-rails'
Plug 'vim-ruby/vim-ruby'

" Elixir
Plug 'elixir-editors/vim-elixir'

" Haskell
Plug 'neovimhaskell/haskell-vim'

" Dart
Plug 'dart-lang/dart-vim-plugin'

" Testing
Plug 'janko/vim-test'
Plug 'victormours/vim-rspec'
Plug 'pgr0ss/vimux-ruby-test'
Plug 'benmills/vimux'

Plug 'tpope/vim-dispatch'

call plug#end()

" Theme
syntax enable
set background=dark

" Tender
"colorscheme tender

" Gruvbox
let g:gruvbox_contrast_light=1
let g:gruvbox_italic=1
colorscheme gruvbox

if (has("termguicolors"))
 set termguicolors
endif

if has("gui_running")
"tell the term has 256 colors
  set t_Co=256
end

" Ruler
set ruler
set textwidth=200
set colorcolumn=80

" Better search
set hlsearch
set incsearch

set nowrap       "Don't wrap lines
"set linebreak    "Wrap lines at convenient points

" Wildignore for search
set wildignore+=.keep,*.beam,*.class,*.jar,*.sql,*/vendor/bundle/*,*/target/*,*/coverage/*,*/yacat-repos/*,*/tmp/*,*/log/*,*/_site/*,*/node_modules/*,*/dist/*,*/deps/*,*/__snapshots__/*,*/cypress/data/*

" RipGrep
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%m
endif

autocmd BufReadPre,FileReadPre *.md :set wrap

" Enable filetype plugins for vim-textobj-rubyblock
if has("autocmd")
  filetype indent plugin on
endif

autocmd FocusLost * silent! wa " Automatically save file

set scrolloff=5 " Keep 5 lines below and above the cursor
set cursorline
set laststatus=2
set showmatch
set formatoptions-=cro " Disable continuation of comments when pasting text

autocmd VimResized * wincmd = " Automatically resize splits when resizing window

" FileTypes configuration
autocmd FileType ruby setlocal expandtab sw=2 ts=2 sts=2
autocmd FileType eruby setlocal expandtab sw=2 ts=2 sts=2
autocmd FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null
autocmd FileType gitcommit set colorcolumn=73 textwidth=72
autocmd BufWritePre * :%s/\s\+$//e

" Devicons
let g:webdevicons_enable = 1
let g:webdevicons_enable_nerdtree = 1

" Tree configuration
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:NERDTreeHijackNetrw = 0
let g:NERDTreeWinSize=60
let g:NERDTreeStatusline = '%#NonText#'
"let NERDTreeQuitOnOpen = 1
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeIgnore=['\.o$', '\~$', 'node_modules', 'cypress/data', 'dist']
autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Prevent opening file inside NERDTree
au BufEnter * if bufname('#') =~ 'NERD_tree' && bufname('%') !~ 'NERD_tree' && winnr('$') > 1 | b# | exe "normal! \<c-w>\<c-w>" | :blast | endif

nnoremap <silent> <leader>n :NERDTreeToggle<CR>
nnoremap <silent> <leader>k :NERDTreeFind<CR>

" Go to tab by number
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<cr>
noremap <leader>x :tabclose<cr>

" Go to last active tab

au TabLeave * let g:lasttab = tabpagenr()
nnoremap <silent> <leader>b :exe "tabn ".g:lasttab<cr>
vnoremap <silent> <leader>b :exe "tabn ".g:lasttab<cr>

" Customize Fzf

function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'

let rgignore = '**/node_modules/*,**/.git/*,**/vendor/assets/*,**/vendor/bundle/*,**/public/assets/*,**/public/packs/*,**/public/fonts/*,*.sql,*.csv,*.log,**/.keep,*.json'

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --hidden --follow --no-heading --color=always --smart-case --glob "!{rgignore}" -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction
command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

command! -bang -nargs=? -complete=dir Files
			\ call fzf#run(fzf#wrap({'source': 'rg --files --hidden --follow', 'down': '40%'}))

nnoremap <silent> <C-p> :Files<CR>
nnoremap <silent> <C-i> :Buffers<CR>
nnoremap <silent> <C-f> :RG<CR>

" Lightline configuration
let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'absolutepath', 'modified' ] ],
      \   'right': [ [ 'lineinfo' ], [ 'percent' ] ]
      \ },
      \ }
let g:lightline.component = { 'close': '' }

" Quickfix window bindings
nnoremap <leader>cn :cnext<CR>
nnoremap <leader>cp :cprevious<CR>
nnoremap <leader>cc :ccl<CR>

" Rspec configuration
let test#ruby#rspec#executable = 'bundle exec rspec'
let test#ruby#use_spring_binstub = 1
map <silent> <leader>tf :TestFile -strategy=vimux<CR>
map <silent> <leader>tn :TestNearest -strategy=vimux<CR>
map <silent> <leader>tl :TestLast -strategy=vimux<CR>
map <silent> <leader>ta :TestSuite -strategy=vimux<CR>

" Misc
nnoremap <leader> <expr> gb '`[' . strpart(getregtype(), 0, 1) . '`]'
nnoremap <leader>r :source %<CR>
nnoremap <leader>pi :PlugInstall<CR>
noremap <leader>q :q<CR>
noremap <leader>w :w<CR>
noremap <leader>qq :qa!<CR>
noremap <leader>z :nohl<CR>
noremap <leader>sp :set paste<CR>
noremap <leader>snp :set nopaste<CR>

nmap <silent> <C-s> :w<CR>
imap <silent> <C-s> <Esc>:w<CR>

nmap <leader>pbp :set paste<CR>:r !pbpaste<CR>:set nopaste<CR>
imap <leader>pbp <Esc>:set paste<CR>:r !pbpaste<CR>:set nopaste<CR>
nmap <leader>pby :.w !pbcopy<CR><CR>
vmap <leader>pby :w !pbcopy<CR><CR>

noremap <leader>aa :call VimuxRunCommand("clear; bundle exec rake test")<CR>
noremap <leader>ai :call VimuxRunCommand("clear; bundle exec ruby -r ./test/test_helper " . bufname("%"))<CR>
noremap <leader>ae :call VimuxRunCommand("clear; bundle exec rake e2e")<CR>
