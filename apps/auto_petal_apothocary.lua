local component = require('component')

local REDSTONE_TICK = 0.1
local GAME_TICK = 0.05
local sides = {
    bottom = 0,
    top = 1,
    north = 2,
    south = 3,
    west = 4,
    east = 5
}

local seed_address = 'f6ae51b4-5462-4e2b-ad8a-3ffde6f5c49c'
local ingredients = require('apothocary_ingredients')
local recipes = require('recipes')

local function printHelp()
    print('Usage: ./auto_apothocary [nameOrNumber] (quantity)')
    print(' nameOrNumber    The name or number of the receipe to create')
    print(' quantity    The optional amount of the receipe to create')
end

local function getReceipeByNumber(n)
    local rtnVal = nil
    for k,v in pairs(recipes) do
        if (v.number == n) then
            rtnVal = k
        end
    end
    return rtnVal;
end

local function sortRecipes()
    local sorted = {}
    for rNum = 1, 39, 1 do
        local name = getReceipeByNumber(rNum)
        table.insert(sorted, { name = name, type = recipes[name].type})
    end
    return sorted
end

local function printTypes()
    print('all')
    print('basic')
    print('generating')
    print('functional')
end

local function printReceipes(t)
    local sorted = sortRecipes()
    for i,v in ipairs(sorted) do
        if (t == v.type or t == 'all') then
            print(i .. ') ' .. v.name, v.type)
        end
    end
end

local function turnOn(add)
    local rs = component.proxy(add)
    rs.setOutput(sides.bottom,1)
    rs.setOutput(sides.north,1)
    rs.setOutput(sides.south,1)
end

local function turnOff(add)
    local rs = component.proxy(add)
    rs.setOutput(sides.bottom,0)
    rs.setOutput(sides.north,0)
    rs.setOutput(sides.south,0)
end

local function dropSeed()
    turnOn(seed_address)
    os.sleep(REDSTONE_TICK)
    turnOff(seed_address)
end

local function makeOne(name)
    for _,v in ipairs(recipes[name]['items'] ) do

        turnOn(v)
        os.sleep(REDSTONE_TICK)
        turnOff(v)
        os.sleep(REDSTONE_TICK)
    end
    dropSeed()
end

local function create(name, quant)
    if (quant == nil) then
        quant = 1
    end
    local key = name
    if (tonumber(name) ~= nil) then
        key = getReceipeByNumber(tonumber(name))
    end
    print('Creating ' .. quant .. ' ' .. key)
    for count = 1, quant, 1 do
        print('Start ' .. count)
        makeOne(key)
        os.sleep(5)
        print('Created!')
    end
    print('All finished!')
end

local args = {...}

if (args[1] == nil) then
    printHelp()
end

if (args[1] == 'list') then
    local type = 'generating'
    if (args[2] ~= nil) then
        type = args[2]
    end
    printReceipes(type)
else
    if (args[2] == nil) then
        create(args[1])
    else
        create(args[1], args[2])
    end
end