local file_path = require("templater.config").options.file_templates_path
local file_templater = {}

file_templater.add_template = function(file_name)
    if file_name==nil then
        vim.ui.input({prompt = "Name of the template"}, function(input)
            vim.cmd('w '..file_path..input)
        end)
    else
        vim.cmd('w '..file_path..file_name)
    end
end

file_templater.copy_template = function ()
    
end

file_templater.remove_template = function (file_name)
    if file_name==nil then
        vim.ui.input({prompt = "Name of the template to delete"}, function(input)
            vim.cmd('!rm '..file_path..input)
        end)
    else
        vim.cmd('!rm '..file_path..file_name)
    end
end

return file_templater
