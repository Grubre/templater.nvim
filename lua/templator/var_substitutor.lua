local config = require("templator.config")
local M = {}

M._substitute_vars = function ()
    for key,value in pairs(config.options.variables) do
        vim.api.nvim_command('silent! %s:'..key..':'..value..':g')
    end
end

return M
