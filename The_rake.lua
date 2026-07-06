local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Настройки по умолчанию
local RakeESP_Enabled = true
local PlayersESP_Enabled = false

-- Создание интерфейса (защищен от удаления при смерти)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RakeRemastered_Gui"
ScreenGui.ResetOnSpawn = false
-- Пытаемся поместить в CoreGui, если не выходит — в PlayerGui
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Главная панель
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Позволяет перетаскивать меню мышкой
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "THE RAKE: ESP MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Кнопка: ESP на Рейка
local RakeButton = Instance.new("TextButton")
RakeButton.Name = "RakeButton"
RakeButton.Size = UDim2.new(0, 180, 0, 35)
RakeButton.Position = UDim2.new(0, 20, 0, 50)
RakeButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
RakeButton.Text = "RAKE ESP: ON"
RakeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RakeButton.TextSize = 14
RakeButton.Font = Enum.Font.SourceSansBold
RakeButton.Parent = MainFrame

local ButtonCorner1 = Instance.new("UICorner")
ButtonCorner1.CornerRadius = UDim.new(0, 6)
ButtonCorner1.Parent = RakeButton

-- Кнопка: ESP на Игроков
local PlayersButton = Instance.new("TextButton")
PlayersButton.Name = "PlayersButton"
PlayersButton.Size = UDim2.new(0, 180, 0, 35)
PlayersButton.Position = UDim2.new(0, 20, 0, 100)
PlayersButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PlayersButton.Text = "PLAYERS ESP: OFF"
PlayersButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayersButton.TextSize = 14
PlayersButton.Font = Enum.Font.SourceSansBold
PlayersButton.Parent = MainFrame

local ButtonCorner2 = Instance.new("UICorner")
ButtonCorner2.CornerRadius = UDim.new(0, 6)
ButtonCorner2.Parent = PlayersButton

-- Функция очистки ESP элементов
local function clearESP(model)
    if model:FindFirstChild("ESPHighlight") then model.ESPHighlight:Destroy() end
    local head = model:FindFirstChild("Head") or model:FindFirstChildWhichIsA("BasePart")
    if head and head:FindFirstChild("ESPName") then head.ESPName:Destroy() end
end

-- Функция создания ESP
local function applyHighlight(model, color, name)
    if model:FindFirstChild("ESPHighlight") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.Adornee = model
    highlight.Parent = model

    local head = model:FindFirstChild("Head") or model:FindFirstChildWhichIsA("BasePart")
    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPName"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = color
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
        
        label.Parent = billboard
        billboard.Parent = head
    end
end

-- Логика переключения кнопок
RakeButton.MouseButton1Click:Connect(function()
    RakeESP_Enabled = not RakeESP_Enabled
    if RakeESP_Enabled then
        RakeButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        RakeButton.Text = "RAKE ESP: ON"
    else
        RakeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        RakeButton.Text = "RAKE ESP: OFF"
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name:lower():find("rake") then clearESP(obj) end
        end
    end
end)

-- Переключатель для игроков
PlayersButton.MouseButton1Click:Connect(function()
    PlayersESP_Enabled = not PlayersESP_Enabled
    if PlayersESP_Enabled then
        PlayersButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        PlayersButton.Text = "PLAYERS ESP: ON"
    else
        PlayersButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        PlayersButton.Text = "PLAYERS ESP: OFF"
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then clearESP(p.Character) end
        end
    end
end)

-- Основной цикл обновления
task.spawn(function()
    while task.wait(1) do
        -- Обновление Рейка
        if RakeESP_Enabled then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and obj.Name:lower():find("rake") then
                    applyHighlight(obj, Color3.new(1, 0, 0), "⚠️ THE RAKE ⚠️")
                end
            end
        end

        -- Обновление Игроков
        if PlayersESP_Enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    applyHighlight(player.Character, Color3.new(0, 1, 0), player.Name)
                end
            end
        end
    end
end)
