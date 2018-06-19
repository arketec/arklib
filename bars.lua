local component = require('component')
local event = require('event')
local colors = require('myColors')
local try = require("try")

local gpu = component.gpu

local bars = {}

local Bar = {}

function Bar:create(coords, color, updateFunction, errorHandler)

    -- add intial coords
    self.coords.xStart = coords.xStart
    self.coords.yStart = coords.yStart
    self.coords.width = coords.width
    self.coords.maxHeight = coords.maxHeight

    -- set color
    self.color = color

    --set functions
    self.updateFunction = updateFunction
    self.errorHandler = errorHandler

end

function Bar:draw()
    -- store current colors
    local lastBgColor = gpu.getBackground()

    -- set button color and fill
    gpu.setBackground(self.color)
    gpu.fill(self.coords.xStart, self.coords.yStart - self.coords.height, self.coords.width, self.coords.height, ' ')

    -- return bg color to previous
    gpu.setBackground(lastBgColor)
end

function Bar:update(...)
    self.coords.height = updateFunction(...)
    self:draw()
end


function bars.new()
    local b = {
        color = colors.black,
        coords = {
            xStart = 0,
            yStart = 0,
            width = 0,
            height = 0,
            maxHeight = 0
        },
        updateFunction = nil,
        errorHandler = print
    }
    setmetatable(b, { __index = Bar })
    return b
end


return button