local button = require('button')
local colors = require('myColors')
local term = require('term')

local function testPrint(addr, cX, cY, mouseButton, playerName)
    term.setCursor(1,1)
    print("Hello from " .. addr)
    print("Clicked: X:" .. cX .. ", Y:" .. cY)
    print("button: " .. mouseButton)
end

local btn = button.new()
btn:init({xStart = 5, yStart = 5, width = 10, height = 5}, "Submit", {color = colors.red }, testPrint)

local btn2 = button.new()
btn2:init({xStart = 20, yStart = 5, width = 10, height = 5}, "New", {color = colors.blue }, testPrint)

term.clear()
btn:draw()
btn2:draw()
term.read()