# templater.nvim
## General info
Neovim plugin for creating file and variable templates, written in lua.
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
The default config values are:
```lua
local defaults = {
    file_templates_path = vim.fn.stdpath("data").."/templater/",
    variables = {}
}
```
## Usage

### File templates
Currently, there are four functions that allow you to interact with the file templates:
|function                                    |description                                             |
|--------------------------------------------|--------------------------------------------------------|
|`require('templater').add_template(opts)`   |Saves the current buffer as a template                  |
|`require('templater').remove_template()opts`|Deletes a saved template                                |
|`require('templater').use_template(opts)`   |Copies selected template under the cursor               |
|`require('templater').get_templates(opts)`  |Returns all availble templates as a table of strings    |

See `:h templater.templates`

### Variables
Variables are `(pattern, function)` pairs. Once you define them (shown below), you can
substitute all `patterns` found in current buffer using `require('templater').sub()`.\
There are two types of variables:

#### Global variables
You can add global variables in your call to the setup function.
```lua
local templates = require("templater.templates")
require("templater").setup({
    --Note that variables is a dictionary consisting of ["variable"] = sub pairs
    --where sub is a function that returns a string
    variables = {
        -- You can use builtin templates:
        -- String:
        -- Simply substitutes all occurences of a given variable to another string
        ["NAME"] = templates.string("Bob"),
        -- Input:
        -- uses vim.ui.input to get the value on the spot
        -- you can pass optional arguments to vim.ui,input
        ["AGE"] = templates.input({prompt = "Pass your age"}),
        -- Select:
        -- uses vim.ui.select
        -- you have to pass a table to select from
        -- also just as above you can pass the optional arguments
        ["FAV_DRINK"] = templates.select({"Coffee", "Tea", "Water"}),
        -- Custom function:
        -- You can also use custom function, it has to take one argument,
        -- a callback function which also takes one argument,
        -- the string to which all occurences are substituted to
        ["FOO"] = function(callback)
            vim.ui.input({prompt = "test"}, function(input)
                local str = ""
                str = "B".."A".."R"
                callback(str)
            end)
        end
    }
})
```
You can also interact with them with `templater.add_variable()` and `templater.remove_variable()`
functions.
#### Local variables
Local variables are defined per file. They are best used in combination with file templates.\
To add local variables, you have to put them between `TEMPLATER_CONFIG` and `TEMPLATER_CONFIG_END`
lines somewhere in your file. You can then specify variables with `VAR(your_var_name)` followed by
corresponding function.
```lua
TEMPLATER_CONFIG
VAR(path)
function(callback)
    callback(vim.fn.expand('%:p'))
end
VAR(another_var)
require('templater.templates').input({prompt = 'new_var'})
TEMPLATER_CONFIG_END
-- The rest of your code...
```
#### Example
You can for example create a template file for competetive programming.\
Global variables:
```lua
VAR(TMP_AUTHOR)
require('temp')
VAR(TMP_DATE)
function(callback)
    callback(os.date("%c"))
end
require("templater").setup({
    variables = {
        ["TMP_CURR_DATETIME"] = templates.string(os.date("%c")),
        ["TMP_PATH"] = templates.string(vim.fn.expand("%:p"))
        ["TMP_AUTHOR"] = templates.string("Bob")
    }
})
```
The file before using `templater.sub()`:
```c++
TEMPLATER_CONFIG
VAR(TMP_PROBLEM_LINK)
require('templater.templates').input({prompt = 'Link'})
TEMPLATER_CONFIG_END
// Author: TMP_AUTHOR
// Date: TMP_DATE
// Problem: TMP_PROBLEM_LINK
#include <bits/stdc++.h>

void f()
{

}

int main()
{
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    int t;
    std::cin >> t;

    while(t-->0)
    {
        f();
    }
    return 0;
}
```
After you use `templater.sub()`, you will be prompted with `vim.ui.input`\
\
![Screenshot_20220824_200150](https://user-images.githubusercontent.com/69735117/186490794-49cc8850-930a-4587-9006-9dad72133221.png) \
After you enter the link, your buffer will look like this:
```C++
// Author: Bob
// Date: wed, 24 aug 2022, 20:08:17 
// Problem: https://codeforces.com/problemset/problem/1720/E
#include <bits/stdc++.h>

void f()
{

}

int main()
{
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    int t;
    std::cin >> t;

    while(t-->0)
    {
        f();
    }
    return 0;
}

```











