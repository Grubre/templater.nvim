--- Templates module
--@module file_templater
--@alias file_templater
local config = require("templater.config")
local file_templater = {}


---Keeps the blank lines when yanking contents from a file
---@private
---@tparam string s string to be parsed
local keep_blank_lines = function(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

---Getter for templates saved in config.options.file_templates_path directory
---@public
---@treturn table templates table of names of existing templates
file_templater.get_templates = function()
    -- Get file names in the template folder using ls
    local handle = io.popen('ls '..config.options.file_templates_path)
    local result = handle:read("*a")
    handle:close()

    -- Split them into a table
    local templates = {}
    for str in string.gmatch(result, "([^".."\n".."]+)") do
        table.insert(templates, str)
    end
    return templates
end



-- ######################################################
-- ADD_TEMPLATE
-- ######################################################

---A table of options for the add_template function
---@table add_opts
---@field name the name of a template
---@field overwrite Possible overwrite values -> {
---        'yes' - overwrites the file without asking,
---        'prompt' - opens a prompt asking whether to overwrite,
---        'no' - doesn't overwrite,
---   }
local add_template_def_opts = {name = nil, overwrite = "no"}

---Adds a template
---@private
---@tparam string name name of the template
---@tparam table opts passed options
local _add_template = function(name, opts)
    local file_path = config.options.file_templates_path
    if opts.overwrite == 'prompt' and vim.fn.filereadable(file_path..name) then
        vim.ui.select({'yes','no'}, {prompt='Overwrite file?'}, function(input)
            if input=='yes' then
                vim.cmd('w! '..file_path..name)
            end
        end)
    elseif opts.overwrite == 'yes' then
        vim.cmd('w! '..file_path..name)
    else -- if no overwrite or prompt and file doesnt exist
        vim.cmd('w '..file_path..name)
    end
end

---Adds a template
---@public
---@tparam table opts table of options
---@see add_opts
file_templater.add_template = function(opts)
    opts = vim.tbl_deep_extend("force", {}, add_template_def_opts, opts or {})
    if opts.name==nil then
        vim.ui.input({prompt = "Name of the template"}, function(input)
            if input==nil then return end
            _add_template(input,opts)
        end)
    else
        _add_template(opts.name,opts)
    end
end


-- ######################################################
-- USE_TEMPLATE
-- ######################################################

---Pastes a template under cursor
---@private
---@tparam string name of the template
---@tparam table opts table of options
local _use_template

---A table of options for the use_template function
---@private
---@table use_opts
---@field name the name of the template
local use_template_def_opts = {name = nil}

---Pastes a template under cursor
---@public
---@tparam table opts table of options
file_templater.use_template = function (opts)
    opts = vim.tbl_deep_extend("force", {}, use_template_def_opts, opts or {})
    if not (opts.name==nil) then
        _use_template(opts.name, opts)
    else
        vim.ui.select(file_templater.get_templates(), {prompt = "Choose template"}, function(input)
            if input==nil then return end
            _use_template(input, opts)
        end)
    end
end

_use_template = function(name, opts)
    local chosen_template = config.options.file_templates_path..name
    assert(vim.fn.filereadable(chosen_template)~=0, "Template not found!")
    -- Read the file
    local file = assert(io.open(chosen_template, "r"), "Error while trying to read the template!")
    local contents = file:read("*a")
    local lines = {}
    for str in keep_blank_lines(contents) do
        table.insert(lines, str)
    end

    local og_row, og_column = unpack(vim.api.nvim_win_get_cursor(0))
    vim.fn.append(og_row-1,lines)
    vim.api.nvim_win_set_cursor(0, {og_row, og_column})
    io.close(file)
end


-- ######################################################
-- REMOVE_TEMPLATE
-- ######################################################

---A table of options for the remove_template function
---@private
---@table remove_opts
---@field name string the name of the template
local remove_template_def_opts = {name = nil}
---removes a template
---@private
---@tparam string name name of the template
---@tparam table opts table of options
local _remove_template = function (name, opts)
    local file_path = config.options.file_templates_path
    assert(vim.fn.filereadable(file_path..name)~=0, "Template "..name.. " doesn't exist!")
    vim.cmd('silent !rm '..file_path..name)
end
---Deletes a template file
---@public
---@tparam table opts table of options
file_templater.remove_template = function (opts)
    opts = vim.tbl_deep_extend("force", {}, remove_template_def_opts, opts or {})
    local templates = file_templater.get_templates()
    if opts.name==nil then
        vim.ui.select(templates, {prompt = "Delete template"}, function(input)
            if input==nil then return end
            _remove_template(input,opts)
        end)
    else
        _remove_template(opts.name,opts)
    end
end


return file_templater
