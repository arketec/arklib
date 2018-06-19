local component = require('component')
local event = require('event')
local colors = require('myColors')
local try = require("try")

local gpu = component.gpu

local window = {}

local Window = {}

local function iterateGrid(grid, fcn)
    for _,cols in pairs(grid) do 
        for _,row in pairs(cols) do
            fcn(grid,cols,row)
        end
    end
end

local function printGrid(win)
    local lastBG = gpu.getBackground()
    local nextColor = colors.blue
    iterateGrid(win.grid, 
        function(_,_, row)
            if (nextColor == colors.blue) then
                nextColor = colors.white
            else
                nextColor = colors.blue
            end
            gpu.setBackground(nextColor)
            gpu.fill(row.X, row.Y, row.Width, row.Height, ' ')
        end
    )
    gpu.setBackground(lastBG)
end

function Window:create(options)
    local maxWidth, maxHeight = gpu.getResolution()
    self.numRows = options.numRows
    self.numCols = options.numCols
    self.maxWidth = math.floor(maxWidth)
    self.maxHeight = math.floor(maxHeight)
    self.elements = {}
    self.grid = {}

    -- config
    self.config = {
        showGrid = false
    }
    if (options.config.showGrid ~= nil) then
        self.config.showGrid = options.config.showGrid
    end

    local nextX = 1
    local nextY = 1
    local cellWidth = math.floor(self.maxWidth / self.numCols)
    local cellHeight = math.floor(self.maxHeight / self.numRows)

    local counter = 1
    for c=1, self.numCols do
        self.grid[c] = {}
        for r=1, self.numRows do
            self.grid[c][r] = {
                GridIndex = counter,
                X = nextX,
                Y = nextY,
                Width = cellWidth,
                Height = cellHeight,
                element = nil
            }
            nextX = nextX + cellWidth
            counter = counter + 1
        end
        nextX = 1
        nextY = nextY + cellHeight
    end

    --iterateGrid(self.grid, function(_, _,row) for k,v in pairs(row) do print(k,v) end end)
end

function Window:add(element, ...)
    local elemI = 1
    local args = {...}
    iterateGrid(self.grid, 
        function(_,_,row)   
            if (row.element == nil) then
                element:create({xStart = row.X, yStart = row.Y, width = row.Width, height = row.Height}, table.unpack(args))
                row.element = element
                return
            end
            elemI = elemI + 1
        end
    )
    self.elements[elemI] = element
end

function Window:draw()
    if (self.config.showGrid) then
        printGrid(self)
    end

    iterateGrid(self.grid,
        function(_,_,cell)
            if (cell.element ~= nil) then
                cell.element:draw()
            end
        end
    )
end

function Window:shapeGrid(gridShape)
    iterateGrid(self.grid,
        function(_,_,cell)
            local shape = gridShape[cell.GridIndex]
            if (shape ~= nil) then
                if (shape.X ~= nil) then
                    cell.X = shape.X
                end
                if (shape.Y ~= nil) then
                    cell.Y = shape.Y
                end
                if (shape.Width ~= nil) then
                    cell.Width = shape.Width
                end
                if (shape.Height ~= nil) then
                    cell.Height = shape.Height
                end
            end
        end
    )
end

function window.new()
    local win = {
        numRows = 0,
        numCols = 0,
        maxWidth = 0, 
        maxHeight = 0,
        elements = nil,
        grid = nil
    }
    setmetatable(win, { __index = Window })
    return win
end


return window