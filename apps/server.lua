local event = require('event')
local component = require("component")
local m = component.modem
local req = component.internet.request
local random = math.random
local data = component.data
local serialization = require('serialization')
local computer = require('computer')
local term = require('term')
local json = require('json')
local char_space  = string.byte(' ')
local char_t = string.byte('t')
local running = true
local accounts = {}
local account_path = '/home/accounts.csv'
local payday_path = '/home/next_payday.txt'
local xMax,yMax = term.gpu().getResolution()

local weeklyAllowence = 100


local function try(f, f_catch, ...)
    local status, e = pcall(f, ...)
    if (not status) then
        if (f_catch ~= nil) then
            f_catch(e)
        end
    end
    return status
end
local function split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
          table.insert(t,cap)
       end
       last_end = e+1
       s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
       cap = str:sub(last_end)
       table.insert(t, cap)
    end
    return t
 end
local function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end
local function save(path, data)
    local file = io.open(path, 'w')
    file:write(data)    
    file:close()
end
local function log(msg)
  local file = io.open('/var/log/server_log.txt', 'a')
  file:write(msg)
  file:close()
end
local function try_save(path, data, errorHandler)
    return try(save, errorHandler, path, data)
end
local function read(path)
    if (not file_exists(path)) then
        return nil
    else
        local s = ""
        for line in io.lines(path) do            
            s = s .. line
        end
        return s
    end
end
local ser = serialization.serialize
local deser = serialization.unserialize
--[[
    Program functions
]]--
local function loadAccounts()
    accounts = deser(read(account_path))
end
local function updateAccount(name, hash)
    accounts[name] = data.encode64(hash)
    if not try_save(account_path, ser(accounts)) then
        return false
    end
    return true
end
local function validateAccount(name, hash)
    return accounts[name] == data.encode64(hash)
end

local function getRealDate()
  local res = req('http://api.geonames.org/timezoneJSON?lat=47.01&lng=10.2&username=arketec')
  res.finishConnect()
  local result = ""
  local chunk = res.read()
  while (chunk ~= nil) do
    result = result .. chunk
    chunk = res.read()
  end
  local _, n = string.find(result,'time\"')
  
  local day = result:sub(n + 3, n+18)
  return day
end

local payday = read(payday_path)
local function getPayday()
  return payday
end

local function getSeconds(dateStr)
  local date = dateStr:sub(1,10)
  local time = dateStr:sub(12,15)
  print(dateStr)
  local daySplit = split(date,'-')
  local timeSplit = split(time,':')
  --for _,v in ipairs(dayTimeSplit) do print(v) end
  local day = daySplit[3]
  --local timeSplit = split(dayTimeSplit[2],':')
  local hour = timeSplit[1]
  local min = timeSplit[2]
  local month = daySplit[2]
  local year = daySplit[1]
  
  return os.time{day=day, year=year, month=month, hour = hour, minute = min}
end

local function getRealDateDiff(date)
  local paySecs = getSeconds(getPayday())
  return os.difftime(paySecs,date)
end

local function checkAllowence(date)
  if (date == nil) then return true end
  return getRealDateDiff(date) >=0
end
local function withdrawCoins(amount)
    local msg = ('withdrawing ' .. amount .. ' coins')
  print(msg)
  log(msg)
end
local function isExistingUser(name)
    return accounts[name] ~= nil
end

local function openCmd(prompt)
  local currentPosX, currentPosY = term.getCursor()
  term.setCursor(1,yMax)
  if (prompt == nil) then
    prompt = ">:"
  end
  term.write(prompt)
  term.setCursor(#prompt + 1, yMax)
  local inp =  term.read({nowrap=true}):sub(1,-2)
  
  term.setCursor(currentPosX,currentPosY)
  return inp
end

local function doCommandLoop()
  term.clear()
  local cmds = {
    "exit",
     "get_allowence_amount",
     "set_allowence_amount",
      "get_uptime",
      "get_accounts",
      "get_date",
      "get_next_payday",
      "set_next_payday",
      "list"
  }
  local cmdMode = true
  while cmdMode do
    local cmd = openCmd()
    if (cmd == cmds[1]) then
      cmdMode = false
    elseif (cmd == cmds[2]) then
      print(weeklyAllowence)
    elseif (cmd == cmds[3]) then
      local nextAmt = openCmd()
      weeklyAllowence = tonumber(nextAmt)
      print("set to " .. nextAmt)
    elseif (cmd == cmds[4]) then
      print(computer.uptime())
    elseif (cmd == cmds[5]) then
      for k,v in pairs(accounts) do print(k,v) end
    elseif (cmd == cmds[6]) then
      print(getRealDate())
      local lastPaid = openCmd("Enter lastPaid: ")
      if (lastPaid ~= '') then
        print(getRealDateDiff(lastPaid))
      end
    elseif (cmd == cmds[7]) then
      print(payday)
    elseif (cmd == cmds[8]) then
      payday = openCmd("Enter date: ")
      print(payday)
      save(payday_path, payday)
    elseif (cmd == cmds[#cmds]) then
      for k,v in ipairs(cmds) do print(v) end
    end
  end
  term.clear()
end


m.open(321)
function unknownEvent()
-- do nothing if the event wasn't relevant
    return true
end
local myEventHandlers = setmetatable({}, { __index = function() return unknownEvent end })
function myEventHandlers.modem_message(_, from, _, _, message)
    local atmData = deser(message)
    if (atmData.command == 'update_account') then
        local msg = ('Updating user: ' .. atmData.user)
        print(msg)
        log(msg)
        updateAccount(atmData.user, atmData.hash)
        m.send(from, 123, 'success')
    elseif (atmData.command == 'request_coins') then
        if (validateAccount(atmData.user, atmData.hash)) then
            withdrawCoins(atmData.amount)
            m.send(from, 123, 'success')
        else
            m.send(from, 123, 'ATM account is invalid')
        end
    elseif (atmData.command == 'is_existing') then
        if (isExistingUser(atmData.name)) then
            m.send(from, 123, 'Error: User: ' .. atmData.name .. ' already has an account')
        else
            m.send(from, 123, 'success')
        end
    elseif (atmData.command == 'check_allowence') then
        if (checkAllowence(atmData.lastPaid)) then
            return m.send(from, 123, ser({message = 'Weekly allowance added!', amount = 100, lastPaid = getSeconds(getRealDate())}))
        else
            return m.send(from, 123, ser({message = nil, amount = 0, lastPaid = getSeconds(getRealDate())}))
        end
    elseif (atmData.command == 'ping') then
        m.send(from, 123, 'success')
    else
        m.send(from, 123, 'Unrecognized command: ' .. atmData.command)
    end
    return true
end
function myEventHandlers.interrupted(...)
    return false
end
function myEventHandlers.key_up(adress, char, code, playerName)
    if (char == char_space) then
        return false
    end
    if (char == char_t) then
      doCommandLoop()
    end
    return true
end
-- The main event handler as function to separate eventID from the remaining arguments
function handleEvent(eventID, ...)
    if (eventID) then -- can be nil if no event was pulled for some time
        return myEventHandlers[eventID](...) -- call the appropriate event handler with all remaining arguments
    end
    return true
end
loadAccounts()
if (accounts == nil) then
    accounts = {}
end
-- main event loop which processes all events, or sleeps if there is nothing to do
while running do
    running = handleEvent(event.pull()) -- sleeps until an event is available, then process it
end
-- event.listen('modem_message', handleEvent)
-- event.listen('interrupt', handleEvent)