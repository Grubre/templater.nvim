local M = {}

M.string = function(str)
    return function(callback)
        callback(tostring(str))
    end
end

M.input = function(opts)
    return function(callback)
        local options = vim.tbl_deep_extend("force", {}, {prompt = "Input"}, opts or {})
        vim.ui.input(options, function(input)
            callback(input)
        end)
    end
end

M.select = function(items, opts)
    return function(callback)
        local options = vim.tbl_deep_extend("force", {}, {prompt = "Select"}, opts or {})
        vim.ui.select(items, options, function(input)
            callback(input)
        end)
    end
end

return M
