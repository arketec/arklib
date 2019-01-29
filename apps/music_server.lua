local component = require('component')
local modem = component.modem
local serialization = require('serialization')
local event = require('event')
local thread = require('thread')

-- ======= DEBUG ============
local debugMode = false
-- =========================

local playThread = nil

local function start(path)
    playThread = thread.create(function(p) 
        os.execute('/home/musicPlayer.lua '.. p)
    end, path)
end

local function stop()
    playThread:kill()
end

local function getSongs()
    return component.filesystem.list('/home/music')
end

--==== Network Functions ============================
local function broadcastSonglist()
    modem.broadcast(200, serialization.serialize(getSongs()))
end

--=== Main Handlers ===================================
function unknownEvent()
    -- do nothing if the event wasn't relevant
    return true
end
local myEventHandlers = setmetatable({}, { __index = function() return unknownEvent end })

function myEventHandlers.modem_message(to, from, port, distance, message)
    if (port == 201) then
        broadcastSonglist()
    elseif (port == 202) then
        local params = serialization.unserialize(message)
        start(params.path)
    elseif (port == 203) then
        stop()
    end
    return true
end

function myEventHandlers.interrupted(...)
    return false
end

function handleEvent(eventID, ...)
    if (eventID) then -- can be nil if no event was pulled for some time
        return myEventHandlers[eventID](...) -- call the appropriate event handler with all remaining arguments
    end
    return true
end

--==== Main Loop ========
modem.open(201)
modem.open(202)
modem.open(203)
local running = true
while running do
    running = handleEvent(event.pull()) -- sleeps until an event is available, then process it
end