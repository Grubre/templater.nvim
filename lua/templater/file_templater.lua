local file_path = require("templater.config").options.file_templates_path
local file_templater = {}

file_templater.add_template = function()
    vim.ui.input({prompt = "Name of the template"}, function(input)
        vim.cmd('w '..file_path..input)
    end)
    -- print(file_path)
    -- local file = io.open(file_path..file_name, "w")
end

file_templater.copy_template = function ()
    
end

file_templater.remove_template = function ()
    
end

return file_templater
