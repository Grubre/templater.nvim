# templater.nvim
## General info
Neovim plugin for creating usable file and variable templates, written in lua.
## Getting started
### Installation
Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'nvim-lua/plenary.nvim'
```

Using [dein](https://github.com/Shougo/dein.vim)

```viml
call dein#add('Grubre/templater.nvim')
```
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'Grubre/templater.nvim',
}
```
### Setup
Somewhere in your config add:
```lua
require("templater").setup({
    ...your opts...
})
```
The default values are:
```lua
local defaults = {
    variables = {}
}
```
## Usage
In order to use the plugin you have to declare your ```["variable"] = substitution``` pairs.\
You can do this by overriding the ```variables``` table in the setup function.\
Then you can use the ```require("templater").sub()``` function or ```:Sub``` command to
substitute all the variables found in the current buffer to their corresponding substitution value. \

### For example:
In your call to the setup function:
```lua
require("templater").setup({
    --Note that variables is a dictionary consisting of ["variable"] = sub pairs
    --where sub is a function that returns a string
    variables = {
        -- You can do it using custom functions 
        ["name"] = function() return "Bob" end,
        -- Or with templater builtin templates
        ["name2"] = require("templater.templates").string("Alice"),
    }
})
```
Then using it on this buffer:
```cpp
name
name2
name
name3
name2
```
Will cause it to turn into:
```cpp
Bob
Alice
Bob
name3
Alice
```
