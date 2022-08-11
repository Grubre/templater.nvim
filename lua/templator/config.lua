local config = {}

local defaults = {

}

config.setup = function(opts)
    config.options = vim.tbl_deep_extend("force", {}, defaults, opts or {}) 
end

return config
