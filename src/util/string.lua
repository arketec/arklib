return {
    split = function(text, delimiter)
        local r = {}
        local index = 1
        for i in string.gmatch(text, '[^' .. delimiter .. ']+' ) do
            r[index] = i
            index = index + 1
        end
        return r
    end
}

