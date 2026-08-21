" =====================================
" Performance optimizatons, kinda, yeah
" =====================================

" Reduce buffer scanning and screen redraw overhead
set lazyredraw                  " Do not redraw screen while executing macros/fast typing
set ttyfast                     " Explicitly tell Vim it is running on a fast terminal
set synmaxcol=250               " Do not highlight long code rows beyond 250 characters
" Massively speed up processing of Nerd Font multibyte symbols and icons
set ambiwidth=single

" Force Vim to use cleaner, crisp font grid mapping inside the terminal 
set t_u7=

" Graphics Accelearation for rendering
" Force Vim to use modern compiled regular expression engine (Version 2)
" This massively boosts scrolling speed inside heavy C++ source files
set re=2

" Set a snappy 100ms internal timeout so LSP popups render instantly upon keypress
set updatetime=100

" ===============================
" Basic Vim settings and behavior
" ===============================

set termguicolors	" Without this option NERDTree highlight doesn't work so ENABLE IT
set background=dark	
set number              " show line numbers
set wrap                " wrap lines
set encoding=utf-8	" set encoding to UTF-8 (default was "latin1")
set fileencoding=utf-8
scriptencoding=utf-8
set mouse=a             " enable mouse support (might not work well on Mac OS X)
set showtabline=2	" Forces Vim to ALWAYS show tab panel
set wildmenu            " visual autocomplete for command menu
set wildmode=longest:full,full
set lazyredraw          " redraw screen only when we need to
set showmatch           " highlight matching parentheses / brackets [{()}]
set showcmd
set showmode
set laststatus=2        " always show statusline (even with only single window)
set ruler               " show line and column number of the cursor on right side of statusline
set visualbell          " blink cursor on error, instead of beeping
set cursorline
set nocompatible

" ==============
" Vim Appearance
" ==============

" put colorscheme files in ~/.vim/colors/
colorscheme wildcharm

" use filetype-based syntax highlighting, ftplugins, and indentation
syntax enable
filetype plugin indent on

" ===============================
" Statusline with information
" ===============================
set laststatus=2
set statusline=

" --- LEFT SIDE (Absolute Basics) ---
set statusline+=%F\                             " Full absolute path to the file
set statusline+=%{&modified?'💾\ ':''}         " Safe disc icon if unsaved changes
set statusline+=[%{&ff}]\                       " File format layout (e.g. [unix])
set statusline+=%y                              " File type syntax (e.g. [cpp])

