" ##############################################################################
"   ██╗   ██╗██╗███╗   ███╗██████╗  ██████╗
"   ██║   ██║██║████╗ ████║██╔══██╗██╔════╝
"   ██║   ██║██║██╔████╔██║██████╔╝██║     
"   ╚██╗ ██╔╝██║██║╚██╔╝██║██╔══██╗██║     
" ██╗╚████╔╝ ██║██║ ╚═╝ ██║██║  ██║╚██████╗
" ╚═╝ ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝
" ##############################################################################

set encoding=utf8
set autoread
set lazyredraw
set wildmenu
set number
set relativenumber
set showmatch
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent
set incsearch
set hlsearch
set tabstop=4
set softtabstop=4
set colorcolumn=80,120
set listchars=tab:→⠀,space:·
set list
set nowrap
set nobackup
set nowb
set noswapfile
set ttymouse=xterm2
set mouse=a
set belloff=all
set hidden
set scrolloff=10
set conceallevel=3
set backspace=indent,eol,start

let mapleader = ','

" ——————————————————————————————————————————————————————————————————————————————
" Plugins
" ——————————————————————————————————————————————————————————————————————————————

call plug#begin('~/.vim/plugged')
  Plug 'sheerun/vim-polyglot'
  Plug 'ervandew/supertab'

  function FixupBase16(info)
    !sed -i '/Base16hi/\! s/a:\(attr\|guisp\)/l:\1/g' ~/.vim/plugged/base16-vim/colors/*.vim
  endfunction
  Plug 'chriskempson/base16-vim', { 'do': function('FixupBase16') }
  Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
  Plug 'ryanoasis/vim-devicons'
  Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'airblade/vim-gitgutter'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'terryma/vim-multiple-cursors'
  Plug 'junegunn/goyo.vim'
  Plug 'blueyed/vim-diminactive'
  Plug 'w0rp/ale'

  Plug 'pangloss/vim-javascript'
call plug#end()

" ——————————————————————————————————————————————————————————————————————————————
" Theme/Syntax
" ——————————————————————————————————————————————————————————————————————————————

syntax enable
highlight EndOfBuffer ctermfg=black ctermbg=black
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif
let g:airline_theme = 'base16'
highlight EndOfBuffer ctermfg=bg

" ——————————————————————————————————————————————————————————————————————————————
" File Explorer
" ——————————————————————————————————————————————————————————————————————————————

let g:loaded_netrw=1
let g:loaded_netrwPlugin=1
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1
let NERDTreeMinimalUI = 1
let NERDTreeShowHidden=1
if exists("g:loaded_webdevicons")
  call webdevicons#refresh()
endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" ——————————————————————————————————————————————————————————————————————————————
" Window/Buffer Management
" ——————————————————————————————————————————————————————————————————————————————

let g:diminactive_use_syntax = 1

" ——————————————————————————————————————————————————————————————————————————————
" Status Bar
" ——————————————————————————————————————————————————————————————————————————————

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#whitespace#enabled = 0

" ——————————————————————————————————————————————————————————————————————————————
" GIT
" ——————————————————————————————————————————————————————————————————————————————

if exists('&signcolumn')
  set signcolumn=yes
else
  let g:gitgutter_sign_column_always = 1
endif
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '▪'
let g:gitgutter_sign_removed = '−'
let g:gitgutter_sign_removed_first_line = 'ꜛ'
let g:gitgutter_sign_modified_removed = '▫'

" ——————————————————————————————————————————————————————————————————————————————
" Fuzzy Finding
" ——————————————————————————————————————————————————————————————————————————————

if executable('ag') " (The Silver Searcher)
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  let g:ctrlp_use_caching = 0
  let g:ctrlp_formatline_func = 's:formatline(s:curtype() == "buf" ? v:val : WebDevIconsGetFileTypeSymbol(v:val) . " " . v:val) '

  command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
  nnoremap \ :Ag<SPACE>
endif

" ——————————————————————————————————————————————————————————————————————————————
" Key Bindings
" ——————————————————————————————————————————————————————————————————————————————

map <C-b> :NERDTreeToggle<CR>            " Toggle the File Explorer
noremap <Leader>w :update<CR>            " Write the current file
noremap <Leader>r :source ~/.vimrc<CR>   " Re-source ~/.vimrc
map <Leader>f :NERDTreeFind<CR>          " Find in file explorer
nnoremap <space> za                      " Opens/closes folds
nnoremap <Leader><space> :nohlsearch<CR> " Turn off search highlight

nmap <leader>T :enew<CR>                 " Open a new/empty buffer
nmap <leader>l :bnext<CR>                " Next buffer
nmap <leader>h :bprevious<CR>            " Previous buffer
nmap <leader>bq :bp <BAR> bd #<CR>       " Close buffer
nmap <leader>bl :ls<CR>                  " List open buffers
