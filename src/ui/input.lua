local component = require('component')
local event = require('event')
local colors = require('src.constants.myColors')
local try = require('src.util.try')
local term = require('term')

local gpu = component.gpu

local inputs = {}

local Input = {}

local function isTextClicked(xStart, yStart, width, clickX, clickY, mouseButton)
    local xEnd = xStart + width
    local yEnd = yStart

    return clickX <= xEnd and clickX >= xStart and clickY <= yEnd and clickY >= yStart
end

-- broken
local function truncateString(s, max)
    local nS = ''
    for i = 1, max do
        nS = nS .. s:sub(i,1)
    end
    return nS
end

function Input:create(coords, label, value, updateFunction, errorHandler)

    -- add intial coords
    self.coords.xStart = coords.xStart
    self.coords.xText = coords.xStart + string.len(label) + 1
    
    self.coords.yStart = coords.yStart
    self.coords.width = coords.width

    -- set value
    self.label = label
    if value  ~= nil then
        self.value = value
    else
        self.value = ''
    end

    --set functions
    self.updateFunction = updateFunction
    if (errorHandler ~= nil) then
        self.errorHandler = errorHandler
    else
        self.errorHandler = print
    end
    
    if ((string.len(label) + 1) > self.coords.width) then
        self.errorHandler('width less than label length')
        return
    end

    -- add touch event callback
    event.listen('touch', 
    function(_, addr, cX, cY, mouseButton, playerName) 
        try(function()
                if (isTextClicked(self.coords.xStart, self.coords.yStart, self.coords.width, cX, cY)) then
                    self:update(addr, cX, cY, mouseButton, playerName)
                end
            end,
            self.errorHandler
        )
    end
)

end

function Input:draw()
    -- set input box
    gpu.set(self.coords.xStart, self.coords.yStart, self.label)
    gpu.set(self.coords.xText, self.coords.yStart, self.value)

end

function Input:clear()
    local clr = ''
    local i = string.len(self.coords.width - string.len(self.label) - 1)
    while i > 0 do
        clr = clr .. ' '
        i = i - 1
    end
        
    gpu.set(self.coords.xText, self.coords.yStart, clr)

end

function Input:update(...)
    term.setCursor(self.coords.xText, self.coords.yStart)
    self:clear()
    local lastValue = self.value
    self.value = term.read()
    if (((string.len(self.label) + 1) + string.len(self.value)) > self.coords.width) then
        self.value= lastValue
        self:clear()
        self.errorHandler('value exeeds width')
    end
    if self.updateFunction ~= nil then
        self.updateFunction(...)
    end
    self:draw()
end


function inputs.new()
    local i = {
        label = nil,
        value = nil,
        coords = {
            xStart = 0,
            yStart = 0,
            width = 0
        },
        updateFunction = nil,
        errorHandler = print
    }
    setmetatable(i, { __index = Input })
    return i
end


return inputs