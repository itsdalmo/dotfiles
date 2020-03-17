syntax enable
colorscheme solarized

" Basic settings --------------------------------------------------------------
set background=dark
set nocompatible
set encoding=utf-8
set laststatus=2
set clipboard=unnamed
set autoindent
set smartindent
set relativenumber
set numberwidth=4
set showmatch
set history=10000
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set scrolloff=5                         "Keeps 5 lines at bottom when scrolling
set mouse=n                             "mouse in normal mode
set backupdir^=~/.vim/_backup//
set directory^=~/.vim/_temp//
set ignorecase
set smartcase
set hlsearch
set nobackup
set nowritebackup
set noswapfile
set showtabline=0
set splitright
set splitbelow
set nowrap

command! W write
command! Q quit

" Keep search matches in the middle of the window.
" (source: https://bitbucket.org/sjl/dotfiles/src/tip/vim/vimrc)
nnoremap n nzzzv
nnoremap N Nzzzv

" indent visual selected code without unselecting and going back to normal mode
vmap > >gv
vmap < <gv
