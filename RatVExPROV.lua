-- CatBoxPRO PREMIUM FULL
-- By: RexTR, NexStudio, VeryFiret and CiteVeT

-- Servicios
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local defaultWalkSpeed = 16
local lagAmount = 0.2
local fakePos = rootPart.CFrame
local ghostPart
local state = {
    FakeLagActive = false,
    LagServerActive = false,
    AntiHitActive = false,
    AntiSpeedNegativeActive = false,
    Whitelist = {}
}

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "CatBoxPROGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Marco Principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 650, 0, 400)
frame.Position = UDim2.new(0.2, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Título RGB
local titleText = "CatBoxPRO"
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 70)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextStrokeTransparency = 0
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
title.TextWrapped = false
title.Parent = frame

-- Subtítulo
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 30)
subtitle.Position = UDim2.new(0, 0, 0, 70)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextScaled = true
subtitle.Text = "By: RexTR, NexStudio, VeryFiret and CiteVeT"
subtitle.TextColor3 = Color3.fromRGB(255, 100, 100)
subtitle.TextStrokeTransparency = 0.5
subtitle.Parent = frame

-- Botones
local buttonList = {}
local function createButton(name, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 45)
    btn.Position = UDim2.new(0.5, -90, 0, posY)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = frame
    return btn
end

buttonList.FakeLagNoclip = createButton("FakeLagNoclip", 110)
buttonList.LAGServer = createButton("LAGServer", 170)
buttonList.AntiLag = createButton("Anti-Lag", 230)
buttonList.AntiHit = createButton("Anti-Hit", 290)
buttonList.AntiSpeedNegative = createButton("AntiSpeedNegative", 350)
buttonList.Whitelist = createButton("Add to Whitelist", 410)

-- Botón de Cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    if ghostPart then ghostPart:Destroy() end
    humanoid.WalkSpeed = defaultWalkSpeed
end)

-- Funciones de FakeLagNoclip
local function enableFakeLag()
    state.FakeLagActive = true
    buttonList.FakeLagNoclip.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

    ghostPart = Instance.new("Part", Workspace)
    ghostPart.Size = Vector3.new(2, humanoid.HipHeight * 2, 1)
    ghostPart.Anchored = false
    ghostPart.CanCollide = false
    ghostPart.Transparency = 0.5
    ghostPart.Material = Enum.Material.ForceField
    ghostPart.Color = Color3.fromRGB(255, 0, 255)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = ghostPart
    weld.Part1 = rootPart
    weld.Parent = ghostPart

    humanoid.WalkSpeed = 14

    spawn(function()
        while state.FakeLagActive do
            local realPos = rootPart.CFrame
            rootPart.CFrame = fakePos
            task.wait(lagAmount)
            fakePos = rootPart.CFrame:Lerp(realPos, 0.5)
        end
    end)
end

local function disableFakeLag()
    state.FakeLagActive = false
    buttonList.FakeLagNoclip.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    humanoid.WalkSpeed = defaultWalkSpeed
    if ghostPart then
        ghostPart:Destroy()
        ghostPart = nil
    end
end

buttonList.FakeLagNoclip.MouseButton1Click:Connect(function()
    if state.FakeLagActive then
        disableFakeLag()
    else
        enableFakeLag()
    end
end)

-- Funciones de LAGServer
local function enableLAGServer()
    state.LagServerActive = true
    buttonList.LAGServer.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

    spawn(function()
        while state.LagServerActive do
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and not table.find(state.Whitelist, otherPlayer.Name) then
                    -- Saturar efectos en otros jugadores
                    -- Aquí se pueden agregar efectos como partículas, luces, sonidos, etc.
                end
            end
            task.wait(1)
        end
    end)
end

local function disableLAGServer()
    state.LagServerActive = false
    buttonList.LAGServer.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    -- Eliminar efectos de saturación en otros jugadores
end

buttonList.LAGServer.MouseButton1Click:Connect(function()
    if state.LagServerActive then
        disableLAGServer()
    else
        enableLAGServer()
    end
end)

-- Funciones de Anti-Lag
local function enableAntiLag()
    buttonList.AntiLag.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    -- Eliminar partículas, auras, efectos y texturas
end

local function disableAntiLag()
    buttonList.AntiLag.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    -- Restaurar efectos eliminados
end

buttonList.AntiLag.MouseButton1Click:Connect(function()
    if buttonList.AntiLag.BackgroundColor3 == Color3.fromRGB(0, 120, 255) then
        enableAntiLag()
    else
        disableAntiLag()
    end
end)

-- Funciones de Anti-Hit
local function enableAntiHit()
    state.AntiHitActive = true
    buttonList.AntiHit.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    -- Desactivar colisiones
end

local function disableAntiHit()
    state.AntiHitActive = false
    buttonList.AntiHit.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    -- Restaurar colisiones
end

buttonList.AntiHit.MouseButton1Click:Connect(function()
    if state.AntiHitActive then
        disableAntiHit()
    else
        enableAntiHit()
    end
end)

-- Funciones de AntiSpeedNegative
local function enableAntiSpeedNegative()
    state.AntiSpeedNegativeActive = true
    buttonList.AntiSpeedNegative.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    -- Mantener velocidad mínima
end

local function disableAntiSpeedNegative()
    state.AntiSpeedNegativeActive = false
    buttonList.AntiSpeedNegative.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    -- Restaurar velocidad
end

buttonList.AntiSpeedNegative18