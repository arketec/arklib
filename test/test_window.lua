local windows = require("window")
local component = require('component')
local term = require("term")
local colors = require('myColors')
local button = require('button')
local gpu = component.gpu
local maxWidth, maxHeight = gpu.getResolution()

local function testPrint(addr, cX, cY, mouseButton, playerName)
    term.setCursor(1,1)
    print("Hello from " .. addr)
    print("Clicked: X:" .. cX .. ", Y:" .. cY)
    print("button: " .. mouseButton)
end


local btn = button.new()
local window = windows.new()

window:create({numRows = 3, numCols = 3,config = {showGrid = true} })

window:shapeGrid({
    nil,nil,nil,
    nil,nil,{X = nil, Y = nil, Width = nil, Height = 5},
    nil,nil,{X = nil, Y =12, Width = nil, Height = 10}
})

window:add(btn, "Submit", {color = colors.red }, testPrint)


term.clear()
window:draw()