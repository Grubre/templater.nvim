--- Var subtitution module
--@module var_substitutor
--@alias M

local config = require("templater.config")
local M = {}

---@public
---Getter for the variables table
---@return table table of variables
M.get_vars = function()
    return config.options.variables
end

-- ######################################################
-- SUBSTITUTE VARS
-- ######################################################

---@private
---@param index integer Index of variable in `variables` table to be substituted
---Substitutes variable #index
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
---@public
---Substitutes variables in current buffer
M.substitute_vars = function ()
    -- Get the current cursor position to restore it after the substitutions
    local og_row, og_column = unpack(vim.api.nvim_win_get_cursor(0))

    -- Substitute the variables, starting with the first one
    M._sub_vars(1)

    -- Move the cursor back to it's original position
    vim.api.nvim_win_set_cursor(0, {og_row, og_column})
end


-- ######################################################
-- ADD VARIABLE
-- ######################################################

---@public
---@param name string name of the variable
---@param func function corresponding function
---Adds a variable
M.add_variable = function(name, func)
    assert(type(name)=="string", "You need to specify the variable name!")
    assert(type(func)=="function", "You need to specify the function! (it takes callback function as a parameter)")
    config.options.variables[name] = func
    table.insert(config.variable_names, name)
end


-- ######################################################
-- REMOVE VARIABLE
-- ######################################################

---@private
---A table of options for the remove_variable function
---@field name the name of variable 
---@table options
local remove_variable_def_opts = {
    name = nil -- name of the variable
}
---@private
---@param name string name of the variable to be removed
---@param opts table table of options
---Removes the variable
local _remove_variable = function(name, opts)
    -- Remove from variables table
    config.options.variables[name] = nil
    -- Remove from variable_names array
    for k,v in ipairs(config.variable_names) do
        if v==name then
            config.variable_names[k] = nil
        end
    end
end
---@public
---@param opts table table of options
---Removes a variable
M.remove_variable = function(opts)
    opts = vim.tbl_deep_extend("force", {}, remove_variable_def_opts, opts or {})
    if opts.name == nil then
        vim.ui.select(config.variable_names,{prompt = "Remove variable"}, function(input)
            if input==nil then return end
            _remove_variable(input,opts)
        end)
    else
        _remove_variable(opts.name)
    end
end

return M
