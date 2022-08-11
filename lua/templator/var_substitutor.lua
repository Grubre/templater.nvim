local M = {}

local variables = {}
variables["NAME"] = "jabuk"
variables["TEST"] = "test abc"

M.variables = variables

M._substitute_vars = function ()
    for key,value in pairs(variables) do
        vim.api.nvim_command('%s:'..key..':'..value..':g')
    end
end

return M
