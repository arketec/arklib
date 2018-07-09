local lib = require('arklib')
local ui = lib.ui
local window = ui.window
local button = ui.button
local colors = lib.constants.colors

local craftables = lib.assets.menu.craftables

local MainWindow = window.new()

MainWindow:create({numRows = 5, numCols = 5})

local breakfast = button.new()

MainWindow:add(breakfast, 'Breakfast',{color = colors.yellow}, function() 
    for k,v in ipairs(craftables.breakfast) do 
        print(v) 
    end 
end, print)

MainWindow:draw()