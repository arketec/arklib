local com = require('component')
local event = require('event')
local ser = require('serialization')
local modem = com.modem

local client = {}

local Client = {
    port = 0,
    callback = nil,
    errorHandler = nil,
    running = false
}

function Client:create(port, address, callback, errorHandler)
    self.port = port
    self.callback = callback
    self.errorHandler = errorHandler
    
    if (modem.open(port)) then
        print('Listening on port at: ' .. port)
    else
        print('Failed to open port: ' .. port)
        if (errorHandler) then
            errorHandler()
        end
    end
end

function Client:handleMessage(type, _, remoteAddress, port, distance, ...)
    local args = {...}
    for i,v in ipairs(arg) do
        local tmp = ser.unserialize(v)
        if (tmp ~= nil) then
            args[i] = tmp
        end
    end
    if (type == 'interrupted') then
        self.running = false
        self.errorHandler()
    else
        self.callback(table.unpack(args))
    end
end

function Client:listen()
    self.running = true
    while (self.running) do
        self.handleMessage(event.pullMultiple('modem_message', 'interrupted'))
    end
end

function client.new()
    local c = {
        port = 0,
        callback = nil,
        errorHandler = nil
    }
    setmetatable(c, { __index = Client })
    return c
end

return client