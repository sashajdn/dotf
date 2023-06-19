""" --- Keanu VIMRC ---

""" --- Leader
	let mapleader =" "

""" --- Plugin Manager Install
	if empty(glob('~/.vim/autoload/plug.vim'))
		silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs 
					\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
	endif

""" --- Plugin Manager
	call plug#begin('~/.vim/plugged')
	" Airline
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	Plug 'airblade/vim-rooter'
	" Highlighting
	Plug 'haya14busa/incsearch.vim' " Vim Tree
	" Code
	Plug 'ervandew/supertab'
	" Fuzzy Finder
	Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': '/.install --all' }
	Plug 'junegunn/fzf.vim'
	" Tree
	Plug 'scrooloose/nerdtree'
	" Text Search
	Plug 'git@github.com:rking/ag.vim.git'
	" Syntax Highlighting
	Plug 'junegunn/goyo.vim'
	Plug 'PotatoesMaster/i3-vim-syntax'
	Plug 'dense-analysis/ale'
	" Golden Ratio
	Plug 'roman/golden-ratio'
	" C/C++
	Plug 'octol/vim-cpp-enhanced-highlight'
	" Go
	Plug 'fatih/vim-go'
	" Node
	Plug 'git@github.com:moll/vim-node.git'
	" Javascript
	Plug 'pangloss/vim-javascript'
	" Typescript
	Plug 'leafgarland/typescript-vim'
	" React
	Plug 'maxmellon/vim-jsx-pretty'
	" Haskell
	Plug 'neovimhaskell/haskell-vim'
	" Python
	Plug 'vim-scripts/indentpython.vim'
	Plug 'kh3phr3n/python-syntax'
	Plug 'psf/black', { 'branch': 'stable' }
	" GraphQL
	Plug 'jparise/vim-graphql'
	" Theme
	Plug 'liuchengxu/space-vim-theme'
	" YCM 
	Plug 'git@github.com:Valloric/YouCompleteMe.git'

	call plug#end()

""" --- Basics
	set nocompatible
	filetype plugin on
	syntax on
	set encoding=utf-8
	set number relativenumber
	set noswapfile
	set cursorline
	autocmd Filetype * setlocal formatoptions-=c formatoptions-=r formatoptions-=o


""" --- Mappings
	vnoremap <leader>p "_dP


""" --- Backups & Undo
	let target_path = expand('~/.vim/dirs/backups')
        if !isdirectory(target_path)
		call system('mkdir -p ' . target_path)
	endif
        let &backupdir = target_path

	if has('persistent_undo')
	    let target_path = expand('~/.vim/dirs/undos')
	    if !isdirectory(target_path)
		call system('mkdir -p ' . target_path)
	endif
	    let &undodir = target_path
	    set undofile
	endif

""" --- Groups
	augroup FrontendGroup
		autocmd!
		autocmd BufNewFile,BufRead *.jsx,*js set filetype=javascript
		autocmd BufNewFile,BufRead *.tsx,*.ts set filetype=typescript
	augroup END


""" --- Vim Specific Keybindings
	nnoremap S :%s//g<Left><Left>
	nnoremap <silent> <Leader>h :split<CR>
	nnoremap <silent> <Leader>v :vsplit<CR>
	nnoremap <silent> <Leader>r :GoldenRatioToggle<CR>
	nnoremap <silent> <Leader>l :call g:ToggleNuMode()<CR>

	vnoremap < <gv
	vnoremap > >gv	

""" --- Autocompletion:
	set wildmode=longest,list,full

""" --- Cursor
	if &term =~ "screen."
	    let &t_ti.="\eP\e[1 q\e\\"
	    let &t_SI.="\eP\e[5 q\e\\"
	    let &t_EI.="\eP\e[1 q\e\\"
	    let &t_te.="\eP\e[0 q\e\\"
	else
	    let &t_ti.="\<Esc>[1 q"
	    let &t_SI.="\<Esc>[5 q"
	    let &t_EI.="\<Esc>[1 q"
	    let &t_te.="\<Esc>[0 q"
	endif

""" --- Scrolling
	set scrolloff=3

