## terminal-image.nvim

Experimental small plugin for showing images in neovim terminals using snacks image.

**Note: This plugin relies on (snacks image)[https://github.com/folke/snacks.nvim/blob/main/docs/image.md] to display images in neovim terminals. If you can't see images with snacks then this definitely won't work.**

### Installation

See (snacks image)[https://github.com/folke/snacks.nvim/blob/main/docs/image.md] for supported terminals.

Install with Lazy

```
{
    "ctorney/terminal-image.nvim",
    config = true,
},
```

### Usage

The plugin will look for lines in any terminal buffer that start with `![terminalimage](path/to/image)` and display the image in the terminal.

A simple way to use this is to create an alias in your shell to echo the markdown for the image:
```
alias nvimage='function _nvimage() { echo "![terminalimage]($(realpath "$1"))"; }; _nvimage'
```
