local component = require('component')
local GUI = require('GUI')
local reactor_list = component.list('nc_fusion_reactor')
local energyCore = component.draconic_rf_storage
local modem = component.modem
local gpu = component.gpu
local thread = require('thread')
local serialization = require('serialization')

-- ======= DEBUG ============
local debugMode = false
-- =========================

local screenWidth, screenHeight = gpu.getResolution()
local numRows = 3
local numColumns = 3
local elements = {}

local reactor_addrs = {}
for k, _ in pairs(reactor_list) do
  table.insert(reactor_addrs, k)
end

local reactor1= component.proxy(reactor_addrs[1]) 
local reactor2= component.proxy(reactor_addrs[2]) 

local time = reactor1.getFusionComboTime()
local size = reactor1.getToroidSize()


local currentPower
local currentCycle
local currentHeat
local currentEfficiency
local active = 'true'

local currentPower2
local currentCycle2
local currentHeat2
local currentEfficiency2
local active2 = 'true'

local function updateStatus()
  currentPower = reactor1.getReactorProcessPower()
  currentCycle = reactor1.getCurrentProcessTime()
  currentHeat = reactor1.getTemperature()
  currentEfficiency = reactor1.getEfficiency()
  
  currentPower2 = reactor2.getReactorProcessPower()
  currentCycle2 = reactor2.getCurrentProcessTime()
  currentHeat2 = reactor2.getTemperature()
  currentEfficiency2 = reactor2.getEfficiency()
end

local function addElement(elem)
    table.insert(elements, elem)
end

local function calcFuelUse()
  return 1000 / (time / size)
end


updateStatus()
reactor1.activate()
reactor2.activate()

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
local fuelText = GUI.text(9, 17, 0xEEEEEE, calcFuelUse() .. ' mB/t')
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
statusContainer1:addChild(GUI.text(10, 20, 0xEEEEEE, reactor1.getFirstFusionFuel()))
statusContainer1:addChild(GUI.label(2,23, 28, 3, 0xEEEEEE, "Fuel 2: "))
statusContainer1:addChild(GUI.text(10, 23, 0xEEEEEE, reactor1.getSecondFusionFuel()))
statusContainer1:addChild(GUI.label(2,26, 28, 3, 0xEEEEEE, "Running: "))
statusContainer1:addChild(activeText)

local startButton1 = GUI.framedButton(1, 1, 26, 3, 0xEEEEEE, 0xFFFFFF, 0xAAAAAA, 0x0, "Start")
startButton1.onTouch = function()
  reactor1.activate()
  active = 'true'
end

local stopButton1 = GUI.framedButton(1, 1, 26, 3, 0xEEEEEE, 0xFFFFFF, 0xAAAAAA, 0x0, "Stop")
stopButton1.onTouch = function()
  reactor1.deactivate()
  active = 'false'
end

local problems = GUI.text(1, 1, 0xEEEEEE, 'Reactor 1 Issues: ' .. reactor1.getProblem())

--========= Reactor 2 =============
local statusContainer2 = GUI.container(1,1,28,28)
local statusPanel2 = GUI.panel(1,1,28, 28, 0xAAAAAA)
local powerText2 = GUI.text(9, 5, 0xEEEEEE,  currentPower2 .. ' rf/t')
local cycleText2 = GUI.text(9, 8, 0xEEEEEE,  currentCycle2 .. ' ticks')
local heatText2 = GUI.text(9, 11, 0xEEEEEE,  currentHeat2 .. ' C')
local effText2 = GUI.text(9, 14, 0xEEEEEE,  currentEfficiency2 .. ' %')
local fuelText2 = GUI.text(9, 17, 0xEEEEEE, calcFuelUse() .. ' mB/t')
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
statusContainer2:addChild(GUI.text(10, 20, 0xEEEEEE, reactor2.getFirstFusionFuel()))
statusContainer2:addChild(GUI.label(2,23, 28, 3, 0xEEEEEE, "Fuel 2: "))
statusContainer2:addChild(GUI.text(10, 23, 0xEEEEEE, reactor2.getSecondFusionFuel()))
statusContainer2:addChild(GUI.label(2,26, 28, 3, 0xEEEEEE, "Running: "))
statusContainer2:addChild(active2Text)

local startButton2 = GUI.framedButton(1, 1, 26, 3, 0xEEEEEE, 0xFFFFFF, 0xAAAAAA, 0x0, "Start")
startButton2.onTouch = function()
  reactor2.activate()
  active2 = 'true'
end

local stopButton2 = GUI.framedButton(1, 1, 26, 3, 0xEEEEEE, 0xFFFFFF, 0xAAAAAA, 0x0, "Stop")
stopButton2.onTouch = function()
  reactor2.deactivate()
  active2 = 'false'
end

local problems2 = GUI.text(1, 1, 0xEEEEEE, 'Reactor 2 Issues: ' .. reactor2.getProblem())

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

--layout:setPosition(2, 1, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "Button 4")))
--layout:setPosition(2, 2, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "Button 5")))
--layout:setPosition(2, 3, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "Button 6")))

local app = GUI.application()
app:addChild(GUI.panel(1, 1, app.width, app.height, 0x2D2D2D))
app:addChild(layout)

--==== Network Functions ============================
local function broadcastStatus()
    modem.broadcast(100, serialization.serialize({
        PowerGeneration = currentPower + currentPower2,
        ReactorsActive = {
            One = active,
            Two = active2
        },
        StoredEnergy = energyCore.getEnergyStored() + energyCore.getMaxEnergyStored()
    }))
end

--==== Update Screen Functions =======================
local function updateText()
    powerText.text = currentPower .. ' rf/t'
    cycleText.text = currentCycle .. ' ticks'
    heatText.text = currentHeat .. ' C'
    effText.text = currentEfficiency .. ' %'
    fuelText.text = calcFuelUse() .. ' mB/t'
    activeText.text = active
    
    powerText2.text = currentPower2 .. ' rf/t'
    cycleText2.text = currentCycle2 .. ' ticks'
    heatText2.text = currentHeat2 .. ' C'
    effText2.text = currentEfficiency2 .. ' %'
    fuelText2.text = calcFuelUse() .. ' mB/t'
    active2Text.text = active2
    
    problems.text = 'Reactor 1 Issues: ' .. reactor1.getProblem()
    problems2.text = 'Reactor 2 Issues: ' .. reactor2.getProblem()
end

local function updateGraph()
    table.insert(energyChart.values, {elapsed, energyCore.getEnergyStored() + energyCore.getMaxEnergyStored()})
end

local function resetGraph()
    energyCore.values = {{0,0}}
end

--==== Update thread ==========================
local statusThread = thread.create(function(a)
  local elapsed = 1
  while true do
    updateStatus()
    updateText()
    updateGraph()
    broadcastStatus()
    if (elapsed % 1800 == 0) then
      resetGraph()
      elapsed = 1
    end
    
    a:draw(true)
    os.sleep(1)
    elapsed = elapsed + 1
  end
end, app)



app:draw(true)
app:start()