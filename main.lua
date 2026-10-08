-- SWILL Delta GUI + NoClip
-- Версия: 1.0.0
-- Дата: 26.09.2025
-- GitHub: https://github.com/<твой_юзер>/<репо>

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Загрузка конфига (локально или по URL)
local Config
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/<твой_юзер>/<репо>/main/config.lua"))()
    end)
    if ok and type(result) == "table" then
        Config = result
    else
        Config = {
            GuiName = "SWILL_Hub",
            Width = 200,
            Height = 120,
            TitleText = "SWILL",
            BackgroundColor = {15, 15, 20},
            AccentOn = {50, 200, 50},
            AccentOff = {200, 50, 50},
            CloseButtonColor = {40, 40, 45},
            TextColor = {240, 240, 240},
        }
    end
end

local function rgb(t) return Color3.fromRGB(t[1], t[2], t[3]) end

-- Состояние
local noClipEnabled = false

------------------------------------------------------------
-- NoClip
------------------------------------------------------------
local function applyNoClip()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

RunService.Stepped:Connect(function()
    if noClipEnabled then
        applyNoClip()
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if noClipEnabled then
        applyNoClip()
    end
end)

------------------------------------------------------------
-- GUI
------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = Config.GuiName
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, Config.Width, 0, Config.Height)
mainFrame.Position = UDim2.new(0.5, -Config.Width / 2, 0.5, -Config.Height / 2)
mainFrame.BackgroundColor3 = rgb(Config.BackgroundColor)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = Config.TitleText
titleLabel.TextColor3 = rgb(Config.TextColor)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -30, 0, 3)
closeButton.BackgroundColor3 = rgb(Config.CloseButtonColor)
closeButton.Text = "X"
closeButton.TextColor3 = rgb(Config.TextColor)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -40)
content.Position = UDim2.new(0, 10, 0, 35)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 6)
uiList.Parent = content
uiList.SortOrder = Enum.SortOrder.LayoutOrder

local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(1, 0, 0, 36)
noclipButton.BackgroundColor3 = rgb(Config.AccentOff)
noclipButton.Text = "NoClip: OFF"
noclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipButton.Font = Enum.Font.GothamSemibold
noclipButton.TextSize = 14
noclipButton.Parent = content

local noclipCorner = Instance.new("UICorner")
noclipCorner.CornerRadius = UDim.new(0, 6)
noclipCorner.Parent = noclipButton

noclipButton.MouseButton1Click:Connect(function()
    noClipEnabled = not noClipEnabled
    if noClipEnabled then
        noclipButton.Text = "NoClip: ON"
        noclipButton.BackgroundColor3 = rgb(Config.AccentOn)
        applyNoClip()
    else
        noclipButton.Text = "NoClip: OFF"
        noclipButton.BackgroundColor3 = rgb(Config.AccentOff)
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

------------------------------------------------------------
-- Перетаскивание
------------------------------------------------------------
local dragging, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)
