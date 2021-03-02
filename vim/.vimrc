call plug#begin('~/.vim/plugged')
Plug 'romainl/flattened'
Plug 'itchyny/lightline.vim'
Plug 'scrooloose/nerdtree'
Plug 'vim-syntastic/syntastic'
Plug 'rainglow/vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'morhetz/gruvbox'
call plug#end()

set number
"set linespace=1
"set guifont=Fira\ Code:h12
set cursorline

"display lightline
"set laststatus=2
"set noshowmode

autocmd vimenter * NERDTree
map <F5> :NERDTreeToggle<CR>
nnoremap <leader>n :NERDTreeFocus<CR>
"let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

autocmd vimenter * ++nested colorscheme gruvbox
set background=dark    " Setting dark mode

set mouse=a

let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1

set splitbelow
terminal ++rows=10

