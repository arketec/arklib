local component = require('component')
local colors = require('myColors')
local gpu = component.gpu

local xStart = 14 -- moves cursor to the right
local yStart = 9 -- moves cursor down
local height = 2 -- stretches cursor down
local width = 1  -- stretches cursor to the right
local maxHeight = 8

local color = gpu.getBackground()
gpu.setBackground(colors.red)
gpu.fill(xStart, yStart - height, width, height, ' ')
gpu.setBackground(color)