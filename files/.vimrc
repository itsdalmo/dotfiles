se nocompatible
let mapleader = "\<SPACE>"

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
autocmd FileType py setlocal shiftwidth=4 softtabstop=4 tabstop=4
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
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'scrooloose/nerdtree'
Plug 'junegunn/vim-easy-align'

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
let g:airline_inactive_collapse=1
let g:SuperTabDefaultCompletionType = "context"

" Linting
let g:neomake_javascript_enabled_makers = ['jscs', 'jshint']
let g:neomake_javascript_enabled_makers = ['jscs', 'jshint']

" Path completion etc
let g:SuperTabDefaultCompletionType = "context"

" Theme -------------------------------------------------
set background=dark
colorscheme solarized
set encoding=utf-8
" set t_ut=
hi VertSplit ctermbg=NONE guibg=NONE

" Commands ---------------------------------------------
command! W write
command! Q quit
" TODO: Figure out why this is not working...
" command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)

" Functions ---------------------------------------------
" Simple function for reformatting code/json
function! ReFormat()
  if &filetype=='json'
    :%!python -m json.tool
  else
    normal! gg=G``
  endif
endfunction

" Misc -------------------------------------------------
" stolen from https://bitbucket.org/sjl/dotfiles/src/tip/vim/vimrc
" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" indent visual selected code without unselecting and going back to normal mode
vmap > >gv
vmap < <gv

" Maps --------------------------------------------------
" No exmode
nnoremap Q <nop>

" Buffers
nmap <LEADER><TAB> <C-^>
nmap <LEADER>bb :buffers<CR>
nmap <LEADER>bd :bdelete<CR>
nmap <LEADER>bn :bn<CR>
nmap <LEADER>bp :bp<CR>
nmap <LEADER>bR :e<CR>

" Commentary
nmap <Leader>;  <Plug>Commentary
nmap <Leader>;; <Plug>CommentaryLine
omap <Leader>;  <Plug>Commentary
vmap <Leader>;  <Plug>Commentary

" Errors
nmap <silent> <Leader>en :lnext<CR>
nmap <silent> <Leader>ep :lprev<CR>

" Files
nmap <LEADER>fed :e ~/.config/nvim/init.vim<CR>
nmap <LEADER>feR :source ~/.config/nvim/init.vim<CR>
nmap <LEADER>ff :Files<CR>
nmap <LEADER>fF :Files ..<CR>
nmap <LEADER>fr :History<CR>
nmap <LEADER>fs :w<CR>
nmap <LEADER>fS :wa<CR>
nmap <LEADER>ft :NERDTreeToggle<CR>"
nmap <LEADER>fR :Move<CR>"

" Git
nmap <LEADER>gh :Gbrowse<CR>
nmap <LEADER>gb :Gblame<CR>
nmap <LEADER>gd :Gdiff<CR>
nmap <LEADER>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<cr>

" Project
" nmap <LEADER>pf :CtrlPRoot<CR>
" nmap <LEADER>pt :call spacemacs#toggleExplorerAtRoot()<CR>

" Toggles
nmap <LEADER>tn :set relativenumber!<CR>

" Search
nmap <Leader>sc :noh<CR>
nmap <LEADER>sp :Ag<CR>

" Window
nmap <LEADER>wh :sp<CR>
nmap <LEADER>wv :vsp<CR>
nmap <LEADER>w= <C-W>=
nmap <LEADER>wd :q<CR>
nmap <LEADER>ww <C-W><C-W>

" Code
noremap <leader>mf :call ReFormat()<cr>
noremap <leader>ma :VtrAttachToPane<cr>
noremap <leader>mr m`:VtrSendLinesToRunner<cr>``
noremap <leader>ml :EasyAlign*<Bar><cr>

" Quit/exit
nmap <LEADER>qw :q<CR>
nmap <LEADER>qq :qa<CR>
nmap <Leader>qQ :qa!<CR>
nmap <Leader>qs :xa<CR>

" imap    <leader>ff <plug>(fzf-complete-path)
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-j> :TmuxNavigateDown<cr>
nnoremap <silent> <C-k> :TmuxNavigateUp<cr>
nnoremap <silent> <C-l> :TmuxNavigateRight<cr>

" Use arrowkeys to resize window in normal mode.
nnoremap <silent> <Up> :resize -5<cr>
nnoremap <silent> <Down> :resize +5<cr>
nnoremap <silent> <Right> :vertical resize -5<cr>
nnoremap <silent> <Left> :vertical resize +5<cr>

" Fix for C-h in Neovim
if has('nvim')
    nmap <BS> :<C-u>TmuxNavigateLeft<CR>
else
    nmap <C-h> <C-w>h
endif
