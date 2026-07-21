local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Состояние полета
local flying = false
local flySpeed = 50
local maxSpeed = 5000

-- Таблица для отслеживания зажатых клавиш
local keys = {W = false, S = false, A = false, D = false, Space = false, LeftShift = false}

-- Создание UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Xeno_Fly_GUI"
ScreenGui.Parent = CoreGui

-- Главная панель
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 190)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Заголовок
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 210, 0, 30)
TitleLabel.Position = UDim2.new(0, 15, 0, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "XENO FLY HACK"
TitleLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- Кнопка Вкл/Выкл
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 210, 0, 35)
ToggleButton.Position = UDim2.new(0, 15, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 59, 48) -- Красный (выключен)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "ПОЛЕТ: ВЫКЛ"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

-- Текст скорости
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 210, 0, 25)
SpeedLabel.Position = UDim2.new(0, 15, 0, 95)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Text = "Скорость: " .. flySpeed
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 14
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = MainFrame

-- Кнопки изменения скорости (- / +)
local MinusButton = Instance.new("TextButton")
MinusButton.Size = UDim2.new(0, 100, 0, 30)
MinusButton.Position = UDim2.new(0, 15, 0, 130)
MinusButton.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
MinusButton.Font = Enum.Font.GothamBold
MinusButton.Text = "-10"
MinusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusButton.TextSize = 14
MinusButton.Parent = MainFrame
Instance.new("UICorner", MinusButton).CornerRadius = UDim.new(0, 6)

local PlusButton = Instance.new("TextButton")
PlusButton.Size = UDim2.new(0, 100, 0, 30)
PlusButton.Position = UDim2.new(0, 130, 0, 130)
PlusButton.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
PlusButton.Font = Enum.Font.GothamBold
PlusButton.Text = "+250"
PlusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusButton.TextSize = 14
PlusButton.Parent = MainFrame
Instance.new("UICorner", PlusButton).CornerRadius = UDim.new(0, 6)

-- Отслеживание нажатий клавиатуры (ПК / Эмуляторы)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then keys.W = true end
    if input.KeyCode == Enum.KeyCode.S then keys.S = true end
    if input.KeyCode == Enum.KeyCode.A then keys.A = true end
    if input.KeyCode == Enum.KeyCode.D then keys.D = true end
    if input.KeyCode == Enum.KeyCode.Space then keys.Space = true end
    if input.KeyCode == Enum.KeyCode.LeftShift then keys.LeftShift = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then keys.W = false end
    if input.KeyCode == Enum.KeyCode.S then keys.S = false end
    if input.KeyCode == Enum.KeyCode.A then keys.A = false end
    if input.KeyCode == Enum.KeyCode.D then keys.D = false end
    if input.KeyCode == Enum.KeyCode.Space then keys.Space = false end
    if input.KeyCode == Enum.KeyCode.LeftShift then keys.LeftShift = false end
end)

-- Логика полета
RunService.RenderStepped:Connect(function(dt)
    if not flying then return end
    
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if root and humanoid then
        -- Отключаем стандартное падение анимации
        root.Velocity = Vector3.new(0, 0, 0)
        
        -- Вычисление направления движения относительно камеры
        local moveDirection = Vector3.new(0, 0, 0)
        
        if keys.W then moveDirection = moveDirection + camera.CFrame.LookVector end
        if keys.S then moveDirection = moveDirection - camera.CFrame.LookVector end
        if keys.A then moveDirection = moveDirection - camera.CFrame.RightVector end
        if keys.D then moveDirection = moveDirection + camera.CFrame.RightVector end
        if keys.Space then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if keys.LeftShift then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
        
        -- Перемещение персонажа
        if moveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (moveDirection.Unit * flySpeed * dt)
        end
    end
end)

-- Переключение полета кнопкой
ToggleButton.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(52, 199, 89) -- Зеленый
        ToggleButton.Text = "ПОЛЕТ: ВКЛ"
        
        -- Смягчаем физику, чтобы персонаж не падал камнем вниз
        pcall(function()
            player.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 59, 48) -- Красный
        ToggleButton.Text = "ПОЛЕТ: ВЫКЛ"
        
        -- Возвращаем обычную физику
        pcall(function()
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
end)

-- Логика изменения скорости
MinusButton.MouseButton1Click:Connect(function()
    if flySpeed > 10 then
        flySpeed = flySpeed - 10
        SpeedLabel.Text = "Скорость: " .. flySpeed
    end
end)

PlusButton.MouseButton1Click:Connect(function()
    if flySpeed < maxSpeed then
        flySpeed = math.min(flySpeed + 250, maxSpeed)
        SpeedLabel.Text = "Скорость: " .. flySpeed
    end
end)

