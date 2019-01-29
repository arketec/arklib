local component = require('component')
local GUI = require('GUI')
local modem = component.modem
local gpu = component.gpu
local thread = require('thread')
local serialization = require('serialization')
local computer = require('computer')

-- ======= DEBUG ============
local debugMode = false
-- =========================

local screenWidth, screenHeight = gpu.getResolution()
local numRows = 3
local numColumns = 3
local elements = {}
local initialUptime = computer.uptime()
local runSecs = 0

local currentPower = 0
local currentCycle = 0
local currentHeat = 0
local currentEfficiency = 0
local active = 'true'
local fuel1 = ''
local fuel2 = ''
local currentProblems = 'No Problems'

local currentPower2 = 0
local currentCycle2 = 0
local currentHeat2 = 0
local currentEfficiency2 = 0
local active2 = 'true'
local fuel21 = ''
local fuel22 = ''
local currentProblems2 = 'No Problems'

local storedEnergy = 0
local fuelUse = 0

local function getRunSecs()
    runSecs = computer.uptime() - initialUptime
    return runSecs
end

local function updateStatus(msg)
  
  local status = serialization.unserialize(msg)
  if (msg.error ~= nil) then
    currentProblems = msg.error
    return
  end
  currentPower = status.reactor1.currentPower
  currentCycle = status.reactor1.currentCycle
  currentHeat = status.reactor1.currentHeat
  currentEfficiency = status.reactor1.currentEfficiency
  currentProblems = status.reactor1.problems
  active = status.reactor1.active
  fuel1 = status.reactor1.fuel1
  fuel2 = status.reactor1.fuel2
  
  currentPower2 = status.reactor2.currentPower
  currentCycle2 = status.reactor2.currentCycle
  currentHeat2 = status.reactor2.currentHeat
  currentEfficiency2 = status.reactor2.currentEfficiency
  currentProblems2 = status.reactor2.problems
  active2 = status.reactor2.active
  fuel21 = status.reactor2.fuel1
  fuel22 = status.reactor2.fuel2

  storedEnergy = status.storedEnergy
  fuelUse = status.reactor1.fuelUse
end

local function addElement(elem)
    table.insert(elements, elem)
end

local layout = GUI.layout(1,1, screenWidth, screenHeight, numColumns, numRows)
layout.showGrid = debugMode

layout:setColumnWidth(1, GUI.SIZE_POLICY_RELATIVE, 0.6)
layout:setColumnWidth(2, GUI.SIZE_POLICY_RELATIVE, 0.2)
layout:setColumnWidth(3, GUI.SIZE_POLICY_RELATIVE, 0.2)

layout:setRowHeight(1, GUI.SIZE_POLICY_RELATIVE, 0.6)
layout:setRowHeight(2, GUI.SIZE_POLICY_RELATIVE, 0.2)
layout:setRowHeight(3, GUI.SIZE_POLICY_RELATIVE, 0.2)

-- ====== Reactor 1 =====
local statusContainer1 = GUI.container(1,1,28,28)
local statusPanel1 = GUI.panel(1,1,28, 28, 0xAAAAAA)
local powerText = GUI.text(9, 5, 0xEEEEEE,  currentPower .. ' rf/t')
local cycleText = GUI.text(9, 8, 0xEEEEEE,  currentCycle .. ' ticks')
local heatText = GUI.text(9, 11, 0xEEEEEE,  currentHeat .. ' C')
local effText = GUI.text(9, 14, 0xEEEEEE,  currentEfficiency .. ' %')
local fuelText = GUI.text(9, 17, 0xEEEEEE, fuelUse .. ' mB/t')
local activeText = GUI.text(11, 26, 0xEEEEEE, active )
statusContainer1:addChild(statusPanel1)
statusContainer1:addChild(GUI.label(2,2, 28, 3, 0xEEEEEE, "Reactor 1 "))
statusContainer1:addChild(GUI.text(2,5, 0xEEEEEE, "Power: "))
statusContainer1:addChild(powerText)
statusContainer1:addChild(GUI.label(2,8, 28, 3, 0xEEEEEE, "Cycle: "))
statusContainer1:addChild(cycleText)
statusContainer1:addChild(GUI.label(2,11, 28, 3, 0xEEEEEE, "Heat: "))
statusContainer1:addChild(heatText)
statusContainer1:addChild(GUI.label(2,14, 28, 3, 0xEEEEEE, "Eff: "))
statusContainer1:addChild(effText)
statusContainer1:addChild(GUI.label(2,17, 28, 3, 0xEEEEEE, "Rate: "))
statusContainer1:addChild(fuelText)
statusContainer1:addChild(GUI.label(2,20, 28, 3, 0xEEEEEE, "Fuel 1: "))
statusContainer1:addChild(GUI.text(10, 20, 0xEEEEEE, fuel1))
statusContainer1:addChild(GUI.label(2,23, 28, 3, 0xEEEEEE, "Fuel 2: "))
statusContainer1:addChild(GUI.text(10, 23, 0xEEEEEE, fuel2))
statusContainer1:addChild(GUI.label(2,26, 28, 3, 0xEEEEEE, "Running: "))
statusContainer1:addChild(activeText)

local startButton1 = GUI.framedButton(1, 1, 26, 3, 0xEEEEEE, 0xFFFFFF, 0xAAAAAA, 0x0, "Start")
startButton1.onTouch = function()
  modem.broadcast(101, serialization.serialize({reactor1 = 'start'}))
end

local stopButton1 = GUI.framedButton(1, 1, 26, 3, 0xEEEEEE, 0xFFFFFF, 0xAAAAAA, 0x0, "Stop")
stopButton1.onTouch = function()
    modem.broadcast(101, serialization.serialize({reactor1 = 'stop'}))
end

local problems = GUI.text(1, 1, 0xEEEEEE, 'Reactor 1 Issues: ' .. currentProblems)

--========= Reactor 2 =============
local statusContainer2 = GUI.container(1,1,28,28)
local statusPanel2 = GUI.panel(1,1,28, 28, 0xAAAAAA)
local powerText2 = GUI.text(9, 5, 0xEEEEEE,  currentPower2 .. ' rf/t')
local cycleText2 = GUI.text(9, 8, 0xEEEEEE,  currentCycle2 .. ' ticks')
local heatText2 = GUI.text(9, 11, 0xEEEEEE,  currentHeat2 .. ' C')
local effText2 = GUI.text(9, 14, 0xEEEEEE,  currentEfficiency2 .. ' %')
local fuelText2 = GUI.text(9, 17, 0xEEEEEE, fuelUse .. ' mB/t')
local active2Text = GUI.text(11, 26, 0xEEEEEE, active2 )
statusContainer2:addChild(statusPanel2)
statusContainer2:addChild(GUI.label(2,2, 28, 3, 0xEEEEEE, "Reactor 2 "))
statusContainer2:addChild(GUI.text(2,5, 0xEEEEEE, "Power: "))
statusContainer2:addChild(powerText2)
statusContainer2:addChild(GUI.label(2,8, 28, 3, 0xEEEEEE, "Cycle: "))
statusContainer2:addChild(cycleText2)
statusContainer2:addChild(GUI.label(2,11, 28, 3, 0xEEEEEE, "Heat: "))
statusContainer2:addChild(heatText2)
statusContainer2:addChild(GUI.label(2,14, 28, 3, 0xEEEEEE, "Eff: "))
statusContainer2:addChild(effText2)
statusContainer2:addChild(GUI.label(2,17, 28, 3, 0xEEEEEE, "Rate: "))
statusContainer2:addChild(fuelText2)
statusContainer2:addChild(GUI.label(2,20, 28, 3, 0xEEEEEE, "Fuel 1: "))
statusContainer2:addChild(GUI.text(10, 20, 0xEEEEEE, fuel21))
statusContainer2:addChild(GUI.label(2,23, 28, 3, 0xEEEEEE, "Fuel 2: "))
statusContainer2:addChild(GUI.text(10, 23, 0xEEEEEE, fuel22))
statusContainer2:addChild(GUI.label(2,26, 28, 3, 0xEEEEEE, "Running: "))
statusContainer2:addChild(active2Text)

local startButton2 = GUI.framedButton(1, 1, 26, 3, 0xEEEEEE, 0xFFFFFF, 0xAAAAAA, 0x0, "Start")
startButton2.onTouch = function()
    modem.broadcast(101, serialization.serialize({reactor2 = 'start'}))
end

local stopButton2 = GUI.framedButton(1, 1, 26, 3, 0xEEEEEE, 0xFFFFFF, 0xAAAAAA, 0x0, "Stop")
stopButton2.onTouch = function()
    modem.broadcast(101, serialization.serialize({reactor2 = 'stop'}))
end

local problems2 = GUI.text(1, 1, 0xEEEEEE, 'Reactor 2 Issues: ' .. currentProblems2)

--======= Energy Core ======
local energyChart = GUI.chart(2,2, 90, 25, 0xEEEEEE, 0xAAAAAA, 0x888888, 0xEE82EE, 0.25, 0.2, "s", "Rf", true, {{0,0}})

layout:setPosition(1, 1, layout:addChild(energyChart))
layout:setPosition(1, 2, layout:addChild(problems))
layout:setPosition(1, 3, layout:addChild(problems2))


layout:setPosition(2, 1, layout:addChild(statusContainer1))
layout:setPosition(2, 2, layout:addChild(startButton1))
layout:setPosition(2, 3, layout:addChild(stopButton1))

layout:setPosition(3, 1, layout:addChild(statusContainer2))
layout:setPosition(3, 2, layout:addChild(startButton2))
layout:setPosition(3, 3, layout:addChild(stopButton2))

local app = GUI.application()
app:addChild(GUI.panel(1, 1, app.width, app.height, 0x2D2D2D))
app:addChild(layout)

--==== Update Screen Functions =======================
local function updateText()
    powerText.text = currentPower .. ' rf/t'
    cycleText.text = currentCycle .. ' ticks'
    heatText.text = currentHeat .. ' C'
    effText.text = currentEfficiency .. ' %'
    fuelText.text = fuelUse .. ' mB/t'
    activeText.text = active
    
    powerText2.text = currentPower2 .. ' rf/t'
    cycleText2.text = currentCycle2 .. ' ticks'
    heatText2.text = currentHeat2 .. ' C'
    effText2.text = currentEfficiency2 .. ' %'
    fuelText2.text = fuelUse .. ' mB/t'
    active2Text.text = active2
    
    problems.text = 'Reactor 1 Issues: ' .. currentProblems
    problems2.text = 'Reactor 2 Issues: ' .. currentProblems2
end

local function updateGraph()
    local secs = getRunSecs()
    local v = {secs, storedEnergy}
    table.insert(energyChart.values, v)
end

local function resetGraph()
    energyCore.values = {{0,0}}
end

app.eventHandler = function(a, obj, event_name, local_addr, remote_addr, power, _, message)
    if (event_name == 'modem_message') then
        local _, err = pcall(updateStatus, message)
        if (err ~= nil) then
          currentProblems = err
        end
        updateText()
        updateGraph()
        a:draw(true)
    end
end

local statusThread = thread.create(function(m)
    while true do
        m.broadcast(101,'')
        --event.pull()
        os.sleep(10)
    end
  end, modem)

modem.open(100)
app:draw(true)
app:start()