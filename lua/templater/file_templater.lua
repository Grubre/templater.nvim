local config = require("templater.config")
local file_templater = {}


-- Helper function to keep the blank lines when yanking contents from a file
local keep_blank_lines = function(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end


-- Returns all the templates saved in config.options.file_templates_path directory
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
-- Public function that adds a template
-- A table of options for the add_template function
-- file_name -> str: the name of the template
-- overwrite ->  {
    --              'yes' - overwrites the file without asking
    --              'prompt' - opens a prompt asking whether to overwrite
    --              'no' - doesn't overwrite
    --          }
local add_template_def_opts = {file_name = nil, overwrite = "no"}

local _add_template = function(file_name, opts)
    local file_path = config.options.file_templates_path
    if opts.overwrite == 'prompt' and vim.fn.filereadable(file_path..file_name) then
        vim.ui.select({'yes','no'}, {prompt='Overwrite file?'}, function(input)
            if input=='yes' then
                vim.cmd('w! '..file_path..file_name)
            end
        end)
    elseif opts.overwrite == 'yes' then
        vim.cmd('w! '..file_path..file_name)
    else -- if no overwrite or prompt and file doesnt exist
        vim.cmd('w '..file_path..file_name)
    end
end

file_templater.add_template = function(opts)
    opts = vim.tbl_deep_extend("force", {}, add_template_def_opts, opts or {})
    if opts.file_name==nil then
        vim.ui.input({prompt = "Name of the template"}, function(input)
            _add_template(input,opts)
        end)
    else
        _add_template(opts.file_name,opts)
    end
end


-- ######################################################
-- USE_TEMPLATE
-- ######################################################
-- Forward declare
local _use_template
-- A table of options for the use_template function
-- file_name -> str: the name of the file
-- buf_type -> str: {
    --                  'e' - create new buffer,
    --                  'v' - use vsplit,
    --                  's' - use split,
    --                  otherwise - use current buffer
                -- }
local use_template_def_opts = {file_name = nil, buf_type = 'c'}

-- A public function to use an existing template
file_templater.use_template = function (opts)
    opts = vim.tbl_deep_extend("force", {}, use_template_def_opts, opts or {})
    if not (opts.file_name==nil) then
        _use_template(opts.file_name, opts)
    else
        vim.ui.select(file_templater.get_templates(), {prompt = "Choose template"}, function(input)
            assert(input~=nil, "You have to choose a template!")
            _use_template(input, opts)
        end)
    end
end

-- Private function that copies contents of a template to a buffer
_use_template = function(file_name, opts)
    local chosen_template = config.options.file_templates_path..file_name
    assert(vim.fn.filereadable(chosen_template)~=0, "Template not found!")
    -- Read the file
    local file = assert(io.open(chosen_template, "r"), "Error while trying to read the template!")
    local contents = file:read("*a")
    local lines = {}
    for str in keep_blank_lines(contents) do
        table.insert(lines, str)
    end

    if opts.buf_type=='e' then
        vim.api.nvim_command('e! '..file_name)
    elseif opts.buf_type=='v' then
        vim.api.nvim_command('vsplit')
        vim.api.nvim_buf_set_name(0, file_name)
    elseif opts.buf_type=='s' then
        vim.api.nvim_command('split')
        vim.api.nvim_buf_set_name(0, file_name)
    end
    local og_row, og_column = unpack(vim.api.nvim_win_get_cursor(0))
    vim.fn.append(og_row-1,lines)
    vim.api.nvim_win_set_cursor(0, {og_row, og_column})
    io.close(file)
end


-- ######################################################
-- REMOVE_TEMPLATE
-- ######################################################
-- A public function to remove a template
file_templater.remove_template = function (file_name)
    local file_path = config.options.file_templates_path
    local templates = file_templater.get_templates()
    if file_name==nil then
        vim.ui.select(templates, {prompt = "Delete template"}, function(input)
            assert(vim.fn.filereadable(file_path..input)~=0, "Template "..input.. " doesn't exist!")
            vim.cmd('silent !rm '..file_path..input)
        end)
    else
        assert(vim.fn.filereadable(file_path..file_name)~=0, "Template "..file_name.. " doesn't exist!")
        vim.cmd('silent !rm '..file_path..file_name)
    end
end

return file_templater
