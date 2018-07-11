local event = require "event" -- load event table and store the pointer to it in event
local running = true -- state variable so the loop can terminate

local handler = {}

function unknownEvent()
 -- do nothing if the event wasn't relevant
end

-- table that holds all event handlers
-- in case no match can be found returns the dummy function unknownEvent
local myEventHandlers = setmetatable({}, { __index = function() return unknownEvent end })

function handler.add(name, callback)
    myEventHandlers[name] = callback
end


-- The main event handler as function to separate eventID from the remaining arguments
function handler.handleEvent(eventID, ...)
 if (eventID) then -- can be nil if no event was pulled for some time
   myEventHandlers[eventID](...) -- call the appropriate event handler with all remaining arguments
 end
end

-- main event loop which processes all events, or sleeps if there is nothing to do
function handler.startLoop()
    while running do
        handler.handleEvent(event.pull()) -- sleeps until an event is available, then process it
    end
end

return handler