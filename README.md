## terminal-image.nvim

Experimental plugin for showing images in neovim terminals using snacks image. Hopefully this plugin will be redundant once [#30889](https://github.com/neovim/neovim/issues/30889) is implemented.

**Note: This plugin relies on [snacks image](https://github.com/folke/snacks.nvim/blob/main/docs/image.md) to display images in neovim terminals. If you can't see images with snacks then this definitely won't work.**


### Installation

See [snacks](https://github.com/folke/snacks.nvim/blob/main/docs/image.md) install instructions for supported terminals.

Install with Lazy

```
{
    "ctorney/terminal-image.nvim",
    opts = {} 
},
```

Currently the only settings are the number of images to keep in the scrollback buffer and whether to automatically scroll to the end of the buffer. The maximum number of mages is set to 10 by default and the autoscroll is set to true meaning that the buffer will scroll to show any images or other outputs if the buffer is not active (main use case is when using a repl plugin like [yarepl.nvim](https://github.com/milanglacier/yarepl.nvim)).

```
opts = { max_num_images = 10, autoscroll = true}
```

### Usage

The plugin will look for lines in any terminal buffer that start with `![terminalimage](path/to/image)` and display the image in the terminal.

A simple way to use this is to create an alias in your shell to echo the markdown for the image:
```
alias nvimage='function _nvimage() { echo "![terminalimage]($(realpath "$1"))"; }; _nvimage'
```

For plotting in python, you can use this with [matplotlib-backend-nvim](https://github.com/ctorney/matplotlib-backend-nvim) to save the image to a temp file and print the markdown to the terminal.


