local substitutor = require("templator.var_substitutor")
local config = require("templator.config")

local templator = {}

templator.setup = config.setup
templator.sub = substitutor._substitute_vars

return templator 
