local component = require('component')
local event = require('event')
local colors = require('src.constants.myColors')
local try = require('src.util.try')

local gpu = component.gpu

local painter = {}

local Painter = {}

function Painter:create(coords, color, updateFunction, errorHandler)
    event.listen('touch', function(_,_,x,y)
        local lastBgColor = gpu.getBackground()
        gpu.setBackground(color)
        gpu.fill(x, y, 1, 1, ' ')
        gpu.setBackground(lastBgColor)
    end)
end


function painter.new()
    local p = {

    }
    setmetatable(p, { __index = Painter })
    return p
end


return painter