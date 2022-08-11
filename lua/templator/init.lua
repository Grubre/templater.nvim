local templator = {}

local substitutor = require("templator.var_substitutor")

templator.sub = function() substitutor._substitute_vars() end

return templator 
