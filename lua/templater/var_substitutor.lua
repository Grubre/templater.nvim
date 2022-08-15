local config = require("templater.config")
local M = {}

-- RECURSIVE IMPLEMENTATION
M._sub_vars = function(index)
    if index>#config.variable_names then return end
        -- Substitute the variables
    local pattern = config.variable_names[index]
    local func = config.options.variables[pattern]
    if vim.fn.search(pattern)==0 then
        M._sub_vars(index+1)
        return
    end
    local callback_func = function(val)
        vim.api.nvim_command('silent! %s:'..pattern..':'..val..':g')
        M._sub_vars(index+1)
    end
    func(callback_func)
end

-- API FUNCTION
M._substitute_vars = function ()
    -- Get the current cursor position to restore it after the substitutions
    local og_row, og_column = unpack(vim.api.nvim_win_get_cursor(0))

    -- Substitute the variables, starting with the first one
    M._sub_vars(1)

    -- Move the cursor back to it's original position
    vim.api.nvim_win_set_cursor(0, {og_row, og_column})
end

return M