""" --- Toggles
	function! g:ToggleNuMode()
		if &nu == 1
			set nonu
			set rnu
		else
			set nornu
			set nu
		endif
	endfunction

""" --- Highlighting
	set hlsearch
	let g:incsearch#auto_nohlsearch = 1
	map /  <Plug>(incsearch-forward)
	map ?  <Plug>(incsearch-backward)
	map g/  <Plug>(incsearch-stay)
	map n  <Plug>(incsearch-nohl-n)
	map N  <Plug>(incsearch-nohl-N)
	map *  <Plug>(incsearch-nohl-*)
	map #  <Plug>(incsearch-nohl-#)
	map g* <Plug>(incsearch-nohl-g*)
	map g# <Plug>(incsearch-nohl-g#)

""" --- Goyo
	noremap <Leader>gy :Goyo \| set linebreak<CR>

""" --- NerdTree
	noremap <Leader>t :NERDTreeToggle<CR>
	nnoremap <silent> <Leader>pv :NERDTreeFind<CR>

""" --- Spell-check
	nnoremap <Leader>o :setlocal spell! spelllang=en_gb<CR>

""" --- Vim Splits
	set splitbelow splitright
	nnoremap <Leader>h :wincmd h<CR>
	nnoremap <Leader>j :wincmd j<CR>
	nnoremap <Leader>k :wincmd k<CR>
	nnoremap <Leader>l :wincmd l<CR>

""" --- Airlines
	let g:airline_powerline_fonts = 1
	let g:airline_theme = 'onedark'
	set noshowmode

""" --- ALE
	highlight ALEWarning ctermbg=DarkMagenta
	let g:ale_completion_enabled = 1
	let g:ale_lint_on_text_changed = 1
	let g:ale_set_highlights = 1
	let g:ale_linters = {
	\	'python': ['pylint', 'flake8', 'isort', 'black', 'mypy'],
	\	'javascript': ['eslint'],
	\	'typescript': ['tsserver', 'tslint'],
	\}
	let g:ale_fixers = {
	\	'python': ['black'],
	\	'javascript': ['eslint'],
	\	'typescript': ['prettier'],
	\	'scss': ['prettier'],
	\	'html': ['prettier'],
	\}

""" --- FZF
	nnoremap <silent> <C-p> <Esc><Esc>:Files!<CR>
	inoremap <silent> <C-p> <Esc><Esc>:BLines!<CR>
	nnoremap <silent> <C-g> <Esc><Esc>:BCommits!<CR>
	let $FZF_DEFAULT_OPTS="--ansi --layout reverse --margin=1,4 --preview 'bat --color=always'"

""" --- YCM
	let g:ycm_autoclose_preview_window_after_completion=1
	noremap <silent> <Leader>gd :YcmCompleter GoToDefinitionElseDeclaration<CR>
	noremap <silent> <Leader>gt :YcmCompleter GoToType<CR>

""" --- Javascript
	autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab

""" --- Typescript
	autocmd FileType typescript setlocal ts=2 sts=2 sw=2 expandtab formatprg=prettier\ --parser\ typescript
 
""" --- Go
	autocmd Filetype go setlocal ts=4 sw=4 sts=4S colorcolumn=99 expandtab

	au FileType go noremap <Leader>b oruntime.Breakpoint()
	au FileType go noremap <Leader>e oif err != nil {}

	let g:go_fmt_command = "goimports"
	let g:go_fmt_fail_silently = 1
	let g:go_fmt_autosave = 0
	let g:go_auto_type_info = 1

""" --- Python
	au FileType python setlocal ts=4 sts=4 sw=4 fileformat=unix colorcolumn=88 autoindent expandtab

	au FileType python noremap <Leader>b oimport ipdb; ipdb.set_trace()
	au FileType python noremap <Leader>c odef __init__(self, *args, **kwargs):

	au Filetype python nnoremap <Leader>f :Black<CR>
	au FileType python set iskeyword-=_

""" --- Embedded / C
	au FileType c setlocal ts=4 sw=4 sts=4 expandtab colorcolumn=80

""" --- Frontend
	autocmd Filetype typescript setlocal ts=2 sw=2 sts=2 expandtab colorcolumn=100
	autocmd Filetype javascript setlocal ts=2 sw=2 sts=2 expandtab colorcolumn=100
	autocmd Filetype html setlocal ts=2 sw=2 sts=2 expandtab colorcolumn=100
	autocmd Filetype css setlocal ts=2 sw=2 sts=2 expandtab colorcolumn=100

""" --- Clipboard
set clipboard=unnamedplus

""" --- Theme
colorscheme space_vim_theme
