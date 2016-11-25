se nocompatible
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
set nowrap

" Autocmd ---------------------------------------------------------------------
" Filetypes
au BufRead,BufNewFile *.geojson setfiletype json
au BufRead,BufNewFile *.topojson setfiletype json

" Language specific settings
autocmd FileType javascript setlocal shiftwidth=4 softtabstop=4 tabstop=4
autocmd FileType pig setlocal shiftwidth=4 softtabstop=4 tabstop=4
autocmd FileType sh setlocal shiftwidth=4 softtabstop=4 tabstop=4

" Run neomake on every enter or save
autocmd! BufWritePost,BufEnter *.js Neomake
autocmd! BufWritePost,BufEnter *.sh Neomake

" Delete trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" Plugins ------------------------------------------------
call plug#begin('~/.config/nvim/plugged')

" File management
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Statusbar
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'

" Language support
Plug 'neomake/neomake'
Plug 'motus/pig.vim'
Plug 'pangloss/vim-javascript'
Plug 'fatih/vim-go'
Plug 'rust-lang/rust.vim'

" Convenience
Plug 'ervandew/supertab'
Plug 'SirVer/ultisnips'
Plug 'tpope/vim-surround'

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
let g:airline_theme='base16'
let g:SuperTabDefaultCompletionType = "context"
let $FZF_DEFAULT_COMMAND = 'ag --ignore={.git,node_modules,coverage} --hidden -g "" -U'

" Linting
let g:neomake_javascript_enabled_makers = ['jscs', 'jshint']
let g:neomake_javascript_enabled_makers = ['jscs', 'jshint']

" Theme -------------------------------------------------
set t_Co=256
set background=dark
set encoding=utf-8
colorscheme solarized

" Commands ---------------------------------------------
command! W write
command! Q quit

" Maps --------------------------------------------------
" Send code to tmux
noremap <leader>rr m`:VtrSendLinesToRunner<cr>``
noremap <leader>ar :VtrAttachToPane<cr>

" Simple function for reformatting code/json
function! ReFormat()
  if &filetype=='json'
    :%!python -m json.tool
  else
    normal! gg=G``
  endif
endfunction

noremap <leader>rf :call ReFormat()<cr>
noremap <leader>gh :Gbrowse<cr>
noremap <leader>gd :Gdiff<cr>
imap    <leader>ff <plug>(fzf-complete-path)

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
nnoremap <C-I> :Ag<CR>
nnoremap <C-C> :Commit<CR>

" stolen from https://bitbucket.org/sjl/dotfiles/src/tip/vim/vimrc
" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" indent visual selected code without unselecting and going back to normal mode
vmap > >gv
vmap < <gv

