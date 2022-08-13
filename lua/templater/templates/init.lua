local M = {}

M.string = function(str)
    return function(callback)
        callback(str)
    end
end

M.input = function()
    return function(callback)
        local p = "Input"
        vim.ui.input({prompt = p}, function(input)
            callback(input)
        end)
    end
end

return M
