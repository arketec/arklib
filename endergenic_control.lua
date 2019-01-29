local lib = require ('arklib')
local component = require('component')
local generator_addresses = require('generators')
local event = require('event')
local os = require('os')
local capacitor = component.energy_device
local injector = component.rftools_pearl_injector
local ser = require('serialization')

local control = {
    maxEnergy = capacitor.getMaxEnergyStored(),
    currentEnergy = capacitor.getEnergyStored
}

function control.getCurrentEnergy()
    return control.currentEnergy()
end

function control.getCurrentEnergyPercent()
    return (control.currentEnergy() / control.maxEnergy)
end

function control.getGenerator(number)
    return component.proxy(generator_addresses[number])
end

function control.checkPosition(number)
    return control.getGenerator(number).getLastPearlPosition()
end

function control.checkCharge(number)
    return control.getGenerator(number).getChargeCycle()
end

function control.injectPearl()
    injector.injectPearl()
end

local running = true
local ticks = 0
event.listen('interrupted', function() running = false end)
event.listen('key_up', function() control.injectPearl() end)

local routines = {}


for j=1,10 do
    print(generator_addresses[j])
    control.getGenerator(j).startCharging()
    routines[j] = coroutine.create(function()
        while (running) do
            print('Generator ' .. i .. ' Charged for: ' .. control.checkCharge(i))
            control.getGenerator(j).firePearl()
            os.sleep(0.05)
            control.getGenerator(j).startCharging()
            coroutine.yield()
        end
    end)
    if (1 ~= 10) then
        os.sleep(0.05)
    end
end
control.injectPearl()

while (running) do
    for k=1,10 do
        event.timer(0.05, function() 
            coroutine.resume(routines[k])
        end, 100 )
    end
end


-- while (running) do
    
--     for i=1,10 do
--         -- while (control.getGenerator((i % 10) + 1).canReceive() == 0) do
--         --     print(control.getGenerator((i % 10) + 1).canReceive())
--         -- end
--         -- control.getGenerator(i).firePearl()
--         -- local pos = control.checkPosition(i)
--         -- if (pos ~= nil) then
--         --     print('Generator ' .. i .. ' Pearl arrived: ' .. pos)
--         -- end
--         -- local charge = control.checkCharge(i)
--         -- if (charge ~= nil) then
--         --     print('Generator ' .. i .. ' Charged for: ' .. control.checkCharge(i))
--         -- end
--         print('Generator ' .. i .. ' Mode: ' .. ser.serialize(control.getGenerator(i).getMode()))
--         print('Generator ' .. i .. ' Charged for: ' .. control.checkCharge(i))
--         local last = i -1
--         if last == 0 then
--             last = 10
--         end
--         local last2 = last - 1
--         if last2 == 0 then
--             last2 = 9
--         end
--         print('Generator ' .. last .. ' Mode: ' .. ser.serialize(control.getGenerator(last).getMode()))
--         print('Generator ' .. last .. ' Charged for: ' .. control.checkCharge(last))
--         print('Generator ' .. last2 .. ' Charged for: ' .. control.checkCharge(last2))
        
--         print(ticks)
--         os.sleep(0.01)
--         control.getGenerator(i).startCharging()
       
--     end
-- end

