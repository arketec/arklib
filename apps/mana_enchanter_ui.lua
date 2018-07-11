local component = require('component')
local term = require('term')
local event = require('event')
local arklib = require('arklib')
local gpu = component.gpu
local colors = arklib.constants.colors
local ui = arklib.ui
local window = ui.window
local button = ui.button
local me = component.me_controller

local args = {...}

local craftables = require('./craftables')
local toCraft = {}
local command = args[1]
local currentGroup = args[2]
local currentDisplay = nil
-- local tools = {}
-- local sword = {}
-- local bow = {}
-- local chest = {}
-- local leggings = {}
-- local helmet = {}
-- local boots = {}

local maxWidth, maxHeight = gpu.getResolution()
local nextX = 1
local nextY = 1
local cellWidth = math.floor(maxWidth / 4)
local cellHeight = math.floor(maxHeight / 4)
local counter = 1

local mainWindow = window.new()

function redraw()
    currentDisplay = {}
    
    for k,v in pairs(craftables) do
        local btn = button.new()
        btn:create({xStart = nextX, yStart = nextY, width = cellWidth, height = cellHeight}, k, {color = colors.blue, text_color = colors.white}, function() 
            if (currentGroup == nil) then
                show(k)
            end
        end, print)
        table.insert(currentDisplay, btn)
        nextX = nextX + cellWidth
        counter = counter + 1
        if (counter > 4) then
            counter = 1
            nextX = 1
            nextY = nextY + cellHeight
        end
    end
    
    local startBtn = button.new()
    startBtn:create({xStart = nextX, yStart = nextY, width = cellWidth, height = cellHeight}, 'Enchant', {color = colors.red, text_color = colors.white}, function() 
        start()
    end, print)
    table.insert(currentDisplay, startBtn)
    nextX = nextX + cellWidth
    counter = counter + 1
    if (counter > 4) then
        counter = 1
        nextX = 1
        nextY = nextY + cellHeight
    end
    
    term.clear()
    for i,v in ipairs(currentDisplay) do
        currentDisplay[i]:draw()
    end
end

function getGroupCount()
    local counter = 0
    for k,v in pairs(craftables) do
        counter = counter + 1
    end
    return counter
end

function showConflict(name, attempted) 
    print(name .. ' conflicts with ' .. attempted)
end

function showTools()
    currentGroup = 'tools'
    for k,v in pairs(craftables.tools) do
        local btn = button.new()
        mainWindow:add(btn, v.display_name, {color = colors.purple, text_color = colors.white}, function() 
            addToCraft(k)
        end, print)
    end
end

function showSword()
    currentGroup = 'sword'
    local cColor = colors.purple
    local tColor = colors.white
    for k,v in pairs(craftables.sword) do
        local btn = button.new()
        if (cColor == colors.purple) then
            cColor = colors.white
            tColor = colors.purple
        else
            cColor = colors.purple
            tColor = colors.white
        end
        btn:create({xStart = nextX, yStart = nextY, width = cellWidth, height = cellHeight}, v.display_name, {color = cColor, text_color = tColor}, function() 
            addToCraft(k)
        end, print)
        table.insert(currentDisplay, btn)
        nextX = nextX + cellWidth
        counter = counter + 1
        if (counter > 4) then
            counter = 1
            nextX = 1
            nextY = nextY + cellHeight
        end
    end
end

function showBow()
    currentGroup = 'bow'
    for k,v in pairs(craftables.bow) do
        local btn = button.new()
        mainWindow:add(btn, v.display_name, {color = colors.purple, text_color = colors.white}, function() 
            addToCraft(k)
        end, print)
    end
end

function showChest()
    currentGroup = 'chest'
    for k,v in pairs(craftables.chest) do
        local btn = button.new()
        mainWindow:add(btn, v.display_name, {color = colors.purple, text_color = colors.white}, function() 
            addToCraft(k)
        end, print)
    end
end

function showLeggings()
    currentGroup = 'leggings'
    for k,v in pairs(craftables.leggings) do
        local btn = button.new()
        mainWindow:add(btn, v.display_name, {color = colors.purple, text_color = colors.white}, function() 
            addToCraft(k)
        end, print)
    end
end

function showHelmet()
    currentGroup = 'helmet'
    for k,v in pairs(craftables.helmet) do
        local btn = button.new()
        mainWindow:add(btn, v.display_name, {color = colors.purple, text_color = colors.white}, function() 
            addToCraft(k)
        end, print)
    end
end

function showBoots()
    currentGroup = 'boots'
    for k,v in pairs(craftables.boots) do
        local btn = button.new()
        mainWindow:add(btn, v.display_name, {color = colors.purple, text_color = colors.white}, function() 
            addToCraft(k)
        end, print)
    end
end

function showAll()
    for k,v in pairs(craftables) do
        for j,w in pairs(v) do
            print(w.display_name, w.level)
        end
    end
end

function show(group)
    term.clear()
    redraw()
    if (group == 'tools') then
        showTools()
    elseif (group == 'sword') then
        showSword()
    elseif (group == 'bow') then
        showBow()
    elseif (group == 'chest') then
        showChest()
    elseif (group == 'leggings') then
        showLeggings()
    elseif (group == 'helmet') then
        showHelmet()
    elseif (group == 'boots') then
        showBoots()
    else
        showAll()
    end
    for i,v in ipairs(currentDisplay) do
        currentDisplay[i]:draw()
    end
end

function addToCraft(enchantment)
    if (next(toCraft) ~= nil) then
        for i,v in ipairs(toCraft) do
            if (craftables[currentGroup][enchantment].conflicts ~= nil and craftables[currentGroup][enchantment].conflicts == craftables[currentGroup][toCraft[i]].craft_name) then
                showConflict(toCraft[i],enchantment)
                return
            end
        end
    end
    table.insert(toCraft, enchantment)
end

function resetWindow()
    mainWindow = nil
    mainWindow = window.new()
    mainWindow:create({numRows = 3, numCols = 3})
    for k,v in pairs(craftables) do
        local btn = button.new()
        mainWindow:add(btn, k, {color = colors.blue, text_color = colors.white}, function() 
            if (currentGroup == nil) then
                show(k)
            end
        end, print)
    end

    local startBtn = button.new()
    mainWindow:add(startBtn, 'Enchant', {color = colors.red, text_color = colors.white}, function() 
        start()
    end, print)
    mainWindow:draw()
end

function start()
    for i,v in ipairs(toCraft) do
        me.getCraftables({name = craftables[currentGroup][v].craft_name})[1].request()
    end
    os.sleep(40)
    print('..done!')
    currentGroup = nil
    redraw()
end

term.clear()
--mainWindow:create({numRows = 3, numCols = 3})
redraw()


while (true) do
    event.pull(0.05)
end