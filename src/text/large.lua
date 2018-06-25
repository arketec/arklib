local component = require('component')
local try = require('src.util.try')
local letters = require("src.text.letters")

local gpu = component.gpu

local lHeight = 5
local lWidth = 3
local lStep = 4

local function draw(x, y, color, pixAr) 
    local bg = gpu.getBackground();
    for i=1, lHeight do
        for j=1, lWidth do
            local pixel = pixAr[i][j]
            if (j == 4 or pixel == 0) then
                gpu.setBackground(bg);
            else
                gpu.setBackground(color);
            end
            gpu.fill(x + j,y + i,1,1,' ')
        end
    end
    gpu.setBackground(bg);
end

local large = {}
local LargeText = {
    X = 0,
    Y = 0,
    color = 0
}

function LargeText:create(x,y,color)
    self.X = x
    self.Y = y
    self.color = color
    self.posX = 0
    self.posY = 0
    self.value = nil
end

function LargeText:print(s)
    self.value = s
    local letterMap = {
        A = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.A) end,
        B = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.B) end,
        C = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.C) end,
        D = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.D) end,
        E = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.E) end,
        F = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.F) end,
        G = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.G) end,
        H = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.H) end,
        I = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.I) end,
        J = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.J) end,
        K = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.K) end,
        L = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.L) end,
        M = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.M) end,
        N = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.N) end,
        O = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.O) end,
        P = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.P) end,
        Q = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.Q) end,
        R = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.R) end,
        S = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.S) end,
        T = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.T) end,
        U = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.U) end,
        V = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.V) end,
        W = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.W) end,
        X = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.X) end,
        Y = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.Y) end,
        Z = function () draw(self.X + self.posX, self.Y + self.posY, self.color, letters.Z) end,
    }

    s:gsub('.', function(c)
        letterMap[c]()
        self.posX = self.posX + lStep
    end)

    self.posX = 0
    self.posY = 0
end

function large.new()
    local l = {
        X = 0,
        Y = 0,
        color = 0,
        posX = 0,
        posY = 0,
        value = nil
    }
    setmetatable(l, { __index = LargeText })
    return l
end

return large;
