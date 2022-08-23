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
-- SUBSTITUTE VARS
-- ######################################################

---@private
---A table of options for the substitute_vars function
---@field use_local_vars whether to use local variables 
---@field delete_local_templater_config whether local templater config should be deleted from buffer 
---@table sub_vars_options
local sub_vars_def_opts = {
    use_local_vars = true,
    delete_local_templater_config = true
}
---Adds local variables to global table
---@private
M.add_local_vars = function()
    local open, close = vim.fn.search('\\<TEMPLATER_CONFIG\\>'), vim.fn.search('\\<TEMPLATER_CONFIG_END\\>')

    local lines = vim.api.nvim_buf_get_lines(0,open,close,false)
    local variables = {}
    local funcs = {}
    local curr_func = ""
    for nr,line in ipairs(lines) do
        if line:match("VAR(.*)") or nr==#lines then
            if curr_func ~= "" then
                table.insert(funcs, curr_func)
                curr_func = ""
            end
            table.insert(variables, line:sub(5,#line-1))
        else
            curr_func=curr_func..' '..line
        end
    end

    for i = 1,#funcs do
        M.add_variable(variables[i], vim.fn.luaeval(funcs[i]))
    end

        
    return open, close
end
---@private
---@param index integer Index of variable in `variables` table to be substituted
---Substitutes variable #index
local function sub_vars(index)
    if index>#config.variable_names then return end
        -- Substitute the variables
    local pattern = config.variable_names[index]
    local func = config.options.variables[pattern]
    if vim.fn.search(pattern)==0 then
        sub_vars(index+1)
        return
    end
    local callback_func = function(val)
        vim.api.nvim_command('silent! %s:'..pattern..':'..val..':g')
        sub_vars(index+1)
    end
    func(callback_func)
end
---Substitutes variables in current buffer
---@param opts table table of options
---@public
M.substitute_vars = function (opts)
    opts = vim.tbl_deep_extend("force", {}, sub_vars_def_opts, opts or {})
    -- Get the current cursor position to restore it after the substitutions
    local og_row, og_column = unpack(vim.api.nvim_win_get_cursor(0))

    -- Create a backup of variables before adding the locals
    local t_vars = config.options.variables

    if opts.use_local_vars then
        local open, close = M.add_local_vars()
        if opts.delete_local_templater_config and open~=0 and close~=0 then
            vim.api.nvim_buf_set_lines(0,open-1,close,false,{})
        end
    end
    -- Substitute the variables, starting with the first one
    sub_vars(1)

    config.options.variables = t_vars
    -- Move the cursor back to it's original position
    vim.api.nvim_win_set_cursor(0, {math.min(og_row,vim.api.nvim_buf_line_count(0)), og_column})
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
        _remove_variable(opts.name, opts)
    end
end

return M
