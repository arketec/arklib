local component = require('component')
local event = require('event')
local colors = require('src.constants.myColors')
local try = require('src.util.try')

local gpu = component.gpu

local painter = {}

local Painter = {}

function Painter:create(coords, color, updateFunction, errorHandler)

end

function Painter:draw()
    -- store current colors
    local lastBgColor = gpu.getBackground()

    -- set button color and fill
    gpu.setBackground(self.color)
    gpu.fill(self.coords.xStart, self.coords.yStart - self.coords.height, self.coords.width, self.coords.height, ' ')

    -- return bg color to previous
    gpu.setBackground(lastBgColor)
end

function Painter:update(...)

end


function painter.new()
    local p = {

    }
    setmetatable(p, { __index = Painter })
    return p
end


return painter