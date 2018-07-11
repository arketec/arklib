local string_util = {}

function string_util.split(text, delimiter)
    return string.gmatch(text, '%' .. delimiter .. '+' )
end