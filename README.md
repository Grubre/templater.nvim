# templater.nvim
## General info
Neovim plugin for creating usable file and variable templates, written in lua.
## Getting started
### Installation
Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'Grubre/templater.nvim'
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
    file_templates_path = vim.fn.stdpath("data").."/templater/",
    variables = {}
}
```
## Usage

### File templates
Currently, there are three functions to interact with the file templates:
|function                              |description                                                 |
|--------------------------------------|------------------------------------------------------------|
|require('templater').add_template()   |Saves the current buffer as a template                          |
|require('templater').remove_template()|Deletes a saved template                                    |
|require('templater').use_template()   |Copies contents of a saved template to the current buffer   |

#### Adding templates
With the use ```require("templater").add_template(opt_name)``` you can save the current
buffer as a template. The ```opt_name``` parameter will be used as the name for the template,
if you don't pass any arguments to the function, you will be asked to provide a name using
vim.ui.input.

#### Deleting templates
Similarly to adding templates, by using ```require("templater").remove_template(opt_name)```
you can remove template of name ```opt_name```. If you don't pass any arguments you will be
prompted to choose one with vim.ui.select.

#### Using templates
Just like the previous two functions, you can do ```require("templater").use_template(opt_name)```
to use template of name ```opt_name```. If you don't pass any parameters, you will be asked to
select a template from the list using vim.ui.select. The chosen template gets yanked to the current
buffer, under your cursor.

### Variables
In order to use the plugin you have to declare your ```["variable"] = substitution``` pairs.\
You can do this by overriding the ```variables``` table in the setup function.\
Then you can use the ```require("templater").sub()``` function or ```:Sub``` command to
substitute all the variables found in the current buffer to their corresponding substitution value.

### For example:
In your call to the setup function you can add variables in a following way:
```lua
local templates = require("templater.templates")
require("templater").setup({
    --Note that variables is a dictionary consisting of ["variable"] = sub pairs
    --where sub is a function that returns a string
    variables = {
        -- You can use builtin templates:
        -- String:
        -- Simply substitutes all occurences of a given variable to another string
        ["#NAME#"] = templates.string("Bob"),
        -- Input:
        -- uses vim.ui.input to get the value on the spot
        -- you can pass optional arguments to vim.ui,input
        ["#AGE#"] = templates.input({prompt = "Pass your age"}),
        -- Select:
        -- uses vim.ui.select
        -- you have to pass a table to select from
        -- also just as above you can pass the optional arguments
        ["#FAV_DRINK#"] = templates.select({"Coffee", "Tea", "Water"}),
        -- Custom function:
        -- You can also use custom function, it has to take one argument,
        -- a callback function which also takes one argument,
        -- the string to which all occurences are substituted to
        ["#FOO#"] = function(callback)
            local str = ""
            str = "B".."A".."R"
            callback(str)
        end
    }
})
