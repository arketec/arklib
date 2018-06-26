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
    if (modem.open(port)) then
        print('Broadcasting on port at: ' .. port)
    else
        print('Failed to open port: ' .. port)
        if (errorHandler) then
            errorHandler()
        end
    end
end

function Server:broadcast(...)
    local args = {...}
    for i,v in ipairs(arg) do
        if (type(v) == 'table') then
            args[i] = ser.serialize(v)
        end
    end
    mode.broadcast(self.port, table.unpack(args))
end

function Server:send(...)
    if (self.address) then
        mode.broadcast(self.address, self.port, ...)
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