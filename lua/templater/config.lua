local config = {}

local defaults = {
    file_templates_path = vim.fn.stdpath("data").."/templater/",
    variables = {},
}

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
