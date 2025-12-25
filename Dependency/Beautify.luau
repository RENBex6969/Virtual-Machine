local beautifyHandlers = {
    table = function(data, tabs)
        if visited[data] then return "{ 'recursive table' }" end

        tabs = tabs or 1

        local out = "{\n"
        local p = string.rep(tab, tabs);

        visited[data] = true

        for i, v in next, data do
            --if i == "location" or i == "position" or i == "trailingtrivia" or i == "leadingtrivia" then continue end

            out ..= `{p}[{beautify(i, tabs + 1)}] = {beautify(v, tabs + 1)},\n`
        end

        visited[data] = false

        if #out == 2 then return "{}" end

        return out:sub(1, -3) .. "\n" .. string.rep(tab, tabs - 1) .. "}"
    end,
    string = function(data, style, depth)
        if (style == 'block') then
            local equals = string.rep("=", depth or 1)
            return format("[%s[%s]%s]", equals, data, equals)
        else
            local quote = style == "double" and '"' or style == "interp" and "`" or "'"
            return quote .. data .. quote
        end
    end,
    number = function(data)
        local str = tostring(data)
        if str == "nan" then return "0/0" elseif str == "inf" then return "math.huge" elseif str == "-inf" then return "-math.huge" end

        return str
    end
}

function beautify(data : any, ...) : string
    local type = typeof(data);

    local f = beautifyHandlers[type] or tostring
    return f(data, ...);
end

return beautify