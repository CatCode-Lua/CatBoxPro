-- CatBoxPRO Test Script para KRNL
-- Solo para pruebas en tu servidor, client-side

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local defaultWalkSpeed = 16
local ghostPart
local fakeLagActive = false
local antiHitActive = false

-- Crear GUI simple
local gui = Instance.new("ScreenGui")
gui.Name = "CatBoxTestGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,300,0,200)
frame.Position = UDim2.new(0.3,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "CatBoxPRO Test"
title.TextColor3 = Color3.fromRGB(255,0,0)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

-- Botón FakeLagNoclip
local btnFakeLag = Instance.new("TextButton")
btnFakeLag.Size = UDim2.new(0,200,0,40)
btnFakeLag.Position = UDim2.new(0.5,-100,0,50)
btnFakeLag.Text = "FakeLagNoclip"
btnFakeLag.BackgroundColor3 = Color3.fromRGB(0,120,255)
btnFakeLag.TextColor3 = Color3.fromRGB(255,255,255)
btnFakeLag.Parent = frame

-- Botón Anti-Hit
local btnAntiHit = Instance.new("TextButton")
btnAntiHit.Size = UDim2.new(0,200,0,40)
btnAntiHit.Position = UDim2.new(0.5,-100,0,100)
btnAntiHit.Text = "Anti-Hit"
btnAntiHit.BackgroundColor3 = Color3.fromRGB(0,120,255)
btnAntiHit.TextColor3 = Color3.fromRGB(255,255,255)
btnAntiHit.Parent = frame

-- Función FakeLagNoclip
local function enableFakeLag()
    if fakeLagActive then return end
    fakeLagActive = true
    btnFakeLag.BackgroundColor3 = Color3.fromRGB(0,255,0)

    ghostPart = Instance.new("Part", Workspace)
    ghostPart.Size = Vector3.new(2,humanoid.HipHeight*2,1)
    ghostPart.Anchored = false
    ghostPart.CanCollide = false
    ghostPart.Transparency = 0.5
    ghostPart.Material = Enum.Material.ForceField
    ghostPart.Color = Color3.fromRGB(255,0,255)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = ghostPart
    weld.Part1 = rootPart
    weld.Parent = ghostPart

    humanoid.WalkSpeed = 14
end

local function disableFakeLag()
    fakeLagActive = false
    btnFakeLag.BackgroundColor3 = Color3.fromRGB(0,120,255)
    humanoid.WalkSpeed = defaultWalkSpeed
    if ghostPart then ghostPart:Destroy() ghostPart = nil end
end

btnFakeLag.MouseButton1Click:Connect(function()
    if fakeLagActive then disableFakeLag() else enableFakeLag() end
end)

-- Función Anti-Hit
local function enableAntiHit()
    if antiHitActive then return end
    antiHitActive = true
    btnAntiHit.BackgroundColor3 = Color3.fromRGB(0,255,0)
    rootPart.CanCollide = false
end

local function disableAntiHit()
    antiHitActive = false
    btnAntiHit.BackgroundColor3 = Color3.fromRGB(0,120,255)
    rootPart.CanCollide = true
end

btnAntiHit.MouseButton1Click:Connect(function()
    if antiHitActive then disableAntiHit() else enableAntiHit() end
end)

-- Loop opcional para FakeLag (simular lag client-side)
RunService.RenderStepped:Connect(function()
    if fakeLagActive and ghostPart then
        rootPart.CFrame = ghostPart.CFrame
    end
end)