local substitutor = require("templater.var_substitutor")
local config = require("templater.config")

local templator = {}

templator.setup = config.setup
templator.sub = substitutor._substitute_vars

return templator 
