---Config module
---@module config
---@alias config
local config = {}

---@private
---@table defaults
---@field file_templates_path path where templater will be stored
---@field variables table a table of variables
local defaults = {
    file_templates_path = vim.fn.stdpath("data").."/templater/",
    variables = {},
}

---@private
---@param opts table user options
---sets the options table
config.setup = function(opts)
    config.options = vim.tbl_deep_extend("force", {}, defaults, opts or {}) 
    config.variable_names = {}
    for k in pairs(config.options.variables) do
        config.variable_names[#config.variable_names+1] = k
    end
    if vim.fn.isdirectory(defaults.file_templates_path)==0 then
        vim.fn.mkdir(defaults.file_templates_path, "")
    end
end

return config
