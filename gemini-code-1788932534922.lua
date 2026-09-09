-- Cloneref
local getcloneref = cloneref or function(obj) return obj end

-- Services
local UserInputService = getcloneref(game:GetService("UserInputService"))
local Players = getcloneref(game:GetService("Players"))
local HttpService = getcloneref(game:GetService("HttpService"))
local TweenService = getcloneref(game:GetService("TweenService"))
local RunService = getcloneref(game:GetService("RunService"))
local ReplicatedStorage = getcloneref(game:GetService("ReplicatedStorage"))
local Workspace = getcloneref(game:GetService("Workspace"))
local StarterGui = getcloneref(game:GetService("StarterGui"))

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CurrentCamera = Workspace.CurrentCamera

---------------------------------------------------------
-- CONFIG SYSTEM
---------------------------------------------------------
local fileName = "CustomMenuConfig.json"

local settingsData = {
    toggleKey = "RightControl",
    chokeEnabled = false,
    chokeKey = "G",
    flyEnabled = false,
    flyKey = "F",
    flySpeed = 50,
    aimLockEnabled = false,
    aimLockKey = "T",
    aimLockMode = "Hold",
    silentAimEnabled = false,
    silentAimKey = "Y",
    noCooldownEnabled = true,
    fireRate = 5,
    wallCheck = true,
    healthCheck = true,
    showFOV = true,
    fovRadius = 170,
    fovColor = {255, 255, 255}
}

local function LoadSettings()
    if readfile and isfile and isfile(fileName) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and type(result) == "table" then
            for key, value in pairs(result) do
                settingsData[key] = value
            end
        end
    end
end

local function SaveSettings()
    if writefile then
        pcall(function()
            writefile(fileName, HttpService:JSONEncode(settingsData))
        end)
    end
end

LoadSettings()

---------------------------------------------------------
-- NOTIFICATION HELPER
---------------------------------------------------------
local function SendNotification(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 2
        })
    end)
end

---------------------------------------------------------
-- GUI CREATION
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomMenuGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 560)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Smooth Dragging
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Resizing Handle (Bottom Right Corner)
local ResizeButton = Instance.new("TextButton")
ResizeButton.Name = "ResizeButton"
ResizeButton.Size = UDim2.new(0, 16, 0, 16)
ResizeButton.Position = UDim2.new(1, -16, 1, -16)
ResizeButton.BackgroundTransparency = 1
ResizeButton.Text = "◢"
ResizeButton.TextColor3 = Color3.fromRGB(100, 100, 100)
ResizeButton.TextSize = 12
ResizeButton.ZIndex = 10
ResizeButton.Parent = MainFrame

local resizing = false
local resizeStartPos, startSize

ResizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStartPos = input.Position
        startSize = MainFrame.AbsoluteSize
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStartPos
        local newWidth = math.clamp(startSize.X + delta.X, 450, 900)
        local newHeight = math.clamp(startSize.Y + delta.Y, 400, 800)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -16)
Sidebar.Position = UDim2.new(0, 8, 0, 8)
Sidebar.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 8)
SidebarCorner.Parent = Sidebar

local TitleContainer = Instance.new("Frame")
TitleContainer.Name = "TitleContainer"
TitleContainer.Size = UDim2.new(1, 0, 0, 55)
TitleContainer.BackgroundTransparency = 1
TitleContainer.Parent = Sidebar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 20)
TitleLabel.Position = UDim2.new(0, 0, 0, 8)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "gremlin2 V∞"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleContainer

local SubTitleLabel = Instance.new("TextLabel")
SubTitleLabel.Size = UDim2.new(1, -10, 0, 26)
SubTitleLabel.Position = UDim2.new(0, 5, 0, 26)
SubTitleLabel.BackgroundTransparency = 1
SubTitleLabel.Text = "fuck XK5NG because of him, i am making my own version"
SubTitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitleLabel.TextSize = 9
SubTitleLabel.TextWrapped = true
SubTitleLabel.Font = Enum.Font.Gotham
SubTitleLabel.Parent = TitleContainer

local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 1, -60)
TabContainer.Position = UDim2.new(0, 0, 0, 60)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 2)
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.Parent = TabContainer

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -184, 1, -16)
ContentArea.Position = UDim2.new(0, 176, 0, 8)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local SectionTitle = Instance.new("TextLabel")
SectionTitle.Name = "SectionTitle"
SectionTitle.Size = UDim2.new(1, 0, 0, 30)
SectionTitle.Position = UDim2.new(0, 0, 0, 0)
SectionTitle.BackgroundTransparency = 1
SectionTitle.Text = "Main"
SectionTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
SectionTitle.TextSize = 18
SectionTitle.Font = Enum.Font.GothamMedium
SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
SectionTitle.Parent = ContentArea

local PagesContainer = Instance.new("Frame")
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, 0, 1, -35)
PagesContainer.Position = UDim2.new(0, 0, 0, 35)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = ContentArea

local tabs = {}

local function AddTab(tabName)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabName .. "TabBtn"
    TabBtn.Size = UDim2.new(1, -16, 0, 28)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
    TabBtn.TextSize = 13
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.Parent = TabContainer

    local Page = Instance.new("ScrollingFrame")
    Page.Name = tabName .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.Visible = false
    Page.Parent = PagesContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.Parent = Page

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Page.Visible = false
            t.Button.TextColor3 = Color3.fromRGB(130, 130, 130)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
        SectionTitle.Text = tabName
    end)

    local tabData = {Page = Page, Button = TabBtn}
    table.insert(tabs, tabData)

    if #tabs == 1 then
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
        SectionTitle.Text = tabName
    end

    return Page
end

local MainTab      = AddTab("Main")
local TargetTab    = AddTab("Target")
local NeckgrabsTab = AddTab("Neckgrabs")
local AutoBuyTab   = AddTab("AutoBuy")
local MiscTab      = AddTab("Misc")
local VisualTab    = AddTab("Visual")
local TeleportTab  = AddTab("Teleport")
local ExtraTab     = AddTab("Extra")

---------------------------------------------------------
-- TARGET CHECKS & FOV
---------------------------------------------------------
local FOVRadius = settingsData.fovRadius or 170
local FOVColorTable = settingsData.fovColor or {255, 255, 255}
local showFOVEnabled = settingsData.showFOV

local FOVCircle = nil
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = showFOVEnabled
    FOVCircle.Radius = FOVRadius
    FOVCircle.Filled = false
    FOVCircle.Thickness = 1
    FOVCircle.NumSides = 100
    FOVCircle.Color = Color3.fromRGB(FOVColorTable[1], FOVColorTable[2], FOVColorTable[3])
end)

local Target = nil
local TargetHighlight = nil

local function ClearTarget()
    Target = nil
    if TargetHighlight then
        TargetHighlight:Destroy()
        TargetHighlight = nil
    end
end

local function SetTarget(Player)
    if Target == Player then return end
    ClearTarget()
    if not Player or Player == LocalPlayer then return end

    Target = Player
    if Player.Character then
        local Highlight = Instance.new("Highlight")
        Highlight.Adornee = Player.Character
        Highlight.FillTransparency = 1
        Highlight.OutlineTransparency = 0
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.Parent = Player.Character
        TargetHighlight = Highlight
    end
end

local function IsVisible(targetPart)
    if not settingsData.wallCheck then return true end
    local camera = CurrentCamera
    if not camera then return true end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local excludeTable = {LocalPlayer.Character}
    if targetPart and targetPart.Parent then
        table.insert(excludeTable, targetPart.Parent)
    end
    rayParams.FilterDescendantsInstances = excludeTable
    rayParams.IgnoreWater = true

    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local result = Workspace:Raycast(origin, direction, rayParams)
    
    return result == nil
end

local function IsValidTarget(humanoid)
    if not settingsData.healthCheck then return true end
    if not humanoid or humanoid.Health <= 0 then return false end
    
    local char = humanoid.Parent
    if not char then return false end
    
    local bodyEffects = char:FindFirstChild("BodyEffects")
    if bodyEffects then
        local ko = bodyEffects:FindFirstChild("K.O") or bodyEffects:FindFirstChild("KO") or bodyEffects:FindFirstChild("Knocked")
        if ko and ko:IsA("BoolValue") and ko.Value == true then
            return false
        end
        local dead = bodyEffects:FindFirstChild("Dead")
        if dead and dead:IsA("BoolValue") and dead.Value == true then
            return false
        end
    end
    
    if char:GetAttribute("K.O") == true or char:GetAttribute("Knocked") == true or char:GetAttribute("Dead") == true then
        return false
    end
    
    if char:FindFirstChildOfClass("ForceField") then
        return false
    end

    if humanoid.PlatformStand then return false end
    
    local currentState = humanoid:GetState()
    if currentState == Enum.HumanoidStateType.Ragdoll or currentState == Enum.HumanoidStateType.Physics then
        return false
    end
    
    return true
end

local function GetTarget()
    local MousePosition = UserInputService:GetMouseLocation()
    local ClosestPlayer = nil
    local ClosestDistance = FOVRadius

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Head = Player.Character:FindFirstChild("Head") or Player.Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")

            if Head and Humanoid and IsValidTarget(Humanoid) then
                local checkVisibility = settingsData.wallCheck
                if not checkVisibility or IsVisible(Head) then
                    local Position, OnScreen = CurrentCamera:WorldToViewportPoint(Head.Position)
                    if OnScreen then
                        local Distance = (Vector2.new(Position.X, Position.Y) - MousePosition).Magnitude
                        if Distance <= ClosestDistance then
                            ClosestDistance = Distance
                            ClosestPlayer = Player
                        end
                    end
                end
            end
        end
    end
    return ClosestPlayer
end

---------------------------------------------------------
-- NO COOLDOWN / RAPID FIRE SYSTEM
---------------------------------------------------------
local MouseHolding = false
local noCooldownEnabled = settingsData.noCooldownEnabled
local fireRateVal = settingsData.fireRate or 5
local fullAutoVal = true

RunService.Heartbeat:Connect(function()
    if not noCooldownEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end

    local bodyEffects = char:FindFirstChild("BodyEffects")
    if bodyEffects then
        local ko = bodyEffects:FindFirstChild("K.O") or bodyEffects:FindFirstChild("KO") or bodyEffects:FindFirstChild("Knocked")
        if ko and ko.Value then return end
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local checkParents = {char}
    if backpack then table.insert(checkParents, backpack) end

    for _, Parent in ipairs(checkParents) do
        for _, Tool in ipairs(Parent:GetChildren()) do
            if Tool:IsA("Tool") and Tool:FindFirstChild("ShootingCooldown") and Tool:FindFirstChild("Handle") and Tool:FindFirstChild("Ammo") then
                if MouseHolding and Tool.Parent == char then
                    coroutine.wrap(function()
                        if fullAutoVal then
                            if not (Tool:FindFirstChild("GunClientAutomatic") or Tool:FindFirstChild("GunClientShotgun")) then
                                Tool:Activate()
                                RunService.RenderStepped:Wait()
                                Tool:Deactivate()
                            end
                        end
                    end)()
                end

                if getconnections and debug and debug.getinfo and debug.getupvalue and debug.setupvalue then
                    local Connections = getconnections(Tool.Activated)
                    if Connections then
                        for _, Connection in pairs(Connections) do
                            if typeof(Connection.Function) == "function" then
                                local Info = debug.getinfo(Connection.Function)
                                for UpvalueIndex = 1, Info.nups do
                                    local UpVal = debug.getupvalue(Connection.Function, UpvalueIndex)
                                    if type(UpVal) == "number" then
                                        debug.setupvalue(Connection.Function, UpvalueIndex, fireRateVal / 1000)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

---------------------------------------------------------
-- UI ELEMENTS (MAIN TAB)
---------------------------------------------------------
local aimLockEnabled = settingsData.aimLockEnabled
local aimLockKey = Enum.KeyCode[settingsData.aimLockKey] or Enum.KeyCode.T
local listeningForAimLockKey = false
local isAimLockActive = false
local aimLockMode = settingsData.aimLockMode or "Hold"

local silentAimEnabled = settingsData.silentAimEnabled
local silentAimKey = Enum.KeyCode[settingsData.silentAimKey] or Enum.KeyCode.Y
local listeningForSilentKey = false

local wallCheckEnabled = settingsData.wallCheck
local healthCheckEnabled = settingsData.healthCheck

-- Aim-Lock Row
local AimLockContainer = Instance.new("Frame")
AimLockContainer.Size = UDim2.new(1, -6, 0, 72)
AimLockContainer.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
AimLockContainer.Parent = MainTab

local ALCorner = Instance.new("UICorner")
ALCorner.CornerRadius = UDim.new(0, 4)
ALCorner.Parent = AimLockContainer

local ALLabel = Instance.new("TextLabel")
ALLabel.Size = UDim2.new(0.4, 0, 0, 36)
ALLabel.Position = UDim2.new(0, 10, 0, 0)
ALLabel.BackgroundTransparency = 1
ALLabel.Text = "Aim-Lock"
ALLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
ALLabel.TextXAlignment = Enum.TextXAlignment.Left
ALLabel.Font = Enum.Font.Gotham
ALLabel.TextSize = 12
ALLabel.Parent = AimLockContainer

local ALKeyBtn = Instance.new("TextButton")
ALKeyBtn.Size = UDim2.new(0, 40, 0, 22)
ALKeyBtn.Position = UDim2.new(1, -90, 0, 7)
ALKeyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ALKeyBtn.Text = aimLockKey.Name
ALKeyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
ALKeyBtn.Font = Enum.Font.GothamBold
ALKeyBtn.TextSize = 11
ALKeyBtn.Parent = AimLockContainer

local ALKeyCorner = Instance.new("UICorner")
ALKeyCorner.CornerRadius = UDim.new(0, 4)
ALKeyCorner.Parent = ALKeyBtn

local ALToggleFrame = Instance.new("TextButton")
ALToggleFrame.Size = UDim2.new(0, 40, 0, 20)
ALToggleFrame.Position = UDim2.new(1, -45, 0, 8)
ALToggleFrame.BackgroundColor3 = aimLockEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
ALToggleFrame.Text = ""
ALToggleFrame.AutoButtonColor = false
ALToggleFrame.Parent = AimLockContainer

local ALToggleCorner = Instance.new("UICorner")
ALToggleCorner.CornerRadius = UDim.new(1, 0)
ALToggleCorner.Parent = ALToggleFrame

local ALToggleCircle = Instance.new("Frame")
ALToggleCircle.Size = UDim2.new(0, 14, 0, 14)
ALToggleCircle.Position = aimLockEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
ALToggleCircle.BackgroundColor3 = aimLockEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)
ALToggleCircle.BorderSizePixel = 0
ALToggleCircle.Parent = ALToggleFrame

local ALCircleCorner = Instance.new("UICorner")
ALCircleCorner.CornerRadius = UDim.new(1, 0)
ALCircleCorner.Parent = ALToggleCircle

local ModeContainer = Instance.new("Frame")
ModeContainer.Size = UDim2.new(1, -16, 0, 26)
ModeContainer.Position = UDim2.new(0, 8, 0, 38)
ModeContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
ModeContainer.Parent = AimLockContainer

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 4)
ModeCorner.Parent = ModeContainer

local HoldBtn = Instance.new("TextButton")
HoldBtn.Size = UDim2.new(0.5, -2, 1, 0)
HoldBtn.Position = UDim2.new(0, 0, 0, 0)
HoldBtn.BackgroundTransparency = 1
HoldBtn.Text = "Hold"
HoldBtn.Font = Enum.Font.GothamBold
HoldBtn.TextSize = 11
HoldBtn.TextColor3 = (aimLockMode == "Hold") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 130, 130)
HoldBtn.Parent = ModeContainer

local ToggleModeBtn = Instance.new("TextButton")
ToggleModeBtn.Size = UDim2.new(0.5, -2, 1, 0)
ToggleModeBtn.Position = UDim2.new(0.5, 2, 0, 0)
ToggleModeBtn.BackgroundTransparency = 1
ToggleModeBtn.Text = "Toggle"
ToggleModeBtn.Font = Enum.Font.GothamBold
ToggleModeBtn.TextSize = 11
ToggleModeBtn.TextColor3 = (aimLockMode == "Toggle") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 130, 130)
ToggleModeBtn.Parent = ModeContainer

HoldBtn.MouseButton1Click:Connect(function()
    aimLockMode = "Hold"
    settingsData.aimLockMode = aimLockMode
    HoldBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleModeBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
    SaveSettings()
end)

ToggleModeBtn.MouseButton1Click:Connect(function()
    aimLockMode = "Toggle"
    settingsData.aimLockMode = aimLockMode
    ToggleModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    HoldBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
    SaveSettings()
end)

ALToggleFrame.MouseButton1Click:Connect(function()
    aimLockEnabled = not aimLockEnabled
    settingsData.aimLockEnabled = aimLockEnabled
    TweenService:Create(ALToggleCircle, TweenInfo.new(0.2), {Position = aimLockEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = aimLockEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)}):Play()
    TweenService:Create(ALToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = aimLockEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)}):Play()
    SaveSettings()
end)

ALKeyBtn.MouseButton1Click:Connect(function()
    listeningForAimLockKey = true
    ALKeyBtn.Text = "..."
    ALKeyBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
end)

-- No Cooldown / Rapid Fire Row
local NoCooldownContainer = Instance.new("Frame")
NoCooldownContainer.Size = UDim2.new(1, -6, 0, 36)
NoCooldownContainer.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
NoCooldownContainer.Parent = MainTab

local NC_Corner = Instance.new("UICorner")
NC_Corner.CornerRadius = UDim.new(0, 4)
NC_Corner.Parent = NoCooldownContainer

local NCLabel = Instance.new("TextLabel")
NCLabel.Size = UDim2.new(0.6, 0, 1, 0)
NCLabel.Position = UDim2.new(0, 10, 0, 0)
NCLabel.BackgroundTransparency = 1
NCLabel.Text = "No Cooldown / Rapid Fire"
NCLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
NCLabel.TextXAlignment = Enum.TextXAlignment.Left
NCLabel.Font = Enum.Font.Gotham
NCLabel.TextSize = 12
NCLabel.Parent = NoCooldownContainer

local NCToggleFrame = Instance.new("TextButton")
NCToggleFrame.Size = UDim2.new(0, 40, 0, 20)
NCToggleFrame.Position = UDim2.new(1, -45, 0.5, -10)
NCToggleFrame.BackgroundColor3 = noCooldownEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
NCToggleFrame.Text = ""
NCToggleFrame.AutoButtonColor = false
NCToggleFrame.Parent = NoCooldownContainer

local NCToggleCorner = Instance.new("UICorner")
NCToggleCorner.CornerRadius = UDim.new(1, 0)
NCToggleCorner.Parent = NCToggleFrame

local NCToggleCircle = Instance.new("Frame")
NCToggleCircle.Size = UDim2.new(0, 14, 0, 14)
NCToggleCircle.Position = noCooldownEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
NCToggleCircle.BackgroundColor3 = noCooldownEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)
NCToggleCircle.BorderSizePixel = 0
NCToggleCircle.Parent = NCToggleFrame

local NCCircleCorner = Instance.new("UICorner")
NCCircleCorner.CornerRadius = UDim.new(1, 0)
NCCircleCorner.Parent = NCToggleCircle

NCToggleFrame.MouseButton1Click:Connect(function()
    noCooldownEnabled = not noCooldownEnabled
    settingsData.noCooldownEnabled = noCooldownEnabled
    TweenService:Create(NCToggleCircle, TweenInfo.new(0.2), {Position = noCooldownEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = noCooldownEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)}):Play()
    TweenService:Create(NCToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = noCooldownEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)}):Play()
    SaveSettings()
end)

-- Health Check Row
local HealthCheckContainer = Instance.new("Frame")
HealthCheckContainer.Size = UDim2.new(1, -6, 0, 36)
HealthCheckContainer.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
HealthCheckContainer.Parent = MainTab

local HC_Corner = Instance.new("UICorner")
HC_Corner.CornerRadius = UDim.new(0, 4)
HC_Corner.Parent = HealthCheckContainer

local HCLabel = Instance.new("TextLabel")
HCLabel.Size = UDim2.new(0.6, 0, 1, 0)
HCLabel.Position = UDim2.new(0, 10, 0, 0)
HCLabel.BackgroundTransparency = 1
HCLabel.Text = "Health Check (Ignore Knocked)"
HCLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
HCLabel.TextXAlignment = Enum.TextXAlignment.Left
HCLabel.Font = Enum.Font.Gotham
HCLabel.TextSize = 12
HCLabel.Parent = HealthCheckContainer

local HCToggleFrame = Instance.new("TextButton")
HCToggleFrame.Size = UDim2.new(0, 40, 0, 20)
HCToggleFrame.Position = UDim2.new(1, -45, 0.5, -10)
HCToggleFrame.BackgroundColor3 = healthCheckEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
HCToggleFrame.Text = ""
HCToggleFrame.AutoButtonColor = false
HCToggleFrame.Parent = HealthCheckContainer

local HCToggleCorner = Instance.new("UICorner")
HCToggleCorner.CornerRadius = UDim.new(1, 0)
HCToggleCorner.Parent = HCToggleFrame

local HCToggleCircle = Instance.new("Frame")
HCToggleCircle.Size = UDim2.new(0, 14, 0, 14)
HCToggleCircle.Position = healthCheckEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
HCToggleCircle.BackgroundColor3 = healthCheckEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)
HCToggleCircle.BorderSizePixel = 0
HCToggleCircle.Parent = HCToggleFrame

local HCCircleCorner = Instance.new("UICorner")
HCCircleCorner.CornerRadius = UDim.new(1, 0)
HCCircleCorner.Parent = HCToggleCircle

HCToggleFrame.MouseButton1Click:Connect(function()
    healthCheckEnabled = not healthCheckEnabled
    settingsData.healthCheck = healthCheckEnabled
    TweenService:Create(HCToggleCircle, TweenInfo.new(0.2), {Position = healthCheckEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = healthCheckEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)}):Play()
    TweenService:Create(HCToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = healthCheckEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)}):Play()
    SaveSettings()
end)

-- Wall Check Row
local WallCheckContainer = Instance.new("Frame")
WallCheckContainer.Size = UDim2.new(1, -6, 0, 36)
WallCheckContainer.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
WallCheckContainer.Parent = MainTab

local WC_Corner = Instance.new("UICorner")
WC_Corner.CornerRadius = UDim.new(0, 4)
WC_Corner.Parent = WallCheckContainer

local WCLabel = Instance.new("TextLabel")
WCLabel.Size = UDim2.new(0.6, 0, 1, 0)
WCLabel.Position = UDim2.new(0, 10, 0, 0)
WCLabel.BackgroundTransparency = 1
WCLabel.Text = "Wall Check (Anti-Wall)"
WCLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
WCLabel.TextXAlignment = Enum.TextXAlignment.Left
WCLabel.Font = Enum.Font.Gotham
WCLabel.TextSize = 12
WCLabel.Parent = WallCheckContainer

local WCToggleFrame = Instance.new("TextButton")
WCToggleFrame.Size = UDim2.new(0, 40, 0, 20)
WCToggleFrame.Position = UDim2.new(1, -45, 0.5, -10)
WCToggleFrame.BackgroundColor3 = wallCheckEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
WCToggleFrame.Text = ""
WCToggleFrame.AutoButtonColor = false
WCToggleFrame.Parent = WallCheckContainer

local WCToggleCorner = Instance.new("UICorner")
WCToggleCorner.CornerRadius = UDim.new(1, 0)
WCToggleCorner.Parent = WCToggleFrame

local WCToggleCircle = Instance.new("Frame")
WCToggleCircle.Size = UDim2.new(0, 14, 0, 14)
WCToggleCircle.Position = wallCheckEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
WCToggleCircle.BackgroundColor3 = wallCheckEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)
WCToggleCircle.BorderSizePixel = 0
WCToggleCircle.Parent = WCToggleFrame

local WCCircleCorner = Instance.new("UICorner")
WCCircleCorner.CornerRadius = UDim.new(1, 0)
WCCircleCorner.Parent = WCToggleCircle

WCToggleFrame.MouseButton1Click:Connect(function()
    wallCheckEnabled = not wallCheckEnabled
    settingsData.wallCheck = wallCheckEnabled
    TweenService:Create(WCToggleCircle, TweenInfo.new(0.2), {Position = wallCheckEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = wallCheckEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)}):Play()
    TweenService:Create(WCToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = wallCheckEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)}):Play()
    SaveSettings()
end)

-- Silent-Aim Row
local SilentContainer = Instance.new("Frame")
SilentContainer.Size = UDim2.new(1, -6, 0, 36)
SilentContainer.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
SilentContainer.Parent = MainTab

local SC_Corner = Instance.new("UICorner")
SC_Corner.CornerRadius = UDim.new(0, 4)
SC_Corner.Parent = SilentContainer

local SCLabel = Instance.new("TextLabel")
SCLabel.Size = UDim2.new(0.4, 0, 1, 0)
SCLabel.Position = UDim2.new(0, 10, 0, 0)
SCLabel.BackgroundTransparency = 1
SCLabel.Text = "Silent-Aim"
SCLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
SCLabel.TextXAlignment = Enum.TextXAlignment.Left
SCLabel.Font = Enum.Font.Gotham
SCLabel.TextSize = 12
SCLabel.Parent = SilentContainer

local SCKeyBtn = Instance.new("TextButton")
SCKeyBtn.Size = UDim2.new(0, 40, 0, 22)
SCKeyBtn.Position = UDim2.new(1, -90, 0.5, -11)
SCKeyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SCKeyBtn.Text = silentAimKey.Name
SCKeyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
SCKeyBtn.Font = Enum.Font.GothamBold
SCKeyBtn.TextSize = 11
SCKeyBtn.Parent = SilentContainer

local SCKeyCorner = Instance.new("UICorner")
SCKeyCorner.CornerRadius = UDim.new(0, 4)
SCKeyCorner.Parent = SCKeyBtn

local SCToggleFrame = Instance.new("TextButton")
SCToggleFrame.Size = UDim2.new(0, 40, 0, 20)
SCToggleFrame.Position = UDim2.new(1, -45, 0.5, -10)
SCToggleFrame.BackgroundColor3 = silentAimEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
SCToggleFrame.Text = ""
SCToggleFrame.AutoButtonColor = false
SCToggleFrame.Parent = SilentContainer

local SCToggleCorner = Instance.new("UICorner")
SCToggleCorner.CornerRadius = UDim.new(1, 0)
SCToggleCorner.Parent = SCToggleFrame

local SCToggleCircle = Instance.new("Frame")
SCToggleCircle.Size = UDim2.new(0, 14, 0, 14)
SCToggleCircle.Position = silentAimEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
SCToggleCircle.BackgroundColor3 = silentAimEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)
SCToggleCircle.BorderSizePixel = 0
SCToggleCircle.Parent = SCToggleFrame

local SCCircleCorner = Instance.new("UICorner")
SCCircleCorner.CornerRadius = UDim.new(1, 0)
SCCircleCorner.Parent = SCToggleCircle

local function UpdateSilentAimVisuals()
    TweenService:Create(SCToggleCircle, TweenInfo.new(0.2), {Position = silentAimEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = silentAimEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)}):Play()
    TweenService:Create(SCToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = silentAimEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)}):Play()
end

SCToggleFrame.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    settingsData.silentAimEnabled = silentAimEnabled
    UpdateSilentAimVisuals()
    SaveSettings()
end)

SCKeyBtn.MouseButton1Click:Connect(function()
    listeningForSilentKey = true
    SCKeyBtn.Text = "..."
    SCKeyBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
end)

-- Show FOV Row
local ShowFOVContainer = Instance.new("Frame")
ShowFOVContainer.Size = UDim2.new(1, -6, 0, 36)
ShowFOVContainer.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
ShowFOVContainer.Parent = MainTab

local SF_Corner = Instance.new("UICorner")
SF_Corner.CornerRadius = UDim.new(0, 4)
SF_Corner.Parent = ShowFOVContainer

local SFLabel = Instance.new("TextLabel")
SFLabel.Size = UDim2.new(0.6, 0, 1, 0)
SFLabel.Position = UDim2.new(0, 10, 0, 0)
SFLabel.BackgroundTransparency = 1
SFLabel.Text = "Show FOV Circle"
SFLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
SFLabel.TextXAlignment = Enum.TextXAlignment.Left
SFLabel.Font = Enum.Font.Gotham
SFLabel.TextSize = 12
SFLabel.Parent = ShowFOVContainer

local SFToggleFrame = Instance.new("TextButton")
SFToggleFrame.Size = UDim2.new(0, 40, 0, 20)
SFToggleFrame.Position = UDim2.new(1, -45, 0.5, -10)
SFToggleFrame.BackgroundColor3 = showFOVEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
SFToggleFrame.Text = ""
SFToggleFrame.AutoButtonColor = false
SFToggleFrame.Parent = ShowFOVContainer

local SFToggleCorner = Instance.new("UICorner")
SFToggleCorner.CornerRadius = UDim.new(1, 0)
SFToggleCorner.Parent = SFToggleFrame

local SFToggleCircle = Instance.new("Frame")
SFToggleCircle.Size = UDim2.new(0, 14, 0, 14)
SFToggleCircle.Position = showFOVEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
SFToggleCircle.BackgroundColor3 = showFOVEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)
SFToggleCircle.BorderSizePixel = 0
SFToggleCircle.Parent = SFToggleFrame

local SFCircleCorner = Instance.new("UICorner")
SFCircleCorner.CornerRadius = UDim.new(1, 0)
SFCircleCorner.Parent = SFToggleCircle

SFToggleFrame.MouseButton1Click:Connect(function()
    showFOVEnabled = not showFOVEnabled
    settingsData.showFOV = showFOVEnabled
    if FOVCircle then FOVCircle.Visible = showFOVEnabled end
    TweenService:Create(SFToggleCircle, TweenInfo.new(0.2), {Position = showFOVEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = showFOVEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)}):Play()
    TweenService:Create(SFToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = showFOVEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)}):Play()
    SaveSettings()
end)

-- FOV Adjustment & Color Inputs
local FOVContainer = Instance.new("Frame")
FOVContainer.Size = UDim2.new(1, -6, 0, 50)
FOVContainer.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
FOVContainer.Parent = MainTab

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(0, 4)
FOVCorner.Parent = FOVContainer

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0.6, 0, 0, 25)
FOVLabel.Position = UDim2.new(0, 10, 0, 4)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV Radius: " .. FOVRadius
FOVLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextSize = 12
FOVLabel.Parent = FOVContainer

local FOVSliderBox = Instance.new("TextBox")
FOVSliderBox.Size = UDim2.new(0, 60, 0, 22)
FOVSliderBox.Position = UDim2.new(1, -70, 0, 4)
FOVSliderBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FOVSliderBox.Text = tostring(FOVRadius)
FOVSliderBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVSliderBox.Font = Enum.Font.GothamBold
FOVSliderBox.TextSize = 11
FOVSliderBox.Parent = FOVContainer

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 4)
BoxCorner.Parent = FOVSliderBox

FOVSliderBox.FocusLost:Connect(function()
    local val = tonumber(FOVSliderBox.Text)
    if val then
        FOVRadius = math.clamp(val, 10, 600)
        if FOVCircle then FOVCircle.Radius = FOVRadius end
        FOVSliderBox.Text = tostring(FOVRadius)
        FOVLabel.Text = "FOV Radius: " .. FOVRadius
        settingsData.fovRadius = FOVRadius
        SaveSettings()
    else
        FOVSliderBox.Text = tostring(FOVRadius)
    end
end)

local ColorLabel = Instance.new("TextLabel")
ColorLabel.Size = UDim2.new(0.6, 0, 0, 20)
ColorLabel.Position = UDim2.new(0, 10, 0, 28)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "FOV Color (R,G,B e.g. 255,0,0)"
ColorLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorLabel.Font = Enum.Font.Gotham
ColorLabel.TextSize = 10
ColorLabel.Parent = FOVContainer

local ColorBox = Instance.new("TextBox")
ColorBox.Size = UDim2.new(0, 90, 0, 20)
ColorBox.Position = UDim2.new(1, -100, 0, 27)
ColorBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ColorBox.Text = table.concat(FOVColorTable, ",")
ColorBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorBox.Font = Enum.Font.GothamBold
ColorBox.TextSize = 10
ColorBox.Parent = FOVContainer

local ColorBoxCorner = Instance.new("UICorner")
ColorBoxCorner.CornerRadius = UDim.new(0, 4)
ColorBoxCorner.Parent = ColorBox

ColorBox.FocusLost:Connect(function()
    local success, r, g, b = pcall(function()
        local split = string.split(ColorBox.Text, ",")
        return tonumber(split[1]), tonumber(split[2]), tonumber(split[3])
    end)
    if success and r and g and b then
        FOVColorTable = {math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255)}
        if FOVCircle then FOVCircle.Color = Color3.fromRGB(FOVColorTable[1], FOVColorTable[2], FOVColorTable[3]) end
        settingsData.fovColor = FOVColorTable
        SaveSettings()
    else
        ColorBox.Text = table.concat(FOVColorTable, ",")
    end
end)

---------------------------------------------------------
-- RENDER LOOP
---------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if silentAimEnabled or aimLockEnabled then
        local playerFound = GetTarget()
        if playerFound then
            SetTarget(playerFound)
        else
            ClearTarget()
        end
    else
        ClearTarget()
    end

    if FOVCircle then FOVCircle.Position = UserInputService:GetMouseLocation() end

    if aimLockEnabled and isAimLockActive and Target and Target.Character then
        local Head = Target.Character:FindFirstChild("Head") or Target.Character:FindFirstChild("HumanoidRootPart")
        local Hum = Target.Character:FindFirstChildOfClass("Humanoid")
        if Head and Hum and IsValidTarget(Hum) and CurrentCamera then
            if not settingsData.wallCheck or IsVisible(Head) then
                CurrentCamera.CFrame = CFrame.lookAt(CurrentCamera.CFrame.Position, Head.Position)
            end
        else
            ClearTarget()
        end
    end
end)

---------------------------------------------------------
-- GUNHANDLER HOOK (SILENT AIM)
---------------------------------------------------------
pcall(function()
    local GunHandler = require(ReplicatedStorage:WaitForChild("Modules"):FindFirstChild("GunHandler"))
    local OriginalShoot = GunHandler.shoot
    
    GunHandler.shoot = newcclosure(function(Data)
        local ActualCharacter = LocalPlayer.Character
        if Data and Data.Shooter == ActualCharacter then
            if Target and Target.Character then
                local targetHead = Target.Character:FindFirstChild("Head") or Target.Character:FindFirstChild("HumanoidRootPart")
                local targetHum = Target.Character:FindFirstChildOfClass("Humanoid")

                if targetHead and targetHum and IsValidTarget(targetHum) then
                    if silentAimEnabled then
                        if not settingsData.wallCheck or IsVisible(targetHead) then
                            Data.AimPosition = targetHead.Position
                        end
                    end
                end
            end
        end
        return OriginalShoot(Data)
    end)
end)

---------------------------------------------------------
-- TELEPORT TAB
---------------------------------------------------------
local teleportLocations = {
    {Name = "Bank (Inside)", CFrame = CFrame.new(-451.95, 23.02, -273.13)},
    {Name = "Bank (Top)", CFrame = CFrame.new(-450.40, 39.68, -285.30)},
    {Name = "Bar (Revolver)", CFrame = CFrame.new(-657.89, 23.38, -124.40)},
    {Name = "Barber", CFrame = CFrame.new(8.53, 21.75, -102.33)},
    {Name = "Basketball (Deagle)", CFrame = CFrame.new(357.69, 64.90, 282.93)},
    {Name = "Basketball (Laundry)", CFrame = CFrame.new(-934.75, 22.00, -483.12)},
    {Name = "Casino", CFrame = CFrame.new(-837.32, 21.80, -141.22)},
    {Name = "Church", CFrame = CFrame.new(205.00, 23.78, -57.73)},
    {Name = "Downhill", CFrame = CFrame.new(-578.70, 8.31, -737.84)},
    {Name = "Fire Dept", CFrame = CFrame.new(-165.92, 21.93, -128.90)},
    {Name = "Furniture", CFrame = CFrame.new(-487.28, 21.85, -105.51)},
    {Name = "Gas Station", CFrame = CFrame.new(587.43, 49.00, -258.92)},
    {Name = "Graveyard", CFrame = CFrame.new(188.71, 21.75, 37.75)},
    {Name = "Laundry", CFrame = CFrame.new(-973.39, 22.01, -625.71)},
    {Name = "Mini Van", CFrame = CFrame.new(-944.71, -4.13, 435.29)},
    {Name = "Motel", CFrame = CFrame.new(356.33, 64.40, 415.87)},
    {Name = "Police Dept", CFrame = CFrame.new(-291.29, 21.80, -93.13)},
    {Name = "Pool", CFrame = CFrame.new(-870.15, 21.80, -259.86)},
    {Name = "School", CFrame = CFrame.new(-652.65, 21.75, 247.05)},
    {Name = "Soccer", CFrame = CFrame.new(-750.86, 22.28, -482.89)},
    {Name = "Taco", CFrame = CFrame.new(589.47, 51.06, -443.76)},
    {Name = "Theatre", CFrame = CFrame.new(-1006.34, 21.25, -173.23)},
    {Name = "Uphill", CFrame = CFrame.new(481.24, 48.07, -617.13)},
    {Name = "Warehouse", CFrame = CFrame.new(413.75, 48.03, -49.47)},
    {Name = "Walter White", CFrame = CFrame.new(595.75, 28.58, -226.46)}
}

table.sort(teleportLocations, function(a, b) return a.Name < b.Name end)

for _, loc in ipairs(teleportLocations) do
    local TpButton = Instance.new("TextButton")
    TpButton.Size = UDim2.new(1, -6, 0, 32)
    TpButton.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    TpButton.Text = "  " .. loc.Name
    TpButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    TpButton.Font = Enum.Font.GothamMedium
    TpButton.TextSize = 12
    TpButton.TextXAlignment = Enum.TextXAlignment.Left
    TpButton.Parent = TeleportTab

    local TpCorner = Instance.new("UICorner")
    TpCorner.CornerRadius = UDim.new(0, 4)
    TpCorner.Parent = TpButton

    TpButton.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.CFrame = loc.CFrame
            end
        end
    end)
end

---------------------------------------------------------
-- TARGET TAB
---------------------------------------------------------
local selectedPlayer = nil
local isSpectating = false

local TargetContainer = Instance.new("Frame")
TargetContainer.Size = UDim2.new(1, -6, 0, 140)
TargetContainer.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
TargetContainer.Parent = TargetTab

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0, 4)
TargetCorner.Parent = TargetContainer

local TargetTitle = Instance.new("TextLabel")
TargetTitle.Size = UDim2.new(1, -20, 0, 25)
TargetTitle.Position = UDim2.new(0, 10, 0, 5)
TargetTitle.BackgroundTransparency = 1
TargetTitle.Text = "Select Target"
TargetTitle.TextColor3 = Color3.fromRGB(210, 210, 210)
TargetTitle.TextXAlignment = Enum.TextXAlignment.Left
TargetTitle.Font = Enum.Font.GothamMedium
TargetTitle.TextSize = 13
TargetTitle.Parent = TargetContainer

local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(1, -20, 0, 28)
DropdownBtn.Position = UDim2.new(0, 10, 0, 32)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DropdownBtn.Text = "  Select a player..."
DropdownBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
DropdownBtn.Font = Enum.Font.Gotham
DropdownBtn.TextSize = 12
DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
DropdownBtn.Parent = TargetContainer

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 4)
DropdownCorner.Parent = DropdownBtn

local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Size = UDim2.new(1, -20, 0, 100)
DropdownList.Position = UDim2.new(0, 10, 0, 62)
DropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
DropdownList.BorderSizePixel = 0
DropdownList.ScrollBarThickness = 3
DropdownList.Visible = false
DropdownList.ZIndex = 5
DropdownList.Parent = TargetContainer

local DropdownListCorner = Instance.new("UICorner")
DropdownListCorner.CornerRadius = UDim.new(0, 4)
DropdownListCorner.Parent = DropdownList

local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropdownLayout.Padding = UDim.new(0, 2)
DropdownLayout.Parent = DropdownList

local ActionFrame = Instance.new("Frame")
ActionFrame.Size = UDim2.new(1, -20, 0, 32)
ActionFrame.Position = UDim2.new(0, 10, 0, 96)
ActionFrame.BackgroundTransparency = 1
ActionFrame.Parent = TargetContainer

local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Size = UDim2.new(0.48, 0, 1, 0)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TeleportBtn.Text = "Teleport"
TeleportBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
TeleportBtn.Font = Enum.Font.GothamMedium
TeleportBtn.TextSize = 12
TeleportBtn.Parent = ActionFrame

local TPBtnCorner = Instance.new("UICorner")
TPBtnCorner.CornerRadius = UDim.new(0, 4)
TPBtnCorner.Parent = TeleportBtn

local SpectateBtn = Instance.new("TextButton")
SpectateBtn.Size = UDim2.new(0.48, 0, 1, 0)
SpectateBtn.Position = UDim2.new(0.52, 0, 0, 0)
SpectateBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpectateBtn.Text = "Spectate: OFF"
SpectateBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
SpectateBtn.Font = Enum.Font.GothamMedium
SpectateBtn.TextSize = 12
SpectateBtn.Parent = ActionFrame

local SpecBtnCorner = Instance.new("UICorner")
SpecBtnCorner.CornerRadius = UDim.new(0, 4)
SpecBtnCorner.Parent = SpectateBtn

local function RefreshPlayerList()
    for _, child in pairs(DropdownList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, -6, 0, 24)
            pBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            pBtn.Text = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"
            pBtn.TextColor3 = Color3.fromRGB(210, 210, 210)
            pBtn.Font = Enum.Font.Gotham
            pBtn.TextSize = 11
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.ZIndex = 6
            pBtn.Parent = DropdownList

            local pBtnCorner = Instance.new("UICorner")
            pBtnCorner.CornerRadius = UDim.new(0, 3)
            pBtnCorner.Parent = pBtn

            pBtn.MouseButton1Click:Connect(function()
                selectedPlayer = p
                DropdownBtn.Text = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"
                DropdownList.Visible = false
                if isSpectating then
                    local targetChar = p.Character
                    local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
                    if targetHum then workspace.CurrentCamera.CameraSubject = targetHum end
                end
            end)
        end
    end
end

DropdownBtn.MouseButton1Click:Connect(function()
    DropdownList.Visible = not DropdownList.Visible
    if DropdownList.Visible then RefreshPlayerList() end
end)

TeleportBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer then return end
    local myChar = LocalPlayer.Character
    local targetChar = selectedPlayer.Character
    if myChar and targetChar then
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        if myHRP and targetHRP then
            myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)

SpectateBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer and not isSpectating then return end
    isSpectating = not isSpectating
    local cam = workspace.CurrentCamera
    local myChar = LocalPlayer.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

    if isSpectating and selectedPlayer then
        local targetChar = selectedPlayer.Character
        local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
        if targetHum then
            cam.CameraSubject = targetHum
            SpectateBtn.Text = "Spectate: ON"
            SpectateBtn.TextColor3 = Color3.fromRGB(0, 255, 140)
        else
            isSpectating = false
            SpectateBtn.Text = "Spectate: OFF"
        end
    else
        if myHum then cam.CameraSubject = myHum end
        SpectateBtn.Text = "Spectate: OFF"
        SpectateBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
    end
end)

---------------------------------------------------------
-- FLIGHT SYSTEM
---------------------------------------------------------
local FLY_SPEED = settingsData.flySpeed or 50
local flyEnabled = settingsData.flyEnabled or false
local flyKey = Enum.KeyCode[settingsData.flyKey or "F"] or Enum.KeyCode.F
local listeningForFlyKey = false
local activeFly = false

local FlyContainer = Instance.new("Frame")
FlyContainer.Size = UDim2.new(1, -6, 0, 68)
FlyContainer.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
FlyContainer.Parent = MainTab

local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(0, 4)
FlyCorner.Parent = FlyContainer

local FlyLabel = Instance.new("TextLabel")
FlyLabel.Size = UDim2.new(0.4, 0, 0, 36)
FlyLabel.Position = UDim2.new(0, 10, 0, 0)
FlyLabel.BackgroundTransparency = 1
FlyLabel.Text = "Flight"
FlyLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
FlyLabel.TextXAlignment = Enum.TextXAlignment.Left
FlyLabel.Font = Enum.Font.Gotham
FlyLabel.TextSize = 12
FlyLabel.Parent = FlyContainer

local FlyKeyBtn = Instance.new("TextButton")
FlyKeyBtn.Size = UDim2.new(0, 40, 0, 22)
FlyKeyBtn.Position = UDim2.new(1, -90, 0, 7)
FlyKeyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FlyKeyBtn.Text = flyKey.Name
FlyKeyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
FlyKeyBtn.Font = Enum.Font.GothamBold
FlyKeyBtn.TextSize = 11
FlyKeyBtn.Parent = FlyContainer

local FlyKeyCorner = Instance.new("UICorner")
FlyKeyCorner.CornerRadius = UDim.new(0, 4)
FlyKeyCorner.Parent = FlyKeyBtn

local FlyToggleFrame = Instance.new("TextButton")
FlyToggleFrame.Size = UDim2.new(0, 40, 0, 20)
FlyToggleFrame.Position = UDim2.new(1, -45, 0, 8)
FlyToggleFrame.BackgroundColor3 = flyEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
FlyToggleFrame.Text = ""
FlyToggleFrame.AutoButtonColor = false
FlyToggleFrame.Parent = FlyContainer

local FlyToggleCorner = Instance.new("UICorner")
FlyToggleCorner.CornerRadius = UDim.new(1, 0)
FlyToggleCorner.Parent = FlyToggleFrame

local FlyToggleCircle = Instance.new("Frame")
FlyToggleCircle.Size = UDim2.new(0, 14, 0, 14)
FlyToggleCircle.Position = flyEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
FlyToggleCircle.BackgroundColor3 = flyEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)
FlyToggleCircle.BorderSizePixel = 0
FlyToggleCircle.Parent = FlyToggleFrame

local FlyCircleCorner = Instance.new("UICorner")
FlyCircleCorner.CornerRadius = UDim.new(1, 0)
FlyCircleCorner.Parent = FlyToggleCircle

local FlySpeedLabel = Instance.new("TextLabel")
FlySpeedLabel.Size = UDim2.new(0.6, 0, 0, 26)
FlySpeedLabel.Position = UDim2.new(0, 10, 0, 36)
FlySpeedLabel.BackgroundTransparency = 1
FlySpeedLabel.Text = "Fly Speed: " .. FLY_SPEED
FlySpeedLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
FlySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
FlySpeedLabel.Font = Enum.Font.Gotham
FlySpeedLabel.TextSize = 11
FlySpeedLabel.Parent = FlyContainer

local FlySpeedBox = Instance.new("TextBox")
FlySpeedBox.Size = UDim2.new(0, 60, 0, 22)
FlySpeedBox.Position = UDim2.new(1, -70, 0, 38)
FlySpeedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FlySpeedBox.Text = tostring(FLY_SPEED)
FlySpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FlySpeedBox.Font = Enum.Font.GothamBold
FlySpeedBox.TextSize = 11
FlySpeedBox.Parent = FlyContainer

local FlySpeedCorner = Instance.new("UICorner")
FlySpeedCorner.CornerRadius = UDim.new(0, 4)
FlySpeedCorner.Parent = FlySpeedBox

FlySpeedBox.FocusLost:Connect(function()
    local val = tonumber(FlySpeedBox.Text)
    if val then
        FLY_SPEED = math.clamp(val, 1, 300)
        FlySpeedBox.Text = tostring(FLY_SPEED)
        FlySpeedLabel.Text = "Fly Speed: " .. FLY_SPEED
        settingsData.flySpeed = FLY_SPEED
        SaveSettings()
    else
        FlySpeedBox.Text = tostring(FLY_SPEED)
    end
end)

local function DisableFlightState()
    activeFly = false
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
    end
end

FlyToggleFrame.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    settingsData.flyEnabled = flyEnabled
    TweenService:Create(FlyToggleCircle, TweenInfo.new(0.2), {Position = flyEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = flyEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)}):Play()
    TweenService:Create(FlyToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = flyEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)}):Play()
    if not flyEnabled then DisableFlightState() end
    SaveSettings()
end)

FlyKeyBtn.MouseButton1Click:Connect(function()
    listeningForFlyKey = true
    FlyKeyBtn.Text = "..."
    FlyKeyBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
end)

RunService.RenderStepped:Connect(function(dt)
    if not flyEnabled or not activeFly then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    if not hrp or not hum or not cam then return end

    hum.PlatformStand = true
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

    local z, x, y = 0, 0, 0
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then z = z + 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then z = z - 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then x = x - 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then x = x + 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then y = y + 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then y = y - 1 end

    local lookVector = cam.CFrame.LookVector
    local rightVector = cam.CFrame.RightVector
    local moveVector = (lookVector * z) + (rightVector * x) + (Vector3.new(0, 1, 0) * y)
    if moveVector.Magnitude > 0 then moveVector = moveVector.Unit end

    local targetCFrame = hrp.CFrame + (moveVector * FLY_SPEED * dt)
    hrp.CFrame = CFrame.new(targetCFrame.Position, targetCFrame.Position + lookVector)
end)

---------------------------------------------------------
-- CHOKE / NECKGRABS TAB
---------------------------------------------------------
local chokeKey = Enum.KeyCode[settingsData.chokeKey] or Enum.KeyCode.G
local chokeEnabled = settingsData.chokeEnabled
local listeningForChokeKey = false
local activeChokeTrack = nil
local isChoking = false
local R15_CHOKE_IDS = {"rbxassetid://507767714", "rbxassetid://507765000", "rbxassetid://3338042792"}

local ChokeContainer = Instance.new("Frame")
ChokeContainer.Size = UDim2.new(1, -6, 0, 36)
ChokeContainer.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
ChokeContainer.Parent = NeckgrabsTab

local ChokeCorner = Instance.new("UICorner")
ChokeCorner.CornerRadius = UDim.new(0, 4)
ChokeCorner.Parent = ChokeContainer

local ChokeLabel = Instance.new("TextLabel")
ChokeLabel.Size = UDim2.new(0.4, 0, 1, 0)
ChokeLabel.Position = UDim2.new(0, 10, 0, 0)
ChokeLabel.BackgroundTransparency = 1
ChokeLabel.Text = "Choke"
ChokeLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
ChokeLabel.TextXAlignment = Enum.TextXAlignment.Left
ChokeLabel.Font = Enum.Font.Gotham
ChokeLabel.TextSize = 12
ChokeLabel.Parent = ChokeContainer

local ChokeKeyBtn = Instance.new("TextButton")
ChokeKeyBtn.Size = UDim2.new(0, 40, 0, 22)
ChokeKeyBtn.Position = UDim2.new(1, -90, 0.5, -11)
ChokeKeyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ChokeKeyBtn.Text = chokeKey.Name
ChokeKeyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
ChokeKeyBtn.Font = Enum.Font.GothamBold
ChokeKeyBtn.TextSize = 11
ChokeKeyBtn.Parent = ChokeContainer

local ChokeKeyCorner = Instance.new("UICorner")
ChokeKeyCorner.CornerRadius = UDim.new(0, 4)
ChokeKeyCorner.Parent = ChokeKeyBtn

local ToggleFrame = Instance.new("TextButton")
ToggleFrame.Size = UDim2.new(0, 40, 0, 20)
ToggleFrame.Position = UDim2.new(1, -45, 0.5, -10)
ToggleFrame.BackgroundColor3 = chokeEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
ToggleFrame.Text = ""
ToggleFrame.AutoButtonColor = false
ToggleFrame.Parent = ChokeContainer

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleFrame

local ToggleCircle = Instance.new("Frame")
ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
ToggleCircle.Position = chokeEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
ToggleCircle.BackgroundColor3 = chokeEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)
ToggleCircle.BorderSizePixel = 0
ToggleCircle.Parent = ToggleFrame

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = ToggleCircle

ToggleFrame.MouseButton1Click:Connect(function()
    chokeEnabled = not chokeEnabled
    settingsData.chokeEnabled = chokeEnabled
    TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = chokeEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = chokeEnabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(200, 200, 200)}):Play()
    TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = chokeEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)}):Play()
    if not chokeEnabled and isChoking and activeChokeTrack then
        activeChokeTrack:Stop()
        isChoking = false
    end
    SaveSettings()
end)

ChokeKeyBtn.MouseButton1Click:Connect(function()
    listeningForChokeKey = true
    ChokeKeyBtn.Text = "..."
    ChokeKeyBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
end)

---------------------------------------------------------
-- MISC TAB: MENU KEYBIND
---------------------------------------------------------
local toggleKey = Enum.KeyCode[settingsData.toggleKey] or Enum.KeyCode.RightControl
local listeningForKey = false

local KeybindContainer = Instance.new("Frame")
KeybindContainer.Size = UDim2.new(1, -6, 0, 36)
KeybindContainer.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
KeybindContainer.Parent = MiscTab

local KeybindCorner = Instance.new("UICorner")
KeybindCorner.CornerRadius = UDim.new(0, 4)
KeybindCorner.Parent = KeybindContainer

local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Size = UDim2.new(0.6, 0, 1, 0)
KeybindLabel.Position = UDim2.new(0, 10, 0, 0)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = "Open/Close Menu Bind"
KeybindLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
KeybindLabel.Font = Enum.Font.Gotham
KeybindLabel.TextSize = 12
KeybindLabel.Parent = KeybindContainer

local KeybindBtn = Instance.new("TextButton")
KeybindBtn.Size = UDim2.new(0, 80, 0, 22)
KeybindBtn.Position = UDim2.new(1, -85, 0.5, -11)
KeybindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
KeybindBtn.Text = toggleKey.Name
KeybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KeybindBtn.Font = Enum.Font.GothamBold
KeybindBtn.TextSize = 11
KeybindBtn.Parent = KeybindContainer

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 4)
BtnCorner.Parent = KeybindBtn

KeybindBtn.MouseButton1Click:Connect(function()
    listeningForKey = true
    KeybindBtn.Text = "..."
    KeybindBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
end)

---------------------------------------------------------
-- EXTRA TAB (Combined + Text-Based Discord Logo)
---------------------------------------------------------
local ExtraInfoContainer = Instance.new("Frame")
ExtraInfoContainer.Size = UDim2.new(1, -6, 0, 220)
ExtraInfoContainer.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
ExtraInfoContainer.Parent = ExtraTab

local ExtraInfoCorner = Instance.new("UICorner")
ExtraInfoCorner.CornerRadius = UDim.new(0, 4)
ExtraInfoCorner.Parent = ExtraInfoContainer

local ExtraInfoLabel = Instance.new("TextLabel")
ExtraInfoLabel.Size = UDim2.new(1, -20, 1, -70)
ExtraInfoLabel.Position = UDim2.new(0, 10, 0, 10)
ExtraInfoLabel.BackgroundTransparency = 1
ExtraInfoLabel.Text = "This script was created because XK5NG stopped updating his script, which caused frustration within the community. As a result, I decided to create a fork inspired by XK5NG's original script.\n\nI have worked on many projects and also run my own Criminality-modded project. I plan to focus more on it in the future, as it is currently my main source of income. However, I am also committed to maintaining this script and ensuring that it remains up to date.\n\nThe script will always be free to use, although there may also be optional paid features for users who want additional functionality."
ExtraInfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ExtraInfoLabel.TextSize = 11
ExtraInfoLabel.Font = Enum.Font.Gotham
ExtraInfoLabel.TextWrapped = true
ExtraInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
ExtraInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
ExtraInfoLabel.Parent = ExtraInfoContainer

-- Text-based Discord Icon Badge instead of Asset ID
local DiscordIconBadge = Instance.new("TextButton")
DiscordIconBadge.Size = UDim2.new(0, 32, 0, 32)
DiscordIconBadge.Position = UDim2.new(0, 10, 1, -44)
DiscordIconBadge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DiscordIconBadge.Text = "💬"
DiscordIconBadge.TextSize = 14
DiscordIconBadge.Parent = ExtraInfoContainer

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 6)
BadgeCorner.Parent = DiscordIconBadge

-- Discord Link Button
local DiscordLinkBtn = Instance.new("TextButton")
DiscordLinkBtn.Size = UDim2.new(1, -95, 0, 32)
DiscordLinkBtn.Position = UDim2.new(0, 50, 1, -44)
DiscordLinkBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DiscordLinkBtn.Text = "https://discord.gg/SBfpSWDBXB"
DiscordLinkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordLinkBtn.Font = Enum.Font.GothamMedium
DiscordLinkBtn.TextSize = 11
DiscordLinkBtn.Parent = ExtraInfoContainer

local DiscordLinkCorner = Instance.new("UICorner")
DiscordLinkCorner.CornerRadius = UDim.new(0, 4)
DiscordLinkCorner.Parent = DiscordLinkBtn

-- Copy Button
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 32, 0, 32)
CopyBtn.Position = UDim2.new(1, -42, 1, -44)
CopyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
CopyBtn.Text = "📋"
CopyBtn.TextSize = 14
CopyBtn.Parent = ExtraInfoContainer

local CopyBtnCorner = Instance.new("UICorner")
CopyBtnCorner.CornerRadius = UDim.new(0, 6)
CopyBtnCorner.Parent = CopyBtn

-- Copy to Clipboard Action
local function CopyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        SendNotification("Copied", "Copied invite link to clipboard!")
    else
        SendNotification("Error", "Your executor does not support setclipboard.")
    end
end

DiscordIconBadge.MouseButton1Click:Connect(function()
    CopyToClipboard("https://discord.gg/SBfpSWDBXB")
end)

DiscordLinkBtn.MouseButton1Click:Connect(function()
    CopyToClipboard("https://discord.gg/SBfpSWDBXB")
end)

CopyBtn.MouseButton1Click:Connect(function()
    CopyToClipboard("https://discord.gg/SBfpSWDBXB")
end)

---------------------------------------------------------
-- ANIMATION / CHOKE HELPER FUNCTIONS
---------------------------------------------------------
local function GetNearbyRagdoll()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
    if not hrp then return nil end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= LocalPlayer and otherPlayer.Character then
            local targetChar = otherPlayer.Character
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("UpperTorso")
            local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
            if targetHRP and targetHumanoid then
                if (hrp.Position - targetHRP.Position).Magnitude <= 10 then
                    if targetHumanoid.PlatformStand or targetHumanoid:GetState() == Enum.HumanoidStateType.Physics or targetHumanoid:GetState() == Enum.HumanoidStateType.Ragdoll or targetHumanoid.Health <= 20 then
                        return targetChar
                    end
                end
            end
        end
    end
    return nil
end

local function PlayR15Choke(animator)
    for _, animId in ipairs(R15_CHOKE_IDS) do
        local anim = Instance.new("Animation")
        anim.AnimationId = animId
        local success, track = pcall(function() return animator:LoadAnimation(anim) end)
        if success and track then
            track.Priority = Enum.AnimationPriority.Action4
            track:Play(0.1, 1, 1)
            return track
        end
    end
    return nil
end

---------------------------------------------------------
-- GLOBAL KEYBIND & INPUT HANDLER
---------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        MouseHolding = true
    end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        if listeningForKey then
            toggleKey = input.KeyCode
            KeybindBtn.Text = toggleKey.Name
            KeybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            listeningForKey = false
            settingsData.toggleKey = toggleKey.Name
            SaveSettings()
            return
        elseif listeningForChokeKey then
            chokeKey = input.KeyCode
            ChokeKeyBtn.Text = chokeKey.Name
            ChokeKeyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            listeningForChokeKey = false
            settingsData.chokeKey = chokeKey.Name
            SaveSettings()
            return
        elseif listeningForFlyKey then
            flyKey = input.KeyCode
            FlyKeyBtn.Text = flyKey.Name
            FlyKeyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            listeningForFlyKey = false
            settingsData.flyKey = flyKey.Name
            SaveSettings()
            return
        elseif listeningForAimLockKey then
            aimLockKey = input.KeyCode
            ALKeyBtn.Text = aimLockKey.Name
            ALKeyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            listeningForAimLockKey = false
            settingsData.aimLockKey = aimLockKey.Name
            SaveSettings()
            return
        elseif listeningForSilentKey then
            silentAimKey = input.KeyCode
            SCKeyBtn.Text = silentAimKey.Name
            SCKeyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            listeningForSilentKey = false
            settingsData.silentAimKey = silentAimKey.Name
            SaveSettings()
            return
        end
    end

    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == toggleKey then
            MainFrame.Visible = not MainFrame.Visible
        elseif input.KeyCode == flyKey and flyEnabled then
            activeFly = not activeFly
            if not activeFly then DisableFlightState() end
        elseif input.KeyCode == aimLockKey and aimLockEnabled then
            if aimLockMode == "Hold" then
                isAimLockActive = true
            else
                isAimLockActive = not isAimLockActive
            end
            
            if isAimLockActive then
                if Target then
                    SendNotification("Aim-Lock", "Locked On Target\n" .. Target.DisplayName .. " (@" .. Target.Name .. ")")
                else
                    SendNotification("Aim-Lock", "Locked On Target\n(No Target)")
                end
            else
                if Target then
                    SendNotification("Aim-Lock", "Locked Off Target\n" .. Target.DisplayName .. " (@" .. Target.Name .. ")")
                else
                    SendNotification("Aim-Lock", "Locked Off Target")
                end
            end
        elseif input.KeyCode == silentAimKey then
            silentAimEnabled = not silentAimEnabled
            settingsData.silentAimEnabled = silentAimEnabled
            UpdateSilentAimVisuals()
            SaveSettings()
        elseif input.KeyCode == chokeKey and chokeEnabled then
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    if isChoking and activeChokeTrack then
                        activeChokeTrack:Stop()
                        isChoking = false
                    else
                        local ragdollTarget = GetNearbyRagdoll()
                        if ragdollTarget then
                            activeChokeTrack = PlayR15Choke(animator)
                            if activeChokeTrack then isChoking = true end
                        end
                    end
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        MouseHolding = false
    end

    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == aimLockKey then
        if aimLockEnabled and aimLockMode == "Hold" then
            isAimLockActive = false
            if Target then
                SendNotification("Aim-Lock", "Locked Off Target\n" .. Target.DisplayName .. " (@" .. Target.Name .. ")")
            else
                SendNotification("Aim-Lock", "Locked Off Target")
            end
        end
    end
end)