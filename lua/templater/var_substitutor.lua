local config = require("templater.config")
local M = {}

local escape_problematic_chars = function(str)
    return str:gsub("%W", {
        ["#"] = "\\#",
        ["("] = "\\(",
        [")"] = "\\)",
        ["]"] = "\\]",
        ["["] = "\\[",
        ["{"] = "\\{",
        ["}"] = "\\}",
    })
end

M._substitute_vars = function ()
    -- Get the current cursor position to restore it after the substitutions
    local og_row, og_column = unpack(vim.api.nvim_win_get_cursor(0))

    -- Substitute the variables
    for pattern,func in pairs(config.options.variables) do
        local escaped_pattern = escape_problematic_chars(pattern)
        if vim.fn.search(pattern)==0 then
            goto continue
        end
        print(pattern)
        local callback_func = function(val)
            vim.api.nvim_command('silent! %s:\\<'..escaped_pattern..'\\>:'..val..':g')
        end
        func(callback_func)
        ::continue::
    end

    -- Move the cursor back to it's original position
    vim.api.nvim_win_set_cursor(0, {og_row, og_column})
end

return M
