local M = {}

M.string = function(str)
    return function(callback)
        callback(str)
    end
end

return M
