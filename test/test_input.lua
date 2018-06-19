local arklib = require('arklib')
local inputs = arklib.ui.input
local colors = arklib.ui.colors
local os = require('os')
local term = require('term')

local input = inputs.new();
input:create({xStart= 12, yStart= 12, width=15}, ':>')
input:draw()
input:update()

local c = 10
while c > 0 do
    os.sleep(3)
    input:draw()
    c = c -1
end
