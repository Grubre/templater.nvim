local config = require("templater.config")
local substitutor = require("templater.var_substitutor")
local file_templater = require("templater.file_templater")

local templater = {}

-- SETUP FUNC
templater.setup = config.setup

-- VARIABLES API
templater.sub = substitutor._substitute_vars

-- FILE TEMPLATES API
templater.add_template = file_templater.add_template
templater.use_template = file_templater.use_template
templater.remove_template = file_templater.remove_template

return templater
