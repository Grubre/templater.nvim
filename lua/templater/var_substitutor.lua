local config = require("templater.config")
local M = {}

M._substitute_vars = function ()
    -- Get the current cursor position to restore it after the substitutions
    local og_row, og_column = unpack(vim.api.nvim_win_get_cursor(0))

    -- Substitute the variables
    for pattern,func in pairs(config.options.variables) do
        vim.api.nvim_command('silent! %s:\\<'..pattern..'\\>:'..func()..':g')
    end

    -- Move the cursor back to it's original position
    vim.api.nvim_win_set_cursor(0, {og_row, og_column})
end

return M
