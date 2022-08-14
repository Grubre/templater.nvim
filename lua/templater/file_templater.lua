local config = require("templater.config")
local file_templater = {}

local keep_blank_lines = function(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

local _use_template = function(chosen_template)
    assert(vim.fn.filereadable(chosen_template)==1, "Template not found")
    local file = assert(io.open(chosen_template, "r"))
    local t = file:read("*a")
    local lines = {}
    for str in keep_blank_lines(t) do
        table.insert(lines, str)
    end
    local og_row, og_column = unpack(vim.api.nvim_win_get_cursor(0))
    vim.fn.append(og_row-1,lines)
    vim.api.nvim_win_set_cursor(0, {og_row, og_column})
    io.close(file)
end

file_templater.add_template = function(file_name)
    local file_path = config.options.file_templates_path
    if file_name==nil then
        vim.ui.input({prompt = "Name of the template"}, function(input)
            vim.cmd('w '..file_path..input)
        end)
    else
        vim.cmd('w '..file_path..file_name)
    end
end

file_templater.use_template = function (file_name)
    local file_path = config.options.file_templates_path
    local chosen_template
    if not (file_name==nil) then
        chosen_template = file_path..file_name
        _use_template(chosen_template)
    else
        -- Get file names in the template folder using ls
        local handle = io.popen('ls '..file_path)
        local result = handle:read("*a")
        handle:close()

        -- Split them into a table
        local files = {}
        for str in string.gmatch(result, "([^".."\n".."]+)") do
            table.insert(files, str)
        end

        vim.ui.select(files, {prompt = "Choose template"}, function(input)
            chosen_template = file_path..input
            _use_template(chosen_template)
        end)
    end
end

file_templater.remove_template = function (file_name)
    local file_path = config.options.file_templates_path
    if file_name==nil then
        vim.ui.input({prompt = "Name of the template to delete"}, function(input)
            vim.cmd('!rm '..file_path..input)
        end)
    else
        vim.cmd('!rm '..file_path..file_name)
    end
end

return file_templater
