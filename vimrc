set nocompatible
let mapleader=","

" Basic settings --------------------------------------------------------------
syntax enable
syntax on
set laststatus=2
set clipboard=unnamed
set autoindent
set smartindent
set relativenumber
set numberwidth=4
set showmatch
set history=10000
set colorcolumn=80
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set scrolloff=5                         "Keeps 5 lines at bottom when scrolling
set mouse=n                             "mouse in normal mode
set backupdir^=~/.vim/_backup//
set directory^=~/.vim/_temp//
set cursorline
set ignorecase
set smartcase
set hlsearch
set nobackup
set nowritebackup
set noswapfile
set showtabline=0
set splitright
set splitbelow

" Autocmd ---------------------------------------------------------------------
" Language specific settings
autocmd FileType markdown setlocal shiftwidth=4 softtabstop=4 tabstop=4 wrap linebreak nolist wrap lbr colorcolumn=0 synmaxcol=999999

" Don't add the comment prefix when I hit enter or o/O on a comment line.
autocmd FileType * setlocal formatoptions-=r formatoptions-=o

" Plugins ------------------------------------------------
call plug#begin('~/.vim/plugged')

" File management
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Statusbar 
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Language support
Plug 'ervandew/supertab'
Plug 'pangloss/vim-javascript'
Plug 'moll/vim-node'
Plug 'leafgarland/typescript-vim'
Plug 'motus/pig.vim'
Plug 'othree/html5.vim'
Plug 'leshill/vim-json'
Plug 'tpope/vim-markdown'

" Git
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'

" Theme 
Plug 'altercation/vim-colors-solarized'

" Tmux
Plug 'christoomey/vim-tmux-navigator'
Plug 'christoomey/vim-tmux-runner'

call plug#end()

" Plugin settings ---------------------------------------
let g:javascript_plugin_jsdoc = 1
let g:jsx_ext_required = 0
let g:airline_powerline_fonts = 1
let g:airline_theme='solarized'
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'

" Theme ------------------------------------------------- 
set t_Co=256
set background=dark
set encoding=utf-8
colorscheme solarized

" Maps --------------------------------------------------
" Send code to tmux
noremap <leader>fr :VtrFocusRunner<cr>
noremap <leader>kr :VtrKillRunner<cr>
noremap <leader>rr :VtrSendLinesToRunner<cr>j
noremap <leader>dr :VtrSendCtrlD<cr>
noremap <leader>ar :VtrAttachToPane<cr>

" CTRL movement between windows
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" Use arrowkeys to resize window in normal mode.
nnoremap <silent> <Up> :resize -5<cr>
nnoremap <silent> <Down> :resize +5<cr>
nnoremap <silent> <Right> :vertical resize -5<cr>
nnoremap <silent> <Left> :vertical resize +5<cr>

" Open fzf with ctrl+o and ctrl+p
nnoremap <C-O> :History<CR>
nnoremap <C-P> :Files<CR>

" stolen from https://bitbucket.org/sjl/dotfiles/src/tip/vim/vimrc
" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" indent visual selected code without unselecting and going back to normal mode
vmap > >gv
vmap < <gv

