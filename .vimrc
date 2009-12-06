""""""""""
" General
""""""""""

" Allow backspacing over everything
set bs=2
" Create a .viminfo
set viminfo='20,\"50
" Don't create backup files
set nobackup
" Allow switching buffers without writing to disk
set hidden
" Show cursor position
set ruler
" Set terminal title
set title

" Allow pasting from outside vim
set pastetoggle=<F2>
" Line wrapping
set wrap
" I hate terminal beeps
set visualbell
" Show possible tab completions
set wildmenu
" Ignore these files when completing. I usually don't want to open them
set wildignore=.svn,CVS,.git,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif

""""""""""""
" Indention
""""""""""""

" Use smart indention for the language being edited
set smartindent

" ASCII tab display spaces
set tabstop=4
" Keyboard tab spaces
set shiftwidth=4
" Number of spaces tab counts for in editing operations
set softtabstop=4
" Don't add tabs as spaces
set noexpandtab
" Don't add two spaces after punctuation
set nojoinspaces

""""""""""""
" Interface
""""""""""""

" Color scheme
colors desert
" I use dark terminals
set background=dark

" Line numbers
set number

" Highlight spaces after the end of the line
highlight RedundantSpaces term=standout ctermbg=red guibg=red
match RedundantSpaces /\s\+$\| \+\ze\t/ "\ze sets end of match so only spaces highlighted

""""""""""""""""""""""
" Syntax highlighting
""""""""""""""""""""""
syntax on

""""""""""""
" Searching
""""""""""""

" Turn off annoying highlights
nnoremap <F6> :set invhls<CR>

" Incremental search
set incsearch
" Don't care about case when searching
set ignorecase
" Ignore case only if I type in lower case when searching
set smartcase

"""""""""""""""""""""
" File type handling
"""""""""""""""""""""

filetype on
filetype plugin on
filetype indent on

"""""""""""""""
" Key bindings
"""""""""""""""

set tags+=~/.tags
map <C-F6> :!ctags -R .<CR>
map <F5> :!make<CR>

