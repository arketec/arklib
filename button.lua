local component = require('component')
local event = require('event')
local colors = require('myColors')
local try = require("try")

local gpu = component.gpu

local button = {}
local Button = {}

-- private functions
local function isButtonClicked(btn, clickX, clickY, mouseButton)
    local xEnd = btn.coords.xStart + btn.coords.width
    local yEnd = btn.coords.yStart + btn.coords.height

    return clickX <= xEnd and clickX >= btn.coords.xStart and clickY <= yEnd and clickY >= btn.coords.yStart and (btn.restrictions.click_type == nil or btn.restrictions.click_type == mouseButton )
end

local function isAuthorized(btn, playerName)
    if (playerName == nil) then
        return true
    end
    if (btn.restrictions.authorized_players == nil) then
        return true
    end

    for i in ipairs(btn.restrictions.authorized_players) do
        if (btn.restrictions.authorized_players[i] == playerName) then
            return true
        end
    end
    return false
end

-- constructor
function Button:create(coords, text, options, callback, errorHandler)
    -- center text in button
    local textX = 0
    local textY = 0
    if (coords == nil) then
        coords = {xStart = 1, yStart = 1, width = 1, height = 1}
    end
    if (not options.text_vertical) then
        textX = (math.floor(coords.width / 2) + coords.xStart) - (math.floor(string.len(text) / 2))
        textY = math.floor(coords.height / 2) + coords.yStart
    else
        textX = math.floor(coords.width / 2 + coords.xStart)
        textY = (math.floor(coords.height / 2) + coords.yStart) - (math.floor(string.len(text) / 2))
    end

    -- set coords
    self.coords.xStart = coords.xStart
    self.coords.yStart = coords.yStart
    self.coords.width = coords.width
    self.coords.height = coords.height
    self.text.xStart = textX
    self.text.yStart = textY

    -- set colors
    if (options.color ~= nil) then
        self.color = options.color
    end

    if (options.text_color ~= nil) then
        self.text.color = options.text_color
    end

    -- set restrictions
    if (options.clickType ~= nil) then
        self.restrictions.click_type = options.clickType
    end

    -- set callbacks
    self.callback = callback
    if (errorHandler ~= nil) then
        self.errorHandler = errorHandler
    end

    -- add text
    if options.text_vertical ~= nil then
        self.text.vertical = options.text_vertical
    end
    self.text.value = text  
end

-- public methods
function Button:addPlayer(name)
    if (self.restrictions.authorized_players == nil) then
        self.restrictions.authorized_players = {}
    end
    table.insert( self.restrictions.authorized_players, self.restrictions.authorized_players_size, name )
    self.restrictions.authorized_players_size = self.restrictions.authorized_players_size + 1
end

function Button:removePlayer(name)
    if (self.restrictions.authorized_players_size == 0) then
        return
    end
    
    for i = 0, self.restrictions.authorized_players_size do
        if (self.restrictions.authorized_players[i] == name) then
            table.remove( self.restrictions.authorized_players, i )
            self.restrictions.authorized_players_size = self.restrictions.authorized_players_size - 1
            return
        end
    end
end

function Button:draw()
    -- store current colors
    local lastBgColor = gpu.getBackground()
    local lastFgColor = gpu.getForeground()

    -- set button color and fill
    gpu.setBackground(self.color)
    gpu.fill(self.coords.xStart, self.coords.yStart, self.coords.width, self.coords.height, ' ')

    -- print to sreen
    gpu.setForeground(self.text.color)
    gpu.set(self.text.xStart, self.text.yStart, self.text.value, self.text.vertical)

    -- add touch event callback
    event.listen('touch', 
        function(_, addr, cX, cY, mouseButton, playerName) 
            try(function()
                    if (isButtonClicked(self, cX, cY, mouseButton)) then
                        if (isAuthorized(self, playerName)) then
                            self.callback(addr, cX, cY, mouseButton, playerName)
                        else
                            self.errorHandler('unauthorized_exception', playerName)
                        end
                    end
                end,
                self.errorHandler
            )
        end
    )

    -- return to previous colors
    gpu.setForeground(lastFgColor)
    gpu.setBackground(lastBgColor)
end

function button.new()
    local btn = {
        color = colors.black,
        restrictions = {
            authorized_players = nil,
            authorized_players_size = 0,
            click_type = nil,
        },
        coords = {
            xStart = 0,
            yStart = 0,
            width = 0,
            height = 0
        },
        text = {
            xStart = 0,
            yStart = 0,
            value = nil,
            color = colors.white,
            vertical = false
        },
        callback = nil,
        errorHandler = print
    }
    setmetatable(btn, { __index = Button })
    return btn
end


return button