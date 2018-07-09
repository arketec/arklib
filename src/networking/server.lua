local com = require('component')
local ser = require('serialization')
local modem = com.modem

local server = {}

local Server = {
    port = 0,
    address = 0
}

function Server:create(port, address, errorHandler)
    self.port = port
    if (address) then
        self.address = address
    end
end

function Server:broadcast(message)
        local msg = message
        if (type(message) == 'table') then
            msg = ser.serialize(message)
        end
    
    modem.broadcast(self.port, msg)
end

function Server:send(...)
    if (self.address) then
        modem.broadcast(self.address, self.port, ...)
    else
        print('Cannot send. No address')
    end
end

function server.new()
    local s = {
        port = 0,
        address = 0
    }
    setmetatable(s, { __index = Server })
    return s
end

return server