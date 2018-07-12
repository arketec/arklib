local file_util = require('src.util.file')
local component = require('component')

local encoder = {}

function encoder.encode(path,smap,w,h)
    local f = io.open(path, "w")
    for i = 1,#smap do
        local encoded = ''
        for j = 1, #line do
            encoded = encoded .. smap[i][j] .. ' '
        end
        
        f:write(encoded, "\n")
    end
    f:close()
end