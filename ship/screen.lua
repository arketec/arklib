local GUI = require("GUI")
local component = require('component')
local modem = component.modem
local gpu = component.gpu

-- =======DEBUG ============
local debugMode = true
-- =========================

local screenWidth, screenHeight = gpu.getResolution()
local numRows = 3
local numColumns = 3
local elements = {}

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

layout:setPosition(1, 1, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "Button 1")))
layout:setPosition(1, 2, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "Button 2")))
layout:setPosition(1, 3, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "Button 3")))

layout:setPosition(2, 1, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "Button 4")))
layout:setPosition(2, 2, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "Button 5")))
layout:setPosition(2, 3, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "Button 6")))

local app = GUI.application()
app:addChild(GUI.panel(1, 1, application.width, application.height, 0x2D2D2D))
app:addChild(layout)
app:start()