_G.SpeedHackActive = false;
_G.TargetSpeed = 147; 
_G.CurrentSpeedInput = 0;

local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");

local ScreenGui = Instance.new("ScreenGui");
ScreenGui.Name = "ApexSpeedSmoothHub";
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui");
ScreenGui.ResetOnSpawn = false;

local MainFrame = Instance.new("Frame");
MainFrame.Parent = ScreenGui;
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24);
MainFrame.Position = UDim2.new(0.02, 0, 0.55, 0);
MainFrame.Size = UDim2.new(0, 240, 0, 150);
MainFrame.Active = true;
MainFrame.Draggable = true;
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8);

local Stroke = Instance.new("UIStroke", MainFrame);
Stroke.Thickness = 2;
Stroke.Color = Color3.fromRGB(255, 60, 60);

local Title = Instance.new("TextLabel");
Title.Parent = MainFrame;
Title.Size = UDim2.new(1, -30, 0, 32);
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 38);
Title.Text = "🔥 APEX HUB | SMOOTH SPEED";
Title.TextColor3 = Color3.fromRGB(255, 70, 70);
Title.Font = Enum.Font.FredokaOne;
Title.TextSize = 13;
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8);

local CloseBtn = Instance.new("TextButton");
CloseBtn.Parent = MainFrame;
CloseBtn.Size = UDim2.new(0, 30, 0, 32);
CloseBtn.Position = UDim2.new(1, -30, 0, 0);
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20);
CloseBtn.Text = "X";
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80);
CloseBtn.Font = Enum.Font.SourceSansBold;
CloseBtn.TextSize = 15;
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8);

local BtnToggle = Instance.new("TextButton");
BtnToggle.Parent = MainFrame;
BtnToggle.Size = UDim2.new(0.92, 0, 0, 40);
BtnToggle.Position = UDim2.new(0.04, 0, 0.28, 0);
BtnToggle.BackgroundColor3 = Color3.fromRGB(32, 32, 44);
BtnToggle.Text = "SMOOTH SPEED: OFF [Key: F]";
BtnToggle.TextColor3 = Color3.fromRGB(180, 180, 195);
BtnToggle.Font = Enum.Font.SourceSansBold;
BtnToggle.TextSize = 13;
Instance.new("UICorner", BtnToggle).CornerRadius = UDim.new(0, 6);

local SliderLabel = Instance.new("TextLabel");
SliderLabel.Parent = MainFrame;
SliderLabel.Size = UDim2.new(0.92, 0, 0, 20);
SliderLabel.Position = UDim2.new(0.04, 0, 0.62, 0);
SliderLabel.BackgroundTransparency = 1;
SliderLabel.Text = "ЛИМИТ: 147 КМ/Ч";
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200);
SliderLabel.Font = Enum.Font.SourceSansBold;
SliderLabel.TextSize = 12;
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left;

local SliderBackground = Instance.new("Frame");
SliderBackground.Parent = MainFrame;
SliderBackground.Size = UDim2.new(0.92, 0, 0, 8);
SliderBackground.Position = UDim2.new(0.04, 0, 0.82, 0);
SliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 50);
Instance.new("UICorner", SliderBackground).CornerRadius = UDim.new(0, 4);

local SliderButton = Instance.new("TextButton");
SliderButton.Parent = SliderBackground;
SliderButton.Size = UDim2.new(0, 16, 0, 16);
SliderButton.Position = UDim2.new(147 / 300, -8, 0.5, -8);
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60);
SliderButton.Text = "";
Instance.new("UICorner", SliderButton).CornerRadius = UDim.new(1, 0);

local function GetBikeRootPart()
    local char = LocalPlayer.Character;
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart;
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name ~= char.Name then
                local mainPart = obj.PrimaryPart or obj:FindFirstChild("DriveSeat") or obj:FindFirstChild("Body") or obj:FindFirstChildOfClass("BasePart");
                if mainPart and (mainPart.Position - hrp.Position).Magnitude < 6 then
                    return mainPart;
                end;
            end;
        end;
        return hrp;
    end;
    return nil;
end;

local dragging = false;
SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        dragging = true; 
    end;
end);

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        dragging = false; 
    end;
end);

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relativeX = input.Position.X - SliderBackground.AbsolutePosition.X;
        local percentage = math.clamp(relativeX / SliderBackground.AbsoluteSize.X, 0, 1);
        SliderButton.Position = UDim2.new(percentage, -8, 0.5, -8);
        _G.TargetSpeed = math.round(percentage * 300);
        SliderLabel.Text = "ЛИМИТ: " .. tostring(_G.TargetSpeed) .. " КМ/Ч";
    end;
end);

local SpeedLoop = nil;

local function TogglePhysicalSpeed()
    _G.SpeedHackActive = not _G.SpeedHackActive;
    
    if _G.SpeedHackActive then
        local bikePart = GetBikeRootPart();
        if bikePart then
            BtnToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 100);
            BtnToggle.Text = "SMOOTH SPEED: ACTIVE [Key: F]";
            
            if SpeedLoop then SpeedLoop:Disconnect(); end;
            _G.CurrentSpeedInput = 0;
            
            SpeedLoop = RunService.Heartbeat:Connect(function(deltaTime)
                if not _G.SpeedHackActive or not bikePart or not bikePart.Parent then
                    if SpeedLoop then SpeedLoop:Disconnect(); SpeedLoop = nil; end;
                    return;
                end;
                
                local isMovingForward = UserInputService:IsKeyDown(Enum.KeyCode.W);
                local isMovingBackward = UserInputService:IsKeyDown(Enum.KeyCode.S);
                
                if isMovingForward then
                    -- Мягкий накат скорости (Lerp алгоритм)
                    _G.CurrentSpeedInput = _G.CurrentSpeedInput + (_G.TargetSpeed - _G.CurrentSpeedInput) * 0.04;
                    -- Множитель 1.1 исправлен для точного совпадения со спидометром
                    local velocityVector = bikePart.CFrame.LookVector * (_G.CurrentSpeedInput * 1.1);
                    bikePart.AssemblyLinearVelocity = Vector3.new(velocityVector.X, bikePart.AssemblyLinearVelocity.Y, velocityVector.Z);
                elseif isMovingBackward then
                    _G.CurrentSpeedInput = _G.CurrentSpeedInput + (_G.TargetSpeed - _G.CurrentSpeedInput) * 0.04;
                    local velocityVector = -bikePart.CFrame.LookVector * (_G.CurrentSpeedInput * 1.1);
                    bikePart.AssemblyLinearVelocity = Vector3.new(velocityVector.X, bikePart.AssemblyLinearVelocity.Y, velocityVector.Z);
                else
                    -- Плавный сброс газа при отпускании кнопок
                    _G.CurrentSpeedInput = _G.CurrentSpeedInput + (0 - _G.CurrentSpeedInput) * 0.08;
                    if _G.CurrentSpeedInput > 1 then
                        local velocityVector = bikePart.CFrame.LookVector * (_G.CurrentSpeedInput * 1.1);
                        bikePart.AssemblyLinearVelocity = Vector3.new(velocityVector.X, bikePart.AssemblyLinearVelocity.Y, velocityVector.Z);
                    end;
                end;
            end);
        else
            _G.SpeedHackActive = false;
            BtnToggle.Text = "SIT ON THE BIKE FIRST!";
            task.wait(1);
            BtnToggle.Text = "SMOOTH SPEED: OFF [Key: F]";
        end;
    else
        BtnToggle.BackgroundColor3 = Color3.fromRGB(32, 32, 44);
        BtnToggle.Text = "SMOOTH SPEED: OFF [Key: F]";
        if SpeedLoop then SpeedLoop:Disconnect(); SpeedLoop = nil; end;
    end;
end;

CloseBtn.MouseButton1Click:Connect(function()
    _G.SpeedHackActive = false;
    if SpeedLoop then SpeedLoop:Disconnect(); SpeedLoop = nil; end;
    ScreenGui:Destroy();
end);

BtnToggle.MouseButton1Click:Connect(TogglePhysicalSpeed);

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then 
        TogglePhysicalSpeed(); 
    end;
end);
