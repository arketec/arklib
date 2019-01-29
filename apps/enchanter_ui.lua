local GUI = require('GUI')
local component = require("component")
local term = require("term")
local sides = require("sides")
local event = require("event")
local colors = require('src.constants.myColors')
local text = require('src.text.large')

local craftables = require('./craftables')

local me = component.me_controller

-- constants
local Items = {
    sword = "sword",
    tool = "tools",
    helmet = "helmet",
    chestplate = "chest",
    leggings = "leggings",
    boots = "boots",
    bow = "bow"
}

-- state variables
local currentItemType = Items.sword
local previousItemType = Items.sword
local toCraft = {}
local selected = {}


function log(val)
  if (type(val) == 'table') then
    for k, v in pairs(val) do
      print(k,v)
    end
  elseif (type(val) == 'function') then
    print("Value is a function")
  else
    print(val)
  end
end

function split_string(s,d)
  if (d == nil) then
    d = '%s'
  end
  
  local tmp = {}
  local counter = 1
  for p in string.gmatch(s, "([^" .. d .. "]+)") do
    tmp[counter] = p
    counter = counter + 1
  end
  return tmp
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

local mainContainer = GUI.fullScreenContainer()

local rowHeight = (mainContainer.height / 6)

local progressBar
function start()
    GUI.alert("Place " .. currentItemType .. " on mana pedestal. Click OK when ready to start")
    for i,v in ipairs(toCraft) do
        me.getCraftables({name = v.craft_name})[1].request()
    end
    mainContainer:addChild(GUI.panel(48, 10, 30, 3, 0x0))
    progressBar = mainContainer:addChild(GUI.progressBar(48, 10, 30, 0x3366CC, 0xEEEEEE, 0xEEEEEE, 0, true, true, "Enchanting Progress: ", " %"))
    local progress = 0
    while progress < 101 do
        progressBar.value = progress
        os.sleep(0.5)
        progress = progress + 1
        mainContainer:drawOnScreen(true)
    end
    GUI.alert("Enchanting Complete! Collect " .. currentItemType .. " from mana pedestal")
    progressBar.value = 0
    clearSelected()
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function getSelectedIndex(val)
    local index={}
    for k,v in ipairs(selected) do
       if (v.display_name == val) then
            return k
       end
    end
    return nil
end

local titleContainer
local menuContainer
local menu
local itemsContext
local enchantmentContainer
local toEnchantContainer
local startContainer
local startButton
local availEnchantsList
local activeEnchantsList
local addButton
local removeButton
local itemsList

function showSelected()
    activeEnchantsList = mainContainer:addChild(GUI.list(31, 9, 15, 17, 2, 0, colors.lightBlue, colors.white, colors.blue, colors.white, colors.gray, 0xEEEEEE))
    for i,v in ipairs(selected) do
        activeEnchantsList:addItem(v.display_name)
        table.insert(toCraft, v)
    end
end

function removeSelected()
    mainContainer:removeChildren(tablelength(mainContainer.children))
    table.remove(selected, getSelectedIndex(activeEnchantsList.selected))
    toCraft = {}
    showSelected()
end

function clearSelected()
    selected = {}
    toCraft = {}
    showSelected()
end

function openEnchantments()
    clearSelected()
    availEnchantsList = mainContainer:addChild(GUI.list(2, 9, 15, 17, 2, 0, colors.lightBlue, colors.white, colors.blue, colors.white, colors.gray, 0xEEEEEE))
    for k,v in pairs(craftables[currentItemType]) do
        availEnchantsList:addItem(v.display_name).onTouch = function()
            table.insert(selected, v)
        end
    end
    mainContainer:drawOnScreen(true)
end

titleContainer = mainContainer:addChild(GUI.container(1,1,mainContainer.width, rowHeight))
titleContainer:addChild(GUI.panel(titleContainer.x + 1,titleContainer.y + 2,titleContainer.width - 2, titleContainer.height - 1, colors.lightGray))
titleContainer:addChild(GUI.text(titleContainer.x + 2,titleContainer.y + 2, colors.blue, "Automatic Mana Enchanter"))
titleContainer:addChild(GUI.text(titleContainer.x + 10,titleContainer.y + 3, colors.blue, "For public use from Arketec Industries™"))

itemsList = mainContainer:addChild(GUI.list(2, 6, mainContainer.width - 2, 2, 2, 0, 0xE1E1E1, 0x4B4B4B, 0xE1E1E1, 0x4B4B4B, 0x696969, 0xFFFFFF, true))
itemsList:setDirection(GUI.DIRECTION_HORIZONTAL)
itemsList:setAlignment(GUI.ALIGNMENT_HORIZONTAL_CENTER, GUI.ALIGNMENT_VERTICAL_TOP)
for k,v in pairs(craftables) do
    itemsList:addItem(firstToUpper(k)).onTouch = function()
        currentItemType = k
        openEnchantments()
    end
end

addButton = mainContainer:addChild(GUI.roundedButton(19, 10, 10, 3, colors.red, colors.white, colors.blue, colors.lightGray, "Add >"))
addButton.onTouch = showSelected
removeButton = mainContainer:addChild(GUI.roundedButton(19, 18, 10, 3, colors.blue, colors.white, colors.red, colors.lightGray, "< Remove"))
removeButton.onTouch = removeSelected

mainContainer:addChild(GUI.panel(50,14,29, 5, colors.lightGray))
mainContainer:addChild(GUI.text(51,14, colors.black, "Instructions:"))
mainContainer:addChild(GUI.text(53,15, colors.black, "1. Right-click item"))
mainContainer:addChild(GUI.text(53,16, colors.black, "2. Add enchantments"))
mainContainer:addChild(GUI.text(53,17, colors.black, "3. Right-click Enchant!"))
mainContainer:addChild(GUI.text(53,18, colors.black, "Contact Arketec if issues"))

mainContainer:addChild(GUI.roundedButton(52, 20, 20, 5, colors.red, colors.white, colors.blue, colors.lightGray, "Enchant!")).onTouch = start
mainContainer:addChild(GUI.button(mainContainer.width - 5, 1, 5, 1, colors.black, colors.gray, colors.blue, colors.lightGray, "Exit")).onTouch = function()
    mainContainer:stopEventHandling()
end

mainContainer:drawOnScreen(true)
mainContainer:startEventHandling()
