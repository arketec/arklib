component = require("component")
shell = require("shell")
side = require("sides")
t = require("term")
c = require("computer")
r = require("robot")
ser = require("serialization")
fs = require("filesystem")
inv = component.inventory_controller
gen = component.generator

version = "1.0.0"

local fns = {}

startpos = {x = 0, y = -1, z = 2}
pos = {x = 0, y = -1, z = 2}
fl = {pos = {}}
fl.pos[0] = {x = 0, y = 0, z = 1}
fl.pos[1] = {x = -1, y = 0, z = 0}
fl.pos[2] = {x = 0, y = 0, z = -1}
fl.pos[3] = {x = 1, y = 0, z = 0}
fl.pos[4] = {x = 0, y = 0, z = 0}
fl.pos[5] = {x = 0, y = 1, z = 0}

cpos = {}
cpos.anlzer = {x = -1, y = 0, z = 1}
cpos.bin = {x = -1, y = 0, z = -1}
cpos.chest = {x = 1, y = 0, z = -1}

slot = {sticks = {}, fuel = 1, rake = 4, seeds = 5, seedsExtra = 6}
slot.sticks[1] = 2
slot.sticks[2] = 3

lang_noFuel = "Please insert a valid fuel in slot "..slot.fuel.."!"
lang_noSticks = "Please insert Crop Sticks in slot "..slot.sticks[1].." or "..slot.sticks[2].."!"
lang_noRake = "Please insert a Hand Rake in slot "..slot.rake.."!"
lang_noSeed = "Please insert ONLY 1 valid seeds in slot "..slot.seeds.."!"
lang_timeBtwGen = "Waiting time between generations: "
lang_curGen = "Current generation: "
lang_line = "---------------------------------------"

fns.noFuel = function()
	while not gen.insert(1) do
		t.clear()
		t.setCursor(1,1)
		t.write(lang_noFuel)
		os.sleep(1)
	end
	t.clear()
	return true
end
noFuel = fns.noFuel
 fns.noSticks = function()
	while not tidySticks() do
		t.clear()
		t.setCursor(1,1)
		t.write(lang_noSticks)
		os.sleep(1)
	end
	t.clear()
	return true
end
noSticks = fns.noSticks
fns.noRake = function()
	while not compareItemInSlot("agricraft:rake",slot.rake) do
		t.clear()
		t.setCursor(1,1)
		t.write(lang_noRake)
		os.sleep(1)
	end
	t.clear()
	return true
end
noRake = fns.noRake 
fns.noSeeds = function()
	while not checkCount(slot.seeds,1) do
		t.clear()
		t.setCursor(1,1)
		t.write(lang_noSeed)
		os.sleep(1)
	end
	if seeds() >= 1 then
		t.clear()
		return true
	else
		noSeeds()
	end
end
noSeeds = fns.noSeeds

fns.compareItemInSlot = function(item,slot) -- Compares $item with the item in $slot
    itemInfo = inv.getStackInInternalSlot(slot)
	if itemInfo ~= nil then --If $slot has item
		--print("Comparing: "..item.." AND: "..itemInfo.name)
		if item == itemInfo.name then -- If $item matches item name in $slot
			return true
		end
	end
	return false
end
compareItemInSlot = fns.compareItemInSlot
fns.checkCount = function(slot,count)
	itemInfo = inv.getStackInInternalSlot(slot)
	if itemInfo ~= nil and itemInfo.size >= count then
		return true
	end
	return false
end
checkCount = fns.checkCount
fns.count = function(slot)
	itemInfo = inv.getStackInInternalSlot(slot)
	if itemInfo ~= nil then 
		return itemInfo.size 
	end
	return 0 
end
count = fns.count
fns.transferItem = function(fromSlot,toSlot)
	lastSl = r.select(fromSlot)
	r.transferTo(toSlot,64)
	r.select(lastSl)
end
transferItem = fns.transferItem

fns.isEquipEmpty = function()
  lastSl = r.select(slot.seeds)
  inv.equip()
  if checkCount(slot.seeds,1) then
    return false
  end
  return true
end
isEquipEmpty = fns.isEquipEmpty
fns.putInAnlzer = function()
	lastSl = r.select(slot.seeds)
	succes = r.dropDown()
	r.select(lastSl)
	return succes
end
putInAnlzer = fns.putInAnlzer
fns.takeFromAnlzer = function()
	lastSl = r.select(slot.seeds)
	succes = inv.suckFromSlot(side.bottom,1)
	r.select(lastSl)
	return succes
end
takeFromAnlzer = fns.takeFromAnlzer
fns.analyze = function()
	move(cpos.anlzer)
	print("Analyzing")
	if putInAnlzer() then
		os.sleep(1.7)
		return takeFromAnlzer()
	end
	return false
end
analyze = fns.analyze
fns.fuel = function() -- Fuels Robot
	if c.energy() < 1000 then -- If energy is less than 1000 insters coal in generator
		lastSl = r.select(1) -- Selects slot 1 (Where fuel should be placed) and gets the previously selected slot
		if gen.insert(1) or noFuel() then -- Inserts fuel it in generator and test if it succeded
			r.select(lastSl) -- Selects prevously selected slot
			return true
		end
		r.select(lastSl) -- Selects prevously selected slot
		return false
	end
	return true -- When the energy is highter or equal than 1000
end
fuel = fns.fuel
fns.tidySticks = function()
	if compareItemInSlot("agricraft:crop_sticks",slot.sticks[1]) then
		return true
	else
		if compareItemInSlot("agricraft:crop_sticks",slot.sticks[2]) then
			transferItem(slot.sticks[2],slot.sticks[1])
			return true
		end
	end
	return false
end
tidySticks = fns.tidySticks
fns.sticks = function()
	if tidySticks() then
		return true
	end
	noSticks()
	return true
end
sticks = fns.sticks
fns.rake = function()
	if compareItemInSlot("agricraft:rake",slot.rake) then
		return true
	end
	noRake()
	return true
end
rake = fns.rake
fns.seeds = function()
	seedCount = count(slot.seeds)
	if seedCount >= 1 then
		if analyze() then
			return seedCount
		end
	end
	return 0
end
seeds = fns.seeds
fns.useRakeDown = function(slotArg)
	lastsl = r.select(slot.rake)
	inv.equip()
	r.useDown(side.bottom)
	transferItem(slot.rake,slotArg)
	inv.equip()
	r.select(lastsl)
end
useRakeDown = fns.useRakeDown
fns.placeStick = function(posTable,crossStick)
	move(posTable)
	lastSl = r.select(slot.sticks[1])
	if sticks() then
	r.swingDown(side.down)
		if crossStick then
			print("Placing Cross Sticks")
			r.select(slot.sticks[1])
			r.transferTo(15,1)
			r.select(15)
			inv.equip()
			r.useDown(side.bottom)
		end
		if sticks() then
			print("Placing Sticks")
			r.select(slot.sticks[1])
			r.transferTo(14,1)
			r.select(14)
			inv.equip()
			r.useDown(side.bottom)
		end
	end
	r.select(lastSl)
	return true
end
placeStick = fns.placeStick
fns.breakStick = function(posTable)
  move(posTable)
  return r.swingDown()
end
breakStick = fns.breakStick
fns.getSeedName = function()
	itemInfo = inv.getStackInInternalSlot(slot.seeds)
	return itemInfo.name
end
getSeedName = fns.getSeedName
fns.placeSeed = function(posTable)
	move(posTable)
	print("Placing Seeds")
	lastsl = r.select(slot.seeds)
	r.transferTo(13,1)
	r.select(13)
	inv.equip()
	r.useDown(side.bottom)
	while not isEquipEmpty() do
	  print("Removing weeds")
	  breakStick(posTable)
	  placeStick(posTable,false)
    lastsl = r.select(slot.seeds)
    r.transferTo(13,1)
    r.select(13)
    inv.equip()
    r.useDown(side.bottom)
	end
	r.select(lastsl)
end
placeSeed = fns.placeSeed
fns.replaceSeeds = function(posTable)
	print("Replacing Seeds")
	move(posTable)
	lastsl = r.select(slot.rake)
	--useRakeDown(slot.seedsExtra)
	placeSeed(posTable)
end
replaceSeeds = fns.replaceSeeds
fns.trashSeed = function(slot)
	print("Trashing")
	move(cpos.bin)
	lastSl = r.select(slot)
	succes = r.dropDown()
	r.select(lastSl)
	return succes
end
trashSeed = fns.trashSeed
fns.storeYeld = function()
	print("Storing Yelds")
	localSlot = slot.seedsExtra
	if not compareItemInSlot("minecraft:coal",1) and checkCount(1,1) then
		localSlot = 1
	end
	if not compareItemInSlot("agricraft:crop_sticks",2) and checkCount(2,1) then
		localSlot = 2
	end
	if not compareItemInSlot("agricraft:crop_sticks",3) and checkCount(3,1) then
		localSlot = 3
	end
	if not compareItemInSlot("agricraft:rake",4) and checkCount(4,1) then
		localSlot = 4
	end
	move(cpos.chest)
	lastSl = r.select(localSlot)
	succes = r.dropDown()
	r.select(lastSl)
end
storeYeld = fns.storeYeld
fns.waitForSeedToGrow = function()
	while count(slot.seeds) < 1 do
		move(fl.pos[5])
		toDelete = {empty = true}
		for i=5,16,1 do
		  if checkCount(i,1) and toDelete.empty then
		    --print("Trashing item in slot "..i)
		    toDelete.empty = false
		  end
		end
		if not toDelete.empty then
		  move(cpos.bin)
		  local lastSl = r.select(5)
		  for i=5,16,1 do
        local lastSl = r.select(i)
        r.dropDown()
		  end
		   r.select(lastSl)
		end
		os.sleep(sleepAmountWhenWachingSeeds)
		move(fl.pos[4])
		useRakeDown(slot.seeds)
		if count(slot.seeds) < 1 then
			r.swingDown(side.down)
			if count(slot.seeds) < 1 then
				placeStick(fl.pos[4],true)
			end
		end
		if not compareItemInSlot(seedName,slot.seeds) and checkCount(slot.seeds,1) then
			trashSeed(slot.seeds)
		end
	end
	return true
end
waitForSeedToGrow = fns.waitForSeedToGrow
fns.forward = function(n)
	if fuel() then -- Checks for fuel()
		for i=1,n do -- Executes r.forward() $n number of times
			r.forward() -- Moves the robot forward
		end
		return true
	end
	return false
end
forward = fns.forward
fns.back = function(n)
	if fuel() then -- Checks for fuel()
		for i=1,n do -- Executes r.back() $n number of times
			r.back() -- Moves the robot backwards
		end
		return true
	end
	return false
end
back = fns.back
fns.up = function(n)
	if fuel() then -- Checks for fuel()
		for i=1,n do -- Executes r.up() $n number of times
			r.up() -- Moves the robot upwards
		end
		return true
	end
	return false
end
up = fns.up
fns.down = function(n)
	if fuel() then -- Checks for fuel()
		for i=1,n do -- Executes r.down() $n number of times
			r.down() -- Moves the robot downwards
		end
		return true
	end
	return false
end
down = fns.down
fns.left = function(n)
	if fuel() then -- Checks for fuel()
		r.turnLeft() -- Turns the robot to the left
		for i=1,n do -- Executes r.forward() $n number of times
			r.forward() -- Moves the robot forward
		end
		r.turnRight() -- Turns the robot to the right
		return true
	end
	return false
end
left = fns.left
fns.right = function(n)
	if fuel() then -- Checks for fuel()
		r.turnRight() -- Turns the robot to the right
		for i=1,n do -- Executes r.forward() $n number of times
			r.forward() -- Moves the robot forward
		end
		r.turnLeft() -- Turns the robot to the left
		return true
	end
	return false
end
right = fns.right
fns.move = function(x,y,z)
	if y == nil then
		tbl = x
		--print("tbl "..tbl.x.." "..tbl.y.." "..tbl.z.." " )
		--print("tbl pos "..pos.x.." "..pos.y.." "..pos.z.." " )
		x = tbl.x - pos.x
		y = tbl.y - pos.y
		z = tbl.z - pos.z
		--print("tbl AFTER "..tbl.x.." "..tbl.y.." "..tbl.z.." " )
	else
		--print("not tbl "..x.." "..y.." "..z.." " )
		--print("not tbl pos "..pos.x.." "..pos.y.." "..pos.z.." " )
		x = x - pos.x
		y = y - pos.y
		z = z - pos.z
		--print("not tbl AFTER "..x.." "..y.." "..z.." " )
		--print("------------------------------------" )
	end
	if y > 0 then
		up(y)
		os.sleep(0.1)
	end
	if x > 0 then
		right(x)
		os.sleep(0.1)
	end
	if x < 0 then
		left(math.abs(x))
		os.sleep(0.1)
	end
	if z > 0 then
		back(z)
		os.sleep(0.1)
	end
	if z < 0 then
		forward(math.abs(z))
		os.sleep(0.1)
	end
	if y < 0 then
		down(math.abs(y))
		os.sleep(0.1)
	end
	pos.x = pos.x + x
	pos.y = pos.y + y
	pos.z = pos.z + z
end
move = fns.move

return fns