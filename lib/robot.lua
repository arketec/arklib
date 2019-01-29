local robot = {
    selected = 1,
    inv_size = 16,
    slots = {
        {
            index = 1,
            count = 0,
            item_name = nil
        },{
            index = 2,
            count = 0,
            item_name = nil
        },{
            index = 3,
            count = 0,
            item_name = nil
        },{
            index = 4,
            count = 0,
            item_name = nil
        },{
            index = 5,
            count = 0,
            item_name = nil
        },{
            index = 6,
            count = 0,
            item_name = nil
        },{
            index = 7,
            count = 0,
            item_name = nil
        },{
            index = 8,
            count = 0,
            item_name = nil
        },{
            index = 9,
            count = 0,
            item_name = nil
        },{
            index = 10,
            count = 0,
            item_name = nil
        },{
            index = 11,
            count = 0,
            item_name = nil
        },{
            index = 12,
            count = 0,
            item_name = nil
        },{
            index = 13,
            count = 0,
            item_name = nil
        },{
            index = 14,
            count = 0,
            item_name = nil
        },{
            index = 15,
            count = 0,
            item_name = nil
        },{
            index = 16,
            count = 0,
            item_name = nil
        }
    }
}

local function randDetect()
    local randInt = math.random(10)

    if (randInt == 6) then
        return true, 'solid'
    elseif (randInt == 7) then
        return false, 'entity'
    elseif (randInt == 8) then
        return true, 'replacable'
    elseif (randInt == 9) then
        return false, 'liquid'
    else
        return false, 'air'
    end
end

robot.name = function()
        return "TestRobot"
end
robot.detect = function()
    return randDetect()
end
robot.detectUp = function()
    return randDetect()
end
robot.detectDown = function()
    return randDetect()
end
robot.select = function(n)
    if (n ~= nil) then
        robot.selected = n
    end
    return robot.selected
end
robot.inventorySize = function()
    return robot.inv_size
end
robot.count = function(n)
    local i = robot.selected
    if (n ~= nil) then
        i = n
    end
    return robot.slots[i].count
end
robot.space = function(n)
    local i = robot.selected
    if (n ~= nil) then
        i = n
    end
    return 64 - robot.slots[i].count
end
robot.transferTo = function(s, c)
    if (robot.slots[s].count ~= 0) then
        return false
    end
    local d = robot.slots[robot.selected].count
    if (c ~= nil) then
        d = c
    end
    robot.slots[robot.selected].count = robot.slots[robot.selected].count - d
    local itemName = robot.slots[robot.selected].item_name
    if (robot.slots[robot.selected].count == 0) then
        robot.slots[robot.selected].item_name = nil
    end
    robot.slots[s].count = robot.slots[robot.selected].count + d
    robot.slots[s].name = itemName
    return true
end
robot.compare = function()
    return math.random() > 0.5
end
robot.compareUp = function()
    return math.random() > 0.5
end
robot.compareDown = function()
    return math.random() > 0.5
end
robot.drop = function(n)
    local d = robot.slots[robot.selected].count
    if (n ~= nil) then
        d = n
    end
    robot.slots[robot.selected].count = robot.slots[robot.selected].count - d
    if (robot.slots[robot.selected].count == 0) then
        robot.slots[robot.selected].item_name = nil
    end
    return true
end
robot.dropUp = function()
    return robot.drop()
end
robot.dropDown = function()
    return robot.drop()
end
robot.suck = function(n)
    local d = 64
    if (n ~= nil) then
        d = n
    end
    robot.slots[robot.selected].count = robot.slots[robot.selected].count + d
    if (robot.slots[robot.selected].count > 0) then
        robot.slots[robot.selected].item_name = 'minecraft:stone'
    end
    return true
end
robot.suckUp = function(n)
    return robot.suck(n)
end
robot.suckDown = function(n)
    return robot.suck(n)
end
robot.place = function(side,sneaky)
    return robot.detect()[2] == 'air'
end
robot.placeUp = function(side,sneaky)
    return robot.detect()[2] == 'air'
end
robot.placeDown = function(side,sneaky)
    return robot.detect()[2] == 'air'
end
robot.swing = function()
    return true
end
robot.swingUp = function()
    return true
end
robot.swingDown = function()
    return true
end
robot.use = function()
    return true
end
robot.useUp = function()
    return true
end
robot.useDown = function()
    return true
end
robot.forward = function()
    local blocked, s = robot.detect()
    if (blocked) then
        print("Cannot move: ".. s)
    else
        print("Moved forward")
    end
end
robot.back = function()
    local blocked, s = robot.detect()
    if (blocked) then
        print("Cannot move: ".. s)
    else
        print("Moved back")
    end
end
robot.up = function()
    local blocked, s = robot.detect()
    if (blocked) then
        print("Cannot move: ".. s)
    else
        print("Moved up")
    end
end
robot.down = function()
    local blocked, s = robot.detect()
    if (blocked) then
        print("Cannot move: ".. s)
    else
        print("Moved down")
    end
end
robot.turnRight = function()
    print("Turned right")
end
robot.turnLeft = function()
    print("Turned left")
end
robot.turnAround = function()
    print("Turned around")
end

return robot