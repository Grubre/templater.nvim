local config = require("templater.config")
local substitutor = require("templater.var_substitutor")
local file_templater = require("templater.file_templater")

local templater = {}

---@public
---@param opts table user options
---sets the options table and api functions
templater.setup = function(opts)
    config.setup(opts)
    -- VARIABLES API
    templater.sub = substitutor.substitute_vars
    templater.add_variable = substitutor.add_variable
    templater.remove_variable = substitutor.remove_variable
    templater.get_variables = substitutor.get_vars

    -- FILE TEMPLATES API
    templater.add_template = file_templater.add_template
    templater.use_template = file_templater.use_template
    templater.remove_template = file_templater.remove_template
    templater.get_templates = file_templater.get_templates
end

return templater