" --- CENTER FOCUS (Live Clangd Statistics) ---
set statusline+=%=                              " Push text strictly to center
set statusline+=%{exists('*lsp#lsp#ErrorCount')&&get(lsp#lsp#ErrorCount(),'Error',0)>0?'❌\ '.lsp#lsp#ErrorCount()['Error'].'\ ':''}
set statusline+=%{exists('*lsp#lsp#ErrorCount')&&get(lsp#lsp#ErrorCount(),'Warn',0)>0?'⚠️\ '.lsp#lsp#ErrorCount()['Warn'].'\ ':''}
set statusline+=%=                              " Push remaining variables to the right

" --- RIGHT SIDE (Cursor Navigation Data) ---
set statusline+=Col:\ %v\                       " Current cursor column number
set statusline+=Ln:\ %l/%L\                     " Current line number / total rows
set statusline+=%p%%                            " Percentage progress through file

" ===================
" Tabulation settings
" ===================

set tabstop=4           " width that a <TAB> character displays as
set expandtab           " convert <TAB> key-presses to spaces
set shiftwidth=4        " number of spaces to use for each step of (auto)indent
set softtabstop=4       " backspace after pressing <TAB> will remove up to this many spaces

set autoindent          " copy indent from current line when starting a new line
set smartindent         " even better autoindent (e.g. add indent after '{')

" ===============
" Search settings
" ===============

set incsearch           " search as characters are entered
set hlsearch            " highlight matches

" =================
" NERDTree Settings
" =================

" Start NERDTree and put the cursor back in the other window.
autocmd VimEnter * NERDTree | wincmd p

" Open the existing NERDTree on each new tab.
autocmd BufWinEnter * if &buftype != 'quickfix' && getcmdwintype() == '' | silent NERDTreeMirror | endif

" Automatically opens new tab whenenver user clicks some file in NERDTree
let g:NERDTreeCustomOpenArgs = {'file': {'where': 't', 'keepopen': 1}}

" Update NERDTree after focus change or buffer
let g:NERDTreeAutoDeleteBuffer = 1

" Re-calculate files tree after changes in directory
let g:NERDTreeNotificationThreshold = 100

" Vim autoread files after their changes commited
set autoread

" ==================================================================
" Autoocomplete and Language server settings (yegappan/lsp + CLANGD)
" ==================================================================

" Configure correct built-in completion popups flags (No insert before select)
set completeopt=menuone,noinsert,noselect
" Enable secondary documentation window inside completion popup menu
set completeopt+=popup

" Smart configuration function wrapper to prevent runtime errors
function! s:SetupMyLanguageServers() abort
    " Clean and official options for yegappan/lsp signature popups, IntelliSense, documentation and etc
    let lspOpts = #{
        \   autoHighlightDiags: v:true,
        \   showDiagOnHover: v:true,
        \   showDiagInBalloon: v:true,
        \   echoDiagMessage: v:true,
        \   useBufferDiagnostics: v:true,
        \   snippetSupport: v:true,
        \   autoComplete: v:true,
        \   showSignature: v:true
        \ }
    call lsp#options#OptionsSet(lspOpts)

    " Register clangd with standard system flags
    let lspServers = [#{
        \    name: 'clangd',
        \    filetype: ['c', 'cpp'],
        \    path: '/usr/bin/clangd',
        \    args: [
        \      '--background-index',
        \      '--completion-style=detailed',
        \      '--header-insertion=iwyu',
        \      '--header-insertion-decorators',
        \      '--function-arg-placeholders',
        \      '--limit-results=100',
        \      '--clang-tidy'
        \    ]
        \  }]
    call lsp#lsp#AddServer(lspServers)
endfunction

" Hook into yegappan/lsp initialization sequence safely
augroup LspInitializationFix
    autocmd!
    autocmd User LspSetup call s:SetupMyLanguageServers()
augroup END

" Press Ctrl+s in Insert mode to forcefully toggle signature help popup inside brackets
inoremap <silent> <C-s> <Cmd>LspShowSignature<CR>

" Map keybindings to jump between include/syntax errors
nmap <silent> [g <Cmd>LspDiag prev<CR>
nmap <silent> ]g <Cmd>LspDiag next<CR>
nmap <silent> <leader>ca <Cmd>LspCodeAction<CR>

" gd: Open your preferred floating popup window with the actual file code
nnoremap <silent> gd :LspPeekDefinition<CR>

" gdf: Go to the actual source file definition and open it inside a clean new tab page
nnoremap <silent> gdf :tab split \| LspGotoDefinition<CR>

" Advanced LSP Navigation and Refactoring: Show Hover Info (Show function signature and documentation in a mini-window)
nmap <silent> K :LspHover<CR>

" Advanced LSP Navigation and Refactoring: Find References (Show where this symbol is used in your project)
nmap <silent> gr :LspPeekReferences<CR>

" Advanced LSP Navigation and Refactoring: Rename Symbol (Smart variable or function renaming across the entire project)
nmap <silent> <leader>rn :LspRename<CR>

" Use Tab to confirm autocomplete selection (simulates Ctrl-Y)
inoremap <expr> <Tab> pumvisible() ? "\<C-y>" : "\<Tab>"

" VIM-C-CPP-MODERN plugin settings
let g:cpp_attributes_highlight = 1     " Highlight [[attributes]]
let g:cpp_member_highlight = 1         " Highlight members of structure/class 
let g:cpp_simple_highlight = 0         " Turn off simple mode for maximum colours

" =========================================
" Plugins management section using Vim-Plug
" =========================================

call plug#begin('~/.vim/plugged')
  Plug 'yegappan/lsp'
  Plug 'bfrg/vim-c-cpp-modern'
  Plug 'preservim/nerdtree'
  Plug 'ryanoasis/vim-devicons'
  Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
call plug#end()

" =======================
" Vim dev-icons settings
" =======================

if !exists('g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols')
    let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {}
endif

let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['txt']  = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['gpg']  = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['png']  = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['jpeg'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['jpg']  = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['zip']  = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['tar']  = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['bz2']  = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['gz']   = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['rar']  = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['7z']   = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['pdf']  = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['djvu'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['epub'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['doc']  = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['docx'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['xls']  = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['xlsx'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['ppt']  = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['pptx'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['so']   = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['asm']  = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['s']    = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['o']    = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['mp3']  = nr2char(0xf0388)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['wav']  = nr2char(0xf0388)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['flac'] = nr2char(0xf0388)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['mp4']  = nr2char(0xf022b)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['mkv']  = nr2char(0xf022b)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['m3u']  = nr2char(0xf0411)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['m3u8'] = nr2char(0xf0411)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['srt']  = nr2char(0xf0171)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['ass']  = nr2char(0xf0171)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['cue']  = nr2char(0xf05ca)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['nfo']  = nr2char(0xf05a)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['info'] = nr2char(0xf05a)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['bin']  = nr2char(0xf120)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['elf']  = nr2char(0xf018d)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['run']  = nr2char(0xf018d)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['obj']   = nr2char(0xf0b84)
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['blend'] = nr2char(0xf0b84)

" =====================================================
" NERDTree syntax highlight using Vim devicons settings
" =====================================================

let g:WebDevIconsDisableDefaultFolderSymbolColorFromNERDTreeDir = 1
let g:WebDevIconsDisableDefaultFileSymbolColorFromNERDTreeFile = 1

let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1

let g:NERDTreeHighlightFolders = 1 " enables folder icon highlighting using exact match
let g:NERDTreeHighlightFoldersFullName = 1 " highlights the folder name

" NERDTree highlight dictionary init
if !exists('g:NERDTreeExtensionHighlightColor')
    let g:NERDTreeExtensionHighlightColor = {}
endif

" Text and Info files
let g:NERDTreeExtensionHighlightColor['txt']   = '808080'
let g:NERDTreeExtensionHighlightColor['nfo']   = '808080'
let g:NERDTreeExtensionHighlightColor['info']  = '808080'

" Cryptography keys
let g:NERDTreeExtensionHighlightColor['gpg']   = 'FF0000'

" Images
let g:NERDTreeExtensionHighlightColor['png']   = 'FF00FF'
let g:NERDTreeExtensionHighlightColor['jpeg']  = 'FF00FF'
let g:NERDTreeExtensionHighlightColor['jpg']   = 'FF00FF'

" Archives
let g:NERDTreeExtensionHighlightColor['zip']   = 'FFFF00'
let g:NERDTreeExtensionHighlightColor['tar']   = 'FFFF00'
let g:NERDTreeExtensionHighlightColor['bz2']  = 'FFFF00'
let g:NERDTreeExtensionHighlightColor['gz']    = 'FFFF00'
let g:NERDTreeExtensionHighlightColor['rar']   = 'FFFF00'
let g:NERDTreeExtensionHighlightColor['7z']    = 'FFFF00'

" Documents and Books
let g:NERDTreeExtensionHighlightColor['pdf']   = '8B0000'
let g:NERDTreeExtensionHighlightColor['djvu']  = '006400'
let g:NERDTreeExtensionHighlightColor['epub']  = '00FF00'
let g:NERDTreeExtensionHighlightColor['doc']   = '0000FF'
let g:NERDTreeExtensionHighlightColor['docx']  = '0000FF'
let g:NERDTreeExtensionHighlightColor['xls']   = '006400'
let g:NERDTreeExtensionHighlightColor['xlsx']  = '006400'
let g:NERDTreeExtensionHighlightColor['ppt']   = 'FF8C00'
let g:NERDTreeExtensionHighlightColor['pptx']  = 'FF8C00'

" Assembly, object files, libraries
let g:NERDTreeExtensionHighlightColor['so']    = '00FFFF'
let g:NERDTreeExtensionHighlightColor['asm']   = '00BFFF'
let g:NERDTreeExtensionHighlightColor['s']     = '00BFFF'
let g:NERDTreeExtensionHighlightColor['o']     = '4F4F4F'

" Multimedia: Audio and Tags
let g:NERDTreeExtensionHighlightColor['mp3']   = '00FF00'
let g:NERDTreeExtensionHighlightColor['wav']   = '00FF00'
let g:NERDTreeExtensionHighlightColor['flac']  = '00FF00'
let g:NERDTreeExtensionHighlightColor['cue']   = 'BA55D3'

" Multimedia: Video and Playlists
let g:NERDTreeExtensionHighlightColor['mp4']   = 'BA55D3'
let g:NERDTreeExtensionHighlightColor['mkv']   = 'BA55D3'
let g:NERDTreeExtensionHighlightColor['m3u']   = 'FF00FF'
let g:NERDTreeExtensionHighlightColor['m3u8']  = 'FF00FF'

" Subtitles
let g:NERDTreeExtensionHighlightColor['srt']   = '808080'
let g:NERDTreeExtensionHighlightColor['ass']   = '808080'

" Executables
let g:NERDTreeExtensionHighlightColor['bin']   = '00FF00'
let g:NERDTreeExtensionHighlightColor['elf']   = '00FF00'
let g:NERDTreeExtensionHighlightColor['run']   = '00FF00'

" 3D
let g:NERDTreeExtensionHighlightColor['obj']   = 'FF8C00'
let g:NERDTreeExtensionHighlightColor['blend'] = 'FF8C00'

" ==============================================================================================================
" This section enables real time NERDTree window update (create files or folders -> instantly shows in NERDTree)
" ==============================================================================================================

function! s:RefreshNERDTreeLive()
    " Check if NERDTree is opened in a current tab
    if exists('t:NERDTreeBufName') && bufwinnr(t:NERDTreeBufName) != -1
        let l:current_winnr = winnr()
        let l:nerd_winnr = bufwinnr(t:NERDTreeBufName)
        
        " Instantly switch to the NERDTree window WITHOUT triggering unnecessary autocommands
        noautocmd execute l:nerd_winnr . 'wincmd w'
        
        " Update the root and force a redraw of the NEDRTree interface
        try
            call b:NERDTree.root.refresh()
            call b:NERDTree.render()
        catch
        endtry
        
        " Also instantly return the cursor to your code window
        noautocmd execute l:current_winnr . 'wincmd w'
        
        " Force Vim to redraw the entire terminal screen
        redraw!
    endif
endfunction

" Autocmd ommands for automatic disk scanning
augroup NERDTreeRealTimeRefresh
    autocmd!
    " If returning to the terminal window from an external file manager
    autocmd FocusGained * checktime | call s:RefreshNERDTreeLive()
    " If saving or creating files in Vim
    autocmd BufWritePost,BufEnter * call s:RefreshNERDTreeLive()
augroup END

" ===================================================
" ADVANCED and much more user friendly Tab line panel
" ===================================================

function! CustomTabLine()
    let l:s = ''
    
    " Loop through all open tab pages
    for l:i in range(1, tabpagenr('$'))
        " Set highlighting group for active vs background tabs
        if l:i == tabpagenr()
            let l:s .= '%#TabLineSel#'
        else
            let l:s .= '%#TabLine#'
        endif

        " Set tab page number for mouse click tracking on the label text
        let l:s .= '%' . l:i . 'T'
        let l:s .= ' ' . l:i . ': '

        " --- LOGIC TO EXTRACT THE ACTUAL EDITING FILENAME ---
        let l:buflist = tabpagebuflist(l:i)
        let l:final_name = ''

        " Scan windows sequentially inside the current tab page
        for l:bufnr in l:buflist
            let l:bname = bufname(l:bufnr)
            " Skip empty buffers and NERDTree workspace views
            if l:bname != '' && l:bname !~# 'NERD_tree_'
                let l:final_name = fnamemodify(l:bname, ':t')
                break " Found actual file buffer, break window loop
            endif
        endfor

        " Fallback if the tab contains only a NERDTree buffer or an empty view
        if l:final_name == ''
            if len(l:buflist) > 0 && bufname(l:buflist[0]) =~# 'NERD_tree_'
                let l:final_name = 'NERDTree'
            else
                let l:final_name = '[No Name]'
            endif
        endif

        " Render extracted filename to the bar layout strings
        let l:s .= l:final_name . ' '

        " RENDER CLICKABLE CLOSING ICON (%X opens tracking zone, %x terminates it)
        let l:s .= '%' . l:i . 'X[x]%x '
    endfor

    " Complete remaining alignment filling spaces 
    let l:s .= '%#TabLineFill#%T'
    return l:s
endfunction

" Activate Custom Tab Line System 
set tabline=%!CustomTabLine()

" =================================================================
" NERDTree mouse event hooks (Smart single-click navigation rules)
" =================================================================

let g:NERDTreeMouseMode = 1

function! s:NERDTreeMouseOpenInTab(node)
    " EMPTY SPACE PATCH: Abort execution if mouse click drops onto empty margins
    if !exists('g:NERDTreeFileNode')
        return
    endif
    
    let l:current_node = g:NERDTreeFileNode.GetSelected()
    if empty(l:current_node) || empty(a:node) || l:current_node.path.str() != a:node.path.str()
        return
    endif

    " Verify action targeting node is a standard source file, not a workspace directory
    if !a:node.path.isDirectory
        let l:target_path = a:node.path.str()
        let l:found_tab = 0

        " Iterate across all open tabs to check if target file is already loaded
        for l:t in range(1, tabpagenr('$'))
            let l:buflist = tabpagebuflist(l:t)
            for l:bufnr in l:buflist
                " Extract absolute path string properties from buffer index 
                let l:buf_path = fnamemodify(bufname(l:bufnr), ':p')
                
                " Swap focus to pre-existing tab index if absolute paths match perfectly
                if l:buf_path == fnamemodify(l:target_path, ':p')
                    execute 'tabnext' l:t
                    let l:found_tab = 1
                    break
                endif
            endfor
            if l:found_tab | break | endif
        endfor

        " Fallback: Initialize an isolated new tab split if target doesn't exist
        if !l:found_tab
            call a:node.open({'where': 't', 'keepopen': 1})
        endif
    endif
endfunction

function! s:RegisterNERDTreeMouseHook()
    " Safely verify that target internal plug interface function is present in memory
    if exists('*NERDTreeAddKeyMap')
        call NERDTreeAddKeyMap({
            \ 'key': '<LeftRelease>',
            \ 'scope': 'FileNode',
            \ 'callback': function('s:NERDTreeMouseOpenInTab'),
            \ 'quickhelp': 'Open file in new tab with mouse click'
            \ })
    endif
endfunction

" EXPLICIT HOOK RULE: Inject event handlers safely right after plugin compilation completes
augroup NERDTreeMouseFix
    autocmd!
    autocmd VimEnter * call s:RegisterNERDTreeMouseHook()
augroup END


" =================================================================================
" This section will activate Vim exit if either NERDTree or main window were closed
" =================================================================================

augroup NERDTreeTimerClose
    autocmd!

    " CASE 1: Close window and only NERDTree window is left -> Close Vim
    autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

    " CASE 2: If NERDTree window is closed, wait 1 ms and check
    " If only one window is left -> Close Vim.
    autocmd WinLeave * if exists('b:NERDTree') | call timer_start(1, {-> s:CheckIfOnlyOneWindowLeft()}) | endif
augroup END

function! s:CheckIfOnlyOneWindowLeft()
    " If after NERDTree window closed only one window left and it's not other NERDTree
    if tabpagenr('$') == 1 && winnr('$') == 1
        quit
    endif
endfunction

" ==================================================
" Compile and Run C/C++ source code files inside Vim
" ==================================================

function! CompileAndRun() abort
    " Save the current buffer automatically before building
    write

    " Extract relative file parameters from the active buffer using core VimScript
    let l:file_name = expand('%:t')         " Just the filename (e.g., 'kernel_module.c')
    let l:file_ext  = expand('%:e')         " File extension (e.g., 'c' or 'cpp')
    let l:file_dir  = expand('%:p:h')      " Directory containing the source file

    " Find the index of the last dot in the filename to isolate the binary name
    let l:dot_index = strridx(l:file_name, '.')
    
    if l:dot_index > 0
        " Slice the string from character 0 up to the last dot index
        let l:exec_name = strpart(l:file_name, 0, l:dot_index)
    else
        " Fallback if the file somehow has no extension at all
        let l:exec_name = l:file_name . '.out'
    endif

    " Select compiler with -Wpedantic, -O3, and FORCE FULL COLOR OUTPUT ENABLED
    if l:file_ext ==# 'c'
        let l:compiler = 'gcc -Wall -Wextra -Wpedantic -fdiagnostics-color=always -O3 -std=c11'
    elseif l:file_ext ==# 'cpp'
        let l:compiler = 'g++ -Wall -Wextra -Wpedantic -fdiagnostics-color=always -O3 -std=c++20'
    else
        echo 'Error: Active buffer extension ("' . l:file_ext . '") is not supported for C/C++ compilation!'
        return
    endif

    " Construct a completely flat shell command string using safe local naming
    let l:run_cmd = 'cd ''' . l:file_dir . ''' && ' . l:compiler . ' ''' . l:file_name . ''' -o ''' . l:exec_name . ''' && ./''' . l:exec_name . ''''

    " STRICT FOCUS STEP 1: Lock the exact window number where your source code is currently open
    let l:code_winnr = winnr()

    " SINGLE WINDOW FIX: Scan all open windows to find and close the old terminal
    for l:w in range(winnr('$'), 1, -1)
        let l:buf = winbufnr(l:w)
        if getbufvar(l:buf, '&buftype') ==# 'terminal'
            execute l:w . 'wincmd c'
            " If the terminal window was closed BEFORE our code window index,
            " adjust our target code window pointer index accordingly
            if l:w < l:code_winnr
                let l:code_winnr -= 1
            endif
        endif
    endfor

    " Launch a single clean terminal split window at the very bottom
    execute 'botright terminal ++rows=10 ++shell ' . l:run_cmd

    " STRICT FOCUS STEP 2: Forcefully jump directly back to the saved code window index
    " This bypasses wincmd p history and completely ignores NERDTree
    noautocmd execute l:code_winnr . 'wincmd w'
endfunction

" Classic F5 Mapping (Using the new global function signature)
nnoremap <silent> <F5> :call CompileAndRun()<CR>

" ==================================================================
" Interactive Close Mouse Button [X] for the Terminal Output Window
" ==================================================================

function! CloseCurrentTerminalWindow() abort
    " Scan all current windows from bottom to top
    for l:w in range(winnr('$'), 1, -1)
        " Locate the interactive terminal output viewport buffer
        if getbufvar(winbufnr(l:w), '&buftype') ==# 'terminal'
            " Forcefully close the terminal window layout instantly
            execute l:w . 'wincmd c'
            break
        endif
    endfor
endfunction

" HOOK: Render an isolated clickable button on the window's top banner bar
augroup TerminalMouseCloseClean
    autocmd!
    " The special '.Text' syntax creates a clean button pushed to the right side
    autocmd TerminalOpen * amenu <silent> WinBar.\[X] :call CloseCurrentTerminalWindow()<CR>
augroup END

" ==============================================================
" Fast Vim exit (save ALL OPEN FILES and FORCE CLOSE Vim)
" ==============================================================

" Press F10 to save every modified buffer and instantly terminate Vim session
nnoremap <silent> <F10> :wqa!<CR>