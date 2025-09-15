-- CatBoxPRO PREMIUM Extended - KRNL Ready
-- By: RexTR, NexStudio, VeryFiret and CiteVeT

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local defaultWalkSpeed = 16

-- Estados
local state = {
    FakeLagActive = false,
    AntiHitActive = false,
    LagServerActive = false,
    AntiLagActive = false,
    AntiSpeedNegativeActive = false,
    Whitelist = {},
    ghostPart = nil
}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CatBoxPROGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Frame Principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,650,0,450)
frame.Position = UDim2.new(0.2,0,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Título RGB letra por letra
local titleText = "CatBoxPRO"
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,60)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextStrokeTransparency = 0
title.TextStrokeColor3 = Color3.fromRGB(0,0,0)
title.Text = titleText
title.TextColor3 = Color3.fromRGB(255,0,0)
title.Parent = frame

-- Subtítulo
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1,0,0,30)
subtitle.Position = UDim2.new(0,0,0,60)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextScaled = true
subtitle.Text = "By: RexTR, NexStudio, VeryFiret and CiteVeT"
subtitle.TextColor3 = Color3.fromRGB(255,100,100)
subtitle.TextStrokeTransparency = 0.5
subtitle.Parent = frame

-- Función para crear botones
local function createButton(name,posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,180,0,45)
    btn.Position = UDim2.new(0.5,-90,0,posY)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(0,120,255)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = frame
    return btn
end

-- Botones
local buttons = {}
buttons.FakeLagNoclip = createButton("FakeLagNoclip",110)
buttons.LAGServer = createButton("LAGServer",170)
buttons.AntiLag = createButton("Anti-Lag",230)
buttons.AntiHit = createButton("Anti-Hit",290)
buttons.AntiSpeedNegative = createButton("AntiSpeedNegative",350)
buttons.Whitelist = createButton("Add to Whitelist",410)

-- Botón de Cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,35,0,35)
closeBtn.Position = UDim2.new(1,-40,0,5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextScaled = true
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    humanoid.WalkSpeed = defaultWalkSpeed
    rootPart.CanCollide = true
    if state.ghostPart then
        state.ghostPart:Destroy()
        state.ghostPart = nil
    end
end)

-- Funciones FakeLagNoclip
local function enableFakeLag()
    if state.FakeLagActive then return end
    state.FakeLagActive = true
    buttons.FakeLagNoclip.BackgroundColor3 = Color3.fromRGB(0,255,0)
    -- Crear ghostPart
    local ghost = Instance.new("Part",Workspace)
    ghost.Size = Vector3.new(2,humanoid.HipHeight*2,1)
    ghost.Anchored = false
    ghost.CanCollide = false
    ghost.Transparency = 0.5
    ghost.Material = Enum.Material.ForceField
    ghost.Color = Color3.fromRGB(255,0,255)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = ghost
    weld.Part1 = rootPart
    weld.Parent = ghost
    state.ghostPart = ghost
    humanoid.WalkSpeed = 14
end

local function disableFakeLag()
    state.FakeLagActive = false
    buttons.FakeLagNoclip.BackgroundColor3 = Color3.fromRGB(0,120,255)
    humanoid.WalkSpeed = defaultWalkSpeed
    if state.ghostPart then
        state.ghostPart:Destroy()
        state.ghostPart = nil
    end
end

buttons.FakeLagNoclip.MouseButton1Click:Connect(function()
    if state.FakeLagActive then disableFakeLag() else enableFakeLag() end
end)

-- Funciones Anti-Hit
local function enableAntiHit()
    state.AntiHitActive = true
    buttons.AntiHit.BackgroundColor3 = Color3.fromRGB(0,255,0)
    rootPart.CanCollide = false
end

local function disableAntiHit()
    state.AntiHitActive = false
    buttons.AntiHit.BackgroundColor3 = Color3.fromRGB(0,120,255)
    rootPart.CanCollide = true
end

buttons.AntiHit.MouseButton1Click:Connect(function()
    if state.AntiHitActive then disableAntiHit() else enableAntiHit() end
end)

-- Funciones LAGServer
local function enableLAGServer()
    state.LagServerActive = true
    buttons.LAGServer.BackgroundColor3 = Color3.fromRGB(255,0,0)
    spawn(function()
        while state.LagServerActive do
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and not table.find(state.Whitelist,plr.Name) then
                    -- Aquí se pueden agregar partículas, luces, efectos saturados
                    -- Velocidad reducida a 12
                    local ch = plr.Character
                    if ch and ch:FindFirstChild("Humanoid") then
                        ch.Humanoid.WalkSpeed = 12
                    end
                end
            end
            task.wait(1)
        end
    end)
end

local function disableLAGServer()
    state.LagServerActive = false
    buttons.LAGServer.BackgroundColor3 = Color3.fromRGB(0,120,255)
    -- Restaurar velocidades originales si deseas
end

buttons.LAGServer.MouseButton1Click:Connect(function()
    if state.LagServerActive then disableLAGServer() else enableLAGServer() end
end)

-- Anti-Lag
local function enableAntiLag()
    state.AntiLagActive = true
    buttons.AntiLag.BackgroundColor3 = Color3.fromRGB(0,255,0)
    -- Eliminar partículas, efectos, animaciones
end

local function disableAntiLag()
    state.AntiLagActive = false
    buttons.AntiLag.BackgroundColor3 = Color3.fromRGB(0,120,255)
    -- Restaurar efectos
end

buttons.AntiLag.MouseButton1Click:Connect(function()
    if state.AntiLagActive then disableAntiLag() else enableAntiLag() end
end)

-- AntiSpeedNegative
local function enableAntiSpeedNegative()
    state.AntiSpeedNegativeActive = true
    buttons.AntiSpeedNegative.BackgroundColor3 = Color3.fromRGB(0,255,0)
end

local function disableAntiSpeedNegative()
    state.AntiSpeedNegativeActive = false
    buttons.AntiSpeedNegative.BackgroundColor3 = Color3.fromRGB(0,120,255)
end

buttons.AntiSpeedNegative.MouseButton1Click:Connect(function()
    if state.AntiSpeedNegativeActive then disableAntiSpeedNegative() else enableAntiSpeedNegative() end
end)

-- Whitelist: agregar jugador
buttons.Whitelist.MouseButton1Click:Connect(function()
    local name = player.Name -- Aquí puedes reemplazar con InputBox si quieres nombre manual
    if not table.find(state.Whitelist,name) then
        table.insert(state.Whitelist,name)
    end
end)

-- Suavizado de movimiento ghostPart
RunService.RenderStepped:Connect(function()
    if state.FakeLagActive and state.ghostPart then
        rootPart.CFrame = rootPart.CFrame:Lerp(state.ghostPart.CFrame,0.2)
    end
    -- Mantener velocidad mínima
    if state.AntiSpeedNegativeActive and humanoid.WalkSpeed < 16 then
        humanoid.WalkSpeed = 16
    end
end)