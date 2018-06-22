local component = require('component')
local try = require('src.util.try')

local gpu = component.gpu

local function drawChar(pixAr, size) 
    local fcn = function (x,y,color ) end
    local yOffset = 0
    
    for i,v in pairs(pixAr) do
        local last = fcn
        if (v == 1) then
            fcn = function (x,y,color)
                    last()
                    local mod= (i % 3)
                    if (mod == 0) then
                        mod = 3
                    end
                    gpu.fill(x + math.floor(mod),y + yOffset,1,1,' ')
                end
        end
        if (i % 3) == 0 then
            yOffset = yOffset + 1
        end
    end
    local final = fcn
    fcn = function (x,y,color)
        local bg = gpu.getBackground()
        gpu.setBackground(color)
        final()
        gpu.setBackground(bg)
    end
    return fcn
end

local letters = {
    medium = {
        A = function (x,y,color)
                local bg = gpu.getBackground()
                gpu.setBackground(color)
                gpu.fill(x,y,1,1,' ')
                gpu.fill(x-1,y +1,1,1,' ')
                gpu.fill(x,y +1,1,1,' ')
                gpu.fill(x+1,y +1,1,1,' ')
                gpu.fill(x+1,y +2,1,1,' ')
                gpu.fill(x-1,y +2,1,1,' ')
                gpu.setBackground(bg);
            end,
        B = drawChar({1,1,1,0,0,
                      1,0,0,1,0,
                      1,1,1,1,0,
                      1,0,0,1,0,
                      1,1,1,0,0}, 5)
    },
    large = {
        A = function (x,y,color)
            local bg = gpu.getBackground();
            gpu.setBackground(color);
            gpu.fill(x,y,1,1,' ')
            gpu.fill(x-1,y +1,1,1,' ')
            gpu.fill(x+1,y +1,1,1,' ')
            gpu.fill(x+1,y +2,1,1,' ')
            gpu.fill(x,y +3,1,1,' ')
            gpu.fill(x-1,y +2,1,1,' ')
            gpu.setBackground(bg);
        end
    }
}

return letters