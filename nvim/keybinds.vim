""" Personal key bindings

" WASD style movement
nnoremap i <Up>
nnoremap k <Down>
nnoremap j <Left>
nnoremap l <Right>

vnoremap i <Up>
vnoremap k <Down>
vnoremap j <Left>
vnoremap l <Right>
vnoremap I <Up>
vnoremap K <Down>

noremap h i
noremap H I

" Ctrl-modifier
nnoremap <C-i> 5<Up>
nnoremap <C-k> 5<Down>
nnoremap <C-j> <S-Left>
nnoremap <C-l> <S-Right>

vnoremap <C-i> 5<Up>
vnoremap <C-k> 5<Down>
vnoremap <C-j> <S-Left>
vnoremap <C-l> <S-Right>

inoremap <C-j> <Left>
inoremap <C-l> <Right>

nnoremap <S-l> $
nnoremap <S-j> ^
vnoremap <S-l> $
vnoremap <S-j> ^

nnoremap <C-S-K> J

nnoremap vi v<Up>

" Window navigation
noremap <C-w>i <C-w>k
noremap <C-w><C-i> <C-w>k
noremap <C-w>j <C-w>h
noremap <C-w><C-j> <C-w>h
noremap <C-w>k <C-w>j
noremap <C-w><C-k> <C-w>j
noremap <C-w><C-l> <C-w>l

" Search
noremap <C-f> /

" Search for current selection
vnoremap // y/<C-R>"<CR>

" Redo on same key
noremap <C-u> <C-r>

" Comment block
vnoremap # <Home><C-v>I#<Esc>

" Repeat last change and go to next occurence
noremap _ .n

" Ctrl-C ftw
nnoremap <silent> <C-c> <Esc>:noh<CR>
inoremap <silent> <C-c> <Esc>
vnoremap <silent> <C-c> <Esc>
cnoremap <silent> <C-c> <Esc>

" Colon is hard
noremap <CR> :

" It's hard to release shift...

cnoreabbrev W w
cnoreabbrev Wq wq
cnoreabbrev WQ wq
cnoreabbrev Cq wq
cnoreabbrev CQ wq

" Shift-Space is M-Space and Shift-Space is easily mistyped...
inoremap <M-Space> <Space>
