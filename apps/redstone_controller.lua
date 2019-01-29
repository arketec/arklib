local r = component.proxy(component.list("redstone")())
local threshold = 7.0
local set = nil

function updateSide(inSide,outSide)
    local side = r.getInput(inSide)
    if (side > 0) then
        set = inSide
    end
    if (side < threshold) then 
        if (set == nil or set == inSide) then  
          r.setOutput(outSide, 15)
        end
    else 
        r.setOutput(outSide, 0)
    end
end

function sleep(timeout)
  local d = computer.uptime() + (timeout or 0)
  repeat
    computer.pullSignal(d - computer.uptime())
  until computer.uptime() >= d
end

local front = coroutine.create(function()
    while (true) do
        updateSide(3,2)
        coroutine.yield()
    end
end)

local back = coroutine.create(function()
    while (true) do
        updateSide(2,3)
        coroutine.yield()
    end
end)

local left = coroutine.create(function()
    while (true) do
        updateSide(5,4)
        coroutine.yield()
    end
end)

local right = coroutine.create(function()
    while (true) do
        updateSide(4,5)
        coroutine.yield()
    end
end)

while(true) do
  sleep(0.1)
  coroutine.resume(front)
  coroutine.resume(back)
  coroutine.resume(left)
  coroutine.resume(right)
end