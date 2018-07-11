local file_util = require('src.util.file')
local string_util = require('src.util.string')
local decoder = {}

function decoder.decode(smapPath)
    local xLen
    local yLen
    local map = {}
    local smap = file_util.readAllLines(smapPath)
    for i = 1,#smap do
        if (i == 1) then
            xLen, yLen = string_util.split(smap[i],'s')
        else
            if (map[yCount] == nil) then
                map[yCount] = {}
            end
            local line = string_util.split(smap[i],'s')
            for j = 1, #line do
                map[i][j] = line[j]
            end
        end
    end
    return map
end

return decoder