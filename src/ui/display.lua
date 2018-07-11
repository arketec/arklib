local decoder = require('src.decoders.smap_decoder')

local display = {}

function display.loadBackgroud(path)
    local cbg = gpu.getBackground()
    local pixArray = decoder.decode(path)
    for i,v in ipairs(pixArray) do
        for j,k in ipairs(v) do
            gpu.setBackground(k)
            gpu.set(i,j,1,1,' ')
        end
    end
    gpu.setBackground(cbg)
end