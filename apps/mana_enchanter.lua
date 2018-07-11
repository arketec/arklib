local component = require('component')
local term = require('term')
local event = require('event')
local me = component.me_controller

local args = {...}

local craftables = require('./craftables')
local toCraft = {}
local command = args[1]
local currentGroup = args[2]

function printUsage()
    print('Usage: ./enchanter [command] [type] {..args}')
    print('Commands:')
    print('  enchant - enchants item with listed enchantments')
    print('  list - show available enchantments for type')
    print('  help - show this prompt')
    print()
    print('Types: ')
    for k,v in pairs(craftables) do
        print('  ' .. k)
    end
    print()
    print('Examples: ')
    print('  ./enchanter list sword --> lists all sword enchantments')
    print('  ./enchanter enchant tools mending unbreaking fortune --> enchants tool with mending, unbreaking, and fortune')
end

function showConflict(name, attempted) 
    print(name .. ' conflicts with ' .. attempted)
end

function showTools()
    currentGroup = 'tools'
    for k,v in pairs(craftables.tools) do
        print(v.display_name, v.level)
    end
end

function showSword()
    currentGroup = 'sword'
    for k,v in pairs(craftables.sword) do
        print(v.display_name, v.level)
    end
end

function showBow()
    currentGroup = 'bow'
    for k,v in pairs(craftables.bow) do
        print(v.display_name, v.level)
    end
end

function showChest()
    currentGroup = 'chest'
    for k,v in pairs(craftables.chest) do
        print(v.display_name, v.level)
    end
end

function showLeggings()
    currentGroup = 'leggings'
    for k,v in pairs(craftables.leggings) do
        print(v.display_name, v.level)
    end
end

function showHelmet()
    currentGroup = 'helmet'
    for k,v in pairs(craftables.helmet) do
        print(v.display_name, v.level)
    end
end

function showBoots()
    currentGroup = 'boots'
    for k,v in pairs(craftables.boots) do
        print(v.display_name, v.level)
    end
end

function showAll()
    for k,v in pairs(craftables) do
        for j,w in pairs(v) do
            print(w.display_name, w.level)
        end
    end
end

function list(group)
    term.clear()
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

function start()
    print('crafting...')
    for i,v in ipairs(toCraft) do
        me.getCraftables({name = craftables[currentGroup][v].craft_name})[1].request()
    end
    os.sleep(40)
    print('..done!')
end

if (command == 'enchant') then
    for i,v in ipairs(args) do
        if (i > 2) then
            addToCraft(args[i])
        end
    end
    start()
elseif (command == 'list') then
    print('Enchantments available for ' .. currentGroup)
    list(currentGroup)
else
    printUsage()
end

os.sleep(2)
print('Press any key to exit..')
while (not event.pull('key_up')) do
    os.sleep()
end

term.clear()