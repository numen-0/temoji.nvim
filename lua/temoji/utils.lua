local M = {}

---@param t table
---@param cb fun(key:string, value:any)
M.foreach = function(t, cb)
    for key, value in pairs(t) do
        cb(key, value)
    end
end

---@param  str string
---@return boolean
M.is_ascii = function(str)
    return not str:find("[\128-\255]")
end

---@param  t table<string, any[]>
---@return any[]
M.flatten = function(t)
    local flat = {}
    for _, list in pairs(t) do
        for _, item in ipairs(list) do
            table.insert(flat, item)
        end
    end
    return flat
end

-- from: https://github.com/blitmap/lua-utf8-simple/tree/master
M.utf8len = function(str)
	return select(2, str:gsub('[^\128-\193]', ''))
end

M.pad_utf8 = function(str, width)
    local len = M.utf8len(str)
    if len < width then
        return str .. string.rep(" ", width - len)
    else
        return str
    end
end

return M
