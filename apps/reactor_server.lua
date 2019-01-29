local component = require('component')
local reactor_list = component.list('nc_fusion_reactor')
local energyCore = component.draconic_rf_storage
local modem = component.modem
local serialization = require('serialization')
local event = require('event')

-- ======= DEBUG ============
local debugMode = false
-- =========================

local reactor_addrs = {}
for k, _ in pairs(reactor_list) do
  table.insert(reactor_addrs, k)
end

local reactor1= component.proxy(reactor_addrs[1]) 
local reactor2= component.proxy(reactor_addrs[2]) 

local time = reactor1.getFusionComboTime()
local size = reactor1.getToroidSize()

local stats = {
    reactor1 = {
        currentPower = 0,
        currentCycle = 0,
        currentHeat = 0,
        currentEfficiency = 0,
        active = 'true',
        problems = 'No Problems',
        fuelUse = 0,
        fuel1 = 'none',
        fuel2 = 'none'
    },
    reactor2 = {
        currentPower = 0,
        currentCycle = 0,
        currentHeat = 0,
        currentEfficiency = 0,
        active = 'true',
        problems = 'No Problems',
        fuelUse = 0,
        fuel1 = 'none',
        fuel2 = 'none'
    },
    storedEnergy = 0
}

local function calcFuelUse()
    return 1000 / (time / size)
end

local function start1()
    reactor1.activate()
    active = 'true'
end

local function start2()
    reactor2.activate()
    active2 = 'true'
end

local function stop1()
    reactor1.deactivate()
    active = 'false'
end

local function stop2()
    reactor2.deactivate()
    active2 = 'false'
end

local function updateStatus()
  stats.reactor1.currentPower = reactor1.getReactorProcessPower()
  stats.reactor1.currentCycle = reactor1.getCurrentProcessTime()
  stats.reactor1.currentHeat = reactor1.getTemperature()
  stats.reactor1.currentEfficiency = reactor1.getEfficiency()
  stats.reactor1.fuel1 = reactor1.getFirstFusionFuel()
  stats.reactor1.fuel2 = reactor1.getSecondFusionFuel()
  
  stats.reactor2.currentPower = reactor2.getReactorProcessPower()
  stats.reactor2.currentCycle = reactor2.getCurrentProcessTime()
  stats.reactor2.currentHeat = reactor2.getTemperature()
  stats.reactor2.currentEfficiency = reactor2.getEfficiency()
  stats.reactor2.fuel1 = reactor2.getFirstFusionFuel()
  stats.reactor2.fuel2 = reactor2.getSecondFusionFuel()

  stats.reactor1.fuelUse = calcFuelUse()
  stats.reactor2.fuelUse = calcFuelUse()
  stats.storedEnergy = energyCore.getEnergyStored() + energyCore.getMaxEnergyStored()

  stats.reactor1.problems = reactor1.getProblem()
  stats.reactor2.problems = reactor2.getProblem()
end

--==== Network Functions ============================
local function broadcastStatus()
    updateStatus()
    modem.broadcast(100, serialization.serialize(stats))
end

--=== Main Handlers ===================================
local myEventHandlers = setmetatable({}, { __index = function() return unknownEvent end })

function myEventHandlers.modem_message(_, from, _, _, message)
    local actions = serialization.deserialize(message)
    if (actions.reactor1 == 'start') then
        start1()
    elseif (actions.reactor2 == 'start') then
        start2()
    elseif (actions.reactor1 == 'stop') then
        stop1()
    elseif (actions.reactor2 == 'stop') then
        stop2()
    else
        broadcastStatus()
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
start1()
start2()
local running = true
while running do
    running = handleEvent(event.pull()) -- sleeps until an event is available, then process it
end