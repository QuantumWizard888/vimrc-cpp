# vimrc for С/C++ programming
These are settings I use in my Vim (console variant) configuration on my Linux system. The goal was to create something that will be convenient, feature complete and will have GUI I'll be glad of. It contains only those options I find practical and most needed. Nothing else. Enjoy programming!

## Requirements
* Latest version of Vim
* Some Nerd compatible font (I use **Adwaita Mono Nerd Font Propo Regular**, you can find nerd fonts [here](https://github.com/ryanoasis/nerd-fonts))
* These plugins:
  - [Language Server Protocol (LSP) plugin for Vim9](https://github.com/yegappan/lsp)
  - [vim-c-cpp-modern: Enhanced C and C++ syntax highlighting](https://github.com/bfrg/vim-c-cpp-modern)
  - [NERDTree](https://github.com/preservim/nerdtree)
  - [Vim-Devicons](https://github.com/ryanoasis/vim-devicons)
  - [vim-nerdtree-syntax-highlight](https://github.com/tiagofumo/vim-nerdtree-syntax-highlight)
* clangd (see how it is Installed in your distribution)

Don't forget to run this command in your Vim after:
```
:PlugInstall
```

## Features
* File tree sidebar
* Icons for different file types in your file tree sidebar (and different colours too!)
* Advanced syntax highlighting for C/C++
* IntelliSense (sort of) for your coding (autocomplete, pop-up window for function definition and etc.)
* Tabs (with button [X] for easy closing)
* Status line which displays number of Errors and Warnings in your current file
* Shortcuts for faster programming:
  - K (go to keyword documentation)
  - gd (go to definition with floating pop-up window near your cursor)
  - gdf (go to definition with opening the file that contains it)
  - gr (go to reference)
  - \rn (smart function and variables renaming)
  - [g, \]g (jump between include/syntax errors)
  - \ca (choose code action for a current line)
  - Tab (for autocomplete selection)
  - F5 (compile and run current source code file)
  - F10 (quick save and exit)
