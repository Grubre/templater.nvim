local M = {}

M.string = function(str)
    return function()
        return tostring(str)
    end
end

return M
