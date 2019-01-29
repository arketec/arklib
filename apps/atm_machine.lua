local component = require("component")
local event = require("event")
local GUI = require('GUI')
local m = component.modem
local data = component.data
local exbus = component.me_exportbus
local ic = component.inventory_controller
local rs = component.redstone
local colors = require('colors')
local filesystem = require('filesystem')
local term = require('term')
local buffer = require("doubleBuffering")
local serialization = require('serialization')
local harddisk_addr = "ab772a22-e792-45e6-b6ff-a4185fdc99e8"
local openos_addr = "666dd744-45d6-428b-bf16-3519d6c4bae4"
local localDisks = {}
local atm_addr = nil
local currentAccount = nil
local amount = 0
local userLoggedOn = false
local keypadEntry = ""
local pinEntry = ''
local key = nil
local uname = ''

local function isArray(tbl)
  return tbl[1] ~= nil
end
local function isNumber(s)
  return tonumber(s) ~= nil
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
local function array_contains(tbl, value)
  for _,v in ipairs(tbl) do
    if (v == value) then return true end
  end
  return false
end
local function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
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
local function save(path, data)
    local file = io.open(path, 'w')
    file:write(data)    
    file:close()
end
local function loadLocalDisks()
  local fileStr = read('/home/localDisks.txt')
  for i,v in ipairs(split(fileStr,',')) do
    table.insert(localDisks, v)
  end
  local d = localDisks[2]
  local c = d
end
local ser = serialization.serialize
local deser = serialization.unserialize
local function recursivePrint(tbl)
  if (type(tbl) == 'function') then
    print("function")
    return
  end
  
  if (type(tbl) ~= 'table' ) then
    print(tbl)
    return
  end
  
  if (isArray(tbl)) then
    for i,v in ipairs(tbl) do
      recursivePrint(v)
   end
   return
  end
  for k,v in pairs(tbl) do
    recursivePrint(v)
   end
end
local function hashAccount()
  return data.sha256(ser(currentAccount))
end
local function updateServerHash()
  
  local d = {
    command = 'update_account',
    user = uname,
    hash = hashAccount()
  }
   m.broadcast(321, ser(d))
   local  _, _, from, port, _, message = event.pull(10, 'modem_message')
    
    if (message ~= 'success') then 
      if (message == nil) then
        GUI.alert('Server not responding')
        return false
      else
        GUI.alert(message)
      end
    end
    return true
end
local function saveAccount(atm)
  local encoded = data.encode64(ser(atm))
  local iv = data.random(16)
  local encrypted = data.encrypt(encoded, key, iv)
  local toSave = data.encode64(ser({
    Key = key,
    IV = iv,
    atm = encrypted
  }))
  save('/floppy/atm', toSave)
  if not updateServerHash() then
    return false
  end
  return true
end
local function loadAccount()
  filesystem.mount(atm_addr, '/floppy')
  local obfused = read('/floppy/atm')
  if (obfused == nil) then return nil end
  local encrypted = deser(data.decode64(obfused))
  key = encrypted.Key
  local decrypted = data.decrypt(encrypted.atm,key, encrypted.IV)
  atm =  deser(data.decode64(decrypted))
  return atm
end
local function clearScreen()
  buffer.clear(0x2D2D2D)
end
local mainContainer = GUI.fullScreenContainer()
local exitBtn = mainContainer:addChild(GUI.framedButton(mainContainer.width - 10, 1, 8, 3, 0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, "Exit"))
exitBtn.onTouch = function()
  m.close()
  mainContainer:stopEventHandling()
end
local loginCon = mainContainer:addChild(GUI.container(1,1,mainContainer.width, mainContainer.height))
local loginBtn = loginCon:addChild(GUI.framedButton(1,1, loginCon.width, loginCon.height, 0xFFFFFF, 0x555555, 0x880000,0xFFFFFF, "Scan Finger"))
local logoutCon = mainContainer:addChild(GUI.container(mainContainer.width - 15, mainContainer.height - 10, 12, 3))
local logoutBtn = logoutCon:addChild(GUI.framedButton(1,1, logoutCon.width, logoutCon.height, 0xFFFFFF, 0x555555, 0x880000,0xFFFFFF, "Log Out"))
local midX, midY = math.floor(mainContainer.width / 2), math.floor( mainContainer.height / 2)
local function validateUser(atm, name)
  if atm == nil then return false end
   return atm.name == name
end
local function checkPayday()
  m.broadcast(321, ser({
    command = 'check_allowence',
    user = uname,
    lastPaid = currentAccount.lastPaid,
    hash = hashAccount()
  }))
  local _, _, from, port, _, message = event.pull(10, 'modem_message')
  
  if (message ~= nil) then
    local pmtAmount = deser(message)
    if (pmtAmount.message ~= nil) then
      currentAccount.balance = currentAccount.balance + pmtAmount.amount --send request
      currentAccount.lastPaid = pmtAmount.lastPaid
      GUI.alert(pmtAmount.message)
    end
    return saveAccount(currentAccount)
  else
    return false
  end
end
local keypad = mainContainer:addChild(GUI.container(15, 5, mainContainer.width - 30, mainContainer.height - 10))
--local keypad = mainContainer:addChild(GUI.container((mainContainer.width /2) - 16, (mainContainer.height / 3) - 4, 30, 30))
--local keypad_bg = keypad:addChild(GUI.panel((mainContainer.width /2) - 8,(mainContainer.height / 3) - 8,keypad.width, 3, 0x262626))
local keypad_keys_layout = keypad:addChild(GUI.layout(1,1,keypad.width, keypad.height , 3, 5))
local keypad_display = keypad_keys_layout :addChild(GUI.label(1,1, 5, 3,0xFFFFFF, ""))
local keypadButtonW, keypadButtonH, keypadButtonColor, keypadTextColor = 30, 6, 0xD3D3D3, 0xD3D3D3
keypad_keys_layout:setPosition(1, 1, keypad_keys_layout :addChild(GUI.framedButton(1, 1, keypadButtonW, keypadButtonH, keypadButtonColor, keypadTextColor, 0xAAAAAA, 0x0, "1")))
keypad_keys_layout:setPosition(2, 1, keypad_keys_layout :addChild(GUI.framedButton(1, 1, keypadButtonW, keypadButtonH, keypadButtonColor, keypadTextColor, 0xAAAAAA, 0x0, "2")))
keypad_keys_layout:setPosition(3, 1, keypad_keys_layout :addChild(GUI.framedButton(1, 1, keypadButtonW, keypadButtonH, keypadButtonColor, keypadTextColor, 0xAAAAAA, 0x0, "3")))
keypad_keys_layout:setPosition(1, 2, keypad_keys_layout :addChild(GUI.framedButton(1, 1, keypadButtonW, keypadButtonH, keypadButtonColor, keypadTextColor, 0xAAAAAA, 0x0, "4")))
keypad_keys_layout:setPosition(2, 2, keypad_keys_layout :addChild(GUI.framedButton(1, 1, keypadButtonW, keypadButtonH, keypadButtonColor, keypadTextColor, 0xAAAAAA, 0x0, "5")))
keypad_keys_layout:setPosition(3, 2, keypad_keys_layout :addChild(GUI.framedButton(1, 1, keypadButtonW, keypadButtonH, keypadButtonColor, keypadTextColor, 0xAAAAAA, 0x0, "6")))
keypad_keys_layout:setPosition(1, 3, keypad_keys_layout :addChild(GUI.framedButton(1, 1, keypadButtonW, keypadButtonH, keypadButtonColor, keypadTextColor, 0xAAAAAA, 0x0, "7")))
keypad_keys_layout:setPosition(2, 3, keypad_keys_layout :addChild(GUI.framedButton(1, 1, keypadButtonW, keypadButtonH, keypadButtonColor, keypadTextColor, 0xAAAAAA, 0x0, "8")))
keypad_keys_layout:setPosition(3, 3, keypad_keys_layout :addChild(GUI.framedButton(1, 1, keypadButtonW, keypadButtonH, keypadButtonColor, keypadTextColor, 0xAAAAAA, 0x0, "9")))
keypad_keys_layout:setPosition(1, 4, keypad_keys_layout :addChild(GUI.framedButton(1, 1, keypadButtonW, keypadButtonH, keypadButtonColor, keypadTextColor, 0xAAAAAA, 0x0, "<")))
keypad_keys_layout:setPosition(2, 4, keypad_keys_layout :addChild(GUI.framedButton(1, 1, keypadButtonW, keypadButtonH, keypadButtonColor, keypadTextColor, 0xAAAAAA, 0x0, "0")))
keypad_keys_layout:setPosition(3, 4, keypad_keys_layout :addChild(GUI.framedButton(1, 1, keypadButtonW, keypadButtonH, keypadButtonColor, keypadTextColor, 0xAAAAAA, 0x0, "V")))
keypad_keys_layout:setPosition(2, 5, keypad_keys_layout :addChild(keypad_display))

local messageBox = mainContainer:addChild(GUI.container(15, mainContainer.height - 3, mainContainer.width -30, 3))
local message_display = messageBox:addChild(GUI.label(1,1,messageBox.width, messageBox.height, 0xFFFFFF, ""))
messageBox.hidden = true

local function getCoinCount()
  local ic_side = 4
  local count = 0
  for i=1,ic.getAllStacks(ic_side).count() do 
    if (ic.getSlotStackSize(ic_side, i) == nil) then 
      return count
    else
      count = count + ic.getSlotStackSize(ic_side, i)
    end
  end
  return count
end
local function depositToBank(total)
  
  local amtleft = total
  local waitTime = math.ceil(total / 64) * 1.5
  
  rs.setOutput(4,1)
  os.sleep(waitTime)
  
  rs.setOutput(4,0)
end
local function depositCoins()
  GUI.alert('STOP! Make sure your deposit is in the deposit chest before continuing')
  GUI.alert('Depositing coins. This may take a bit depending on amount')
  amount = getCoinCount()
  depositToBank(amount)
  currentAccount.balance = currentAccount.balance + amount
  return saveAccount(currentAccount)
end
local function calcExSlot(count, current)
  if (count % 64 == 0) then
    return current + 1
  else
    return current
  end
end
local function requestCoins()
  -- send request
  
  m.broadcast(321, ser({
    command ='request_coins',
    user = uname,
    amount = amount,
    hash = hashAccount()
  }))
  local _, _, from, port, _, message = event.pull(10, 'modem_message')
  
  if (message ~= "success") then 
    GUI.alert(message)
    return false
  else
  
  GUI.alert('Withdrawing coins. This may take a few minutes')
  local remain = amount
  local count = 0
  local currentSlot = 0
  while remain > 0 do
    currentSlot = calcExSlot(count, currentSlot)
    exbus.exportIntoSlot(4, currentSlot)
    remain = remain - 1
    count = count + 1
  end
  
    
    currentAccount.balance = currentAccount.balance - amount
    return saveAccount(currentAccount)
  end
end
local details = mainContainer:addChild(GUI.container(mainContainer.width - 25, 10, 20, 6))
details:addChild(GUI.panel(1,1,details.width,details.height,0x262626))
details:addChild(GUI.text(1,1,0xFFFFFF, "User: "))
details:addChild(GUI.text(1,2,0xFFFFFF, "Balance: "))
local userText = details:addChild(GUI.text(10,1,0xFFFFFF, 'none'))
local balanceText = details:addChild(GUI.text(10,2,0xFFFFFF,'$0'))
local function updateDetails()
  clearScreen()
  if (currentAccount ~= nil) then
    userText.text = currentAccount.name
    balanceText.text = tostring("$" .. currentAccount.balance)
  end
end
local mainMenu = mainContainer:addChild(GUI.container(mainContainer.width / 10, 20, 8 * (mainContainer.width / 10) , 20))
local function logout()
  mainMenu.hidden = true
  details.hidden = true
  logoutCon.hidden = true
  exitBtn.hidden = true
  userLoggedOn = false
  currentAccount = nil
end
local function hideMainMenu(signedIn)
  mainMenu.hidden = true
  details.hidden = true
  loginCon.hidden = signedIn
  clearScreen()
end
local timout
local timout_remain
local function showMainMenu()
  --loginCon:remove()
  loginCon.hidden = true 
  keypad.hidden = true
  logoutCon.hidden = false
  mainMenu.hidden = false
  details.hidden = false
  clearScreen()
  updateDetails()
  if (currentAccount ~= nil and currentAccount.name == 'Arketec') then
    exitBtn.hidden = false
  end
end
local keypadActive = false
keypad.hidden = true
local function printStars(len)
  local s = ''
  while len > 0 do 
    s = s .. '*'
    len = len - 1
  end
  return s
end
local function updateKeypadDisplay(prefix, obf)
  clearScreen()
  if (prefix == nil) then
    prefix = ''
  end
  keypad_display.text  = prefix .. keypadEntry
end
local function amountCallback() 
  keypadActive = false
  if (keypadEntry ~= '') then
     amount = tonumber(keypadEntry)
  else 
    amount = 0
  end
   
   if (amount <= currentAccount.balance) then
      if requestCoins() then
        GUI.alert("Withdrew $" .. amount .. ". Current balance: $" .. currentAccount.balance)
      end
   else 
      GUI.alert("Insufficient Funds. Current balance: $" .. currentAccount.balance)
   end
  amount = 0
  keypadEntry = ""
  updateKeypadDisplay()
  updateDetails()
  showMainMenu()
end
local amountKeyEntryCallback = function(v) 
  return function()
    keypadEntry = keypadEntry .. v.text 
    updateKeypadDisplay('$')
  end
end
local function amountBackCallback()
  keypadEntry = keypadEntry:sub(1, string.len(keypadEntry) -1)
  updateKeypadDisplay("$")
end
local function addKeypadTouchEvents(backCb, enterCb, keyCb)
  for i,v in ipairs(keypad_keys_layout.children) do 
    if (v.text == "<") then
      v.onTouch = backCb
    elseif (v.text == "V") then
       v.onTouch = enterCb
    else 
      v.onTouch = keyCb(v)
    end
  end
  keypad:drawOnScreen()
end
local function showKeypad(backCb, enterCb, keyCb)
  addKeypadTouchEvents(backCb, enterCb, keyCb)
  hideMainMenu(true)
  keypad.hidden = false
  keypadActive = true
end
local withdrawBtn = mainMenu:addChild(GUI.framedButton(1, 1, (mainMenu.width / 2) - 1, mainMenu.height, 0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, "Withdraw"))
withdrawBtn.onTouch = function()
  showKeypad(amountBackCallback, amountCallback, amountKeyEntryCallback)
end
local depositBtn = mainMenu:addChild(GUI.framedButton(mainMenu.width / 2, 1, (mainMenu.width / 2) - 1, mainMenu.height, 0x008000, 0x555555, 0x880000, 0xFFFFFF, "Deposit"))
depositBtn.onTouch = function()
  if depositCoins() then
    GUI.alert("Deposited $" .. amount .. ". Current balance: $" .. currentAccount.balance)
    amount = 0
  else
    GUI.alert('Error: Could not deposit. Please try again later')
    amount = 0
  end
  updateDetails()
end
logoutBtn.onTouch = function()
  hideMainMenu(false)
  logout()
  atm_addr = nil
end
local function createPIN()
  GUI.alert('Create PIN:')
  showKeypad()
end
local function createNewAccount(username, pid)
  m.broadcast(321, ser({
    command = 'is_existing',
    user = username,
    hash = hashAccount()
  }))
  local _, _, from, port, _, message = event.pull(10,"modem_message")
  if (message ~= "success") then
    GUI.alert(message)
    showMainMenu()
    logout()
    hideMainMenu()
    pinEntry = ''
    atm_addr = nil
    return
  end
  
  if (pid == '') then
    showMainMenu()
    logout()
    hideMainMenu(userLoggedOn)
  else
  
    local newAtm = {
      name = username,
      balance = 0,
      pin = pid,
      lastPaid = nil
    }
    
    key = data.random(16)
    
    if not saveAccount(newAtm) then
      showMainMenu()
      logout()
      hideMainMenu()
    else
    
      GUI.alert('New account created! User: ' .. username)
      currentAccount = newAtm
      userLoggedOn = true
      pinEntry = ''
      showMainMenu()
    end
  end
end
local function pinCreateCallback()
  keypadEntry = ""
  updateKeypadDisplay()  
  createNewAccount(uname, pinEntry)
  checkPayday()
  updateDetails()
end
local function pinValidateCallback()
    
      local decoded = loadAccount()
      if (validateUser(decoded, uname) and pinEntry == decoded.pin) then
          currentAccount = decoded
          userLoggedOn = true
          checkPayday()  
          
          keypadEntry = ""
          updateKeypadDisplay()
          userLoggedOn = true
          
          showMainMenu()
      else 
          if (not validateUser(decoded, uname)) then
            GUI.alert('Username does not match ATM Card')
            atm_addr = nil
          else
            GUI.alert("Invalid PIN.")
          end
          showMainMenu()
          logout()
          hideMainMenu(userLoggedOn)
      end
      pinEntry = ''
      keypadEntry = ''
      updateKeypadDisplay()
end
local function pinBackCallback()
  pinEntry = pinEntry:sub(1, string.len(pinEntry) -1)
  keypadEntry = printStars(string.len(pinEntry))
  updateKeypadDisplay()
end
local pinKeyEntryCallback = function(v) 
  return function()
    pinEntry = pinEntry .. v.text 
    keypadEntry = printStars(string.len(pinEntry))
    updateKeypadDisplay()
  end
end
loginBtn.onTouch = function(_,_,_, _, _, _,_, username)
  GUI.alert("Welcome " .. username .. "!")
 
  local retries = 3
  while atm_addr == nil do
    for v in (component.list("filesystem" )) do 
      if not array_contains(localDisks, v) then atm_addr = v end
    end
    if (atm_addr == nil) then
      retries = retries - 1
      GUI.alert('Please insert ATM card')
    end
    
    if (retries == 0) then
      GUI.alert("Max attempts used. Logging out")
      return
    end
  end
  
  uname = username
  atm = loadAccount()
  for k,v in pairs(atm) do print(k,v) end
  if (atm == nil) then
    GUI.alert('New user detected. Please create PIN:')
    showKeypad(pinBackCallback, pinCreateCallback, pinKeyEntryCallback)
  else
    pinEntry = ''
    showKeypad(pinBackCallback, pinValidateCallback, pinKeyEntryCallback)
  end
end
loadLocalDisks()
clearScreen()
logout()
m.open(123)
mainContainer:drawOnScreen(true)
mainContainer:startEventHandling()