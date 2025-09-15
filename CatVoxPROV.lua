-- CatBoxPRO PREMIUM FULL - PLAYERSCRIPTS EDITION
-- By: RexTR, NexStudio, VeryFiret and CiteVeT
-- Versión: 3.5 PlayerScripts Edition
-- Líneas de código: 700+

-- Esperar a que el juego cargue completamente
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Obtener servicios esenciales del CLIENTE
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Verificar que estamos en el cliente
if not RunService:IsClient() then
    warn("Este script debe ejecutarse en el cliente (PlayerScripts)")
    return
end

-- Esperar a que el jugador esté listo
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Configuración con valores aleatorizados para evitar detección
local config = {
    FakeLagSpeed = 14,
    AntiSpeedMin = 16,
    Whitelist = {},
    UISize = "Normal",
    SecurityLevel = 4,
    Randomization = {
        Enabled = true,
        Interval = math.random(8, 15)
    },
    Hotkeys = {
        Enabled = true,
        Cooldown = 0.5
    }
}

-- Estados de las funciones
local states = {
    FakeLagNoclip = false,
    LAGServer = false,
    AntiLag = false,
    AntiHit = false,
    AntiSpeedNegative = false,
    StealthActive = false
}

-- Variables de funcionamiento
local ghostPart = nil
local originalWalkSpeed = humanoid.WalkSpeed
local originalCollision = true
local lagEffects = {}
local uiVisible = true
local lastActivation = 0
local securityCheckInterval = 15

-- Función para generar retrasos aleatorios
local function randomDelay()
    if config.Randomization.Enabled then
        task.wait(math.random() * 0.3)
    end
end

-- Función para ejecutar código de forma segura
local function safeExecute(name, func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("Script Error: " .. tostring(result))
        return false
    end
    return true
end

-- Función para verificar la validez de un jugador (desde el cliente)
local function isValidPlayer(player)
    return player and player:IsA("Player") and player.Character and 
           player.Character:FindFirstChild("Humanoid") and
           player.Character.Humanoid.Health > 0 and
           player.Character:FindFirstChild("HumanoidRootPart")
end

-- Crear la interfaz de usuario de manera segura (SOLO CLIENTE)
local function createSecureUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CatBoxPRO_UI_" .. HttpService:GenerateGUID(false):sub(1, 8)
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Enabled = true
    
    -- Hacer la GUI menos detectable
    task.delay(1, function()
        if screenGui.Parent == CoreGui then
            pcall(function()
                screenGui.Parent = player:FindFirstChild("PlayerGui")
            end)
        end
    end)
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "CatBoxPRO Premium"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = mainFrame
    
    -- Botones de funciones
    local buttons = {
        {Name = "FakeLagNoclip", Text = "FakeLagNoclip (F1)", Position = 40},
        {Name = "LAGServer", Text = "LAGServer (F2)", Position = 80},
        {Name = "AntiLag", Text = "Anti-Lag (F3)", Position = 120},
        {Name = "AntiHit", Text = "Anti-Hit (F4)", Position = 160},
        {Name = "AntiSpeed", Text = "AntiSpeed (F5)", Position = 200},
        {Name = "Stealth", Text = "Stealth Mode (F7)", Position = 240},
        {Name = "Panic", Text = "PANIC (Ctrl+Shift+P)", Position = 280}
    }
    
    for _, btnInfo in ipairs(buttons) do
        local button = Instance.new("TextButton")
        button.Name = btnInfo.Name
        button.Text = btnInfo.Text
        button.Size = UDim2.new(0.9, 0, 0, 30)
        button.Position = UDim2.new(0.05, 0, 0, btnInfo.Position)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.Gotham
        button.TextSize = 12
        button.Parent = mainFrame
        
        button.MouseButton1Click:Connect(function()
            if btnInfo.Name == "FakeLagNoclip" then toggleFakeLagNoclip()
            elseif btnInfo.Name == "LAGServer" then toggleLAGServer()
            elseif btnInfo.Name == "AntiLag" then toggleAntiLag()
            elseif btnInfo.Name == "AntiHit" then toggleAntiHit()
            elseif btnInfo.Name == "AntiSpeed" then toggleAntiSpeedNegative()
            elseif btnInfo.Name == "Stealth" then toggleStealthMode()
            elseif btnInfo.Name == "Panic" then panicKey() end
        end)
    end
    
    return screenGui, mainFrame
end

-- Sistema de teclas rápidas con protección mejorada
local hotkeySystem = {
    Enabled = config.Hotkeys.Enabled,
    Bindings = {
        {Key = Enum.KeyCode.F1, Function = "FakeLagNoclip", Description = "Toggle FakeLagNoclip"},
        {Key = Enum.KeyCode.F2, Function = "LAGServer", Description = "Toggle LAGServer"},
        {Key = Enum.KeyCode.F3, Function = "AntiLag", Description = "Toggle Anti-Lag"},
        {Key = Enum.KeyCode.F4, Function = "AntiHit", Description = "Toggle Anti-Hit"},
        {Key = Enum.KeyCode.F5, Function = "AntiSpeedNegative", Description = "Toggle AntiSpeedNegative"},
        {Key = Enum.KeyCode.F6, Function = "ToggleUI", Description = "Toggle UI Visibility"},
        {Key = Enum.KeyCode.F7, Function = "StealthMode", Description = "Toggle Stealth Mode"},
        {Key = Enum.KeyCode.P, Modifiers = {Enum.ModifierCtrl, Enum.ModifierShift}, Function = "Panic", Description = "Emergency Panic Key"}
    },
    Cooldowns = {}
}

-- Función para manejar teclas rápidas
local function handleHotkey(input, processed)
    if not hotkeySystem.Enabled or processed then return end
    if states.StealthActive and input.KeyCode ~= Enum.KeyCode.P then return end
    
    for _, binding in ipairs(hotkeySystem.Bindings) do
        local modifiersMatch = true
        
        -- Verificar modificadores
        if binding.Modifiers then
            for _, modifier in ipairs(binding.Modifiers) do
                if not UserInputService:IsKeyDown(modifier) then
                    modifiersMatch = false
                    break
                end
            end
        else
            modifiersMatch = not UserInputService:IsKeyDown(Enum.ModifierCtrl) and
                            not UserInputService:IsKeyDown(Enum.ModifierShift) and
                            not UserInputService:IsKeyDown(Enum.ModifierAlt)
        end
        
        if modifiersMatch and input.KeyCode == binding.Key then
            if hotkeySystem.Cooldowns[binding.Function] and 
               tick() - hotkeySystem.Cooldowns[binding.Function] < config.Hotkeys.Cooldown then
                return
            end
            
            hotkeySystem.Cooldowns[binding.Function] = tick()
            
            task.delay(math.random() * 0.1, function()
                if binding.Function == "FakeLagNoclip" then
                    toggleFakeLagNoclip()
                elseif binding.Function == "LAGServer" then
                    toggleLAGServer()
                elseif binding.Function == "AntiLag" then
                    toggleAntiLag()
                elseif binding.Function == "AntiHit" then
                    toggleAntiHit()
                elseif binding.Function == "AntiSpeedNegative" then
                    toggleAntiSpeedNegative()
                elseif binding.Function == "ToggleUI" then
                    toggleUI()
                elseif binding.Function == "StealthMode" then
                    toggleStealthMode()
                elseif binding.Function == "Panic" then
                    panicKey()
                end
            end)
            
            break
        end
    end
end

-- Conectar el evento de teclado
local inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
    safeExecute("HotkeyHandler", handleHotkey, input, processed)
end)

-- Función FakeLagNoclip mejorada (SOLO CLIENTE)
local function toggleFakeLagNoclip()
    if tick() - lastActivation < 1 then return end
    lastActivation = tick()
    
    states.FakeLagNoclip = not states.FakeLagNoclip
    
    if states.FakeLagNoclip then
        originalWalkSpeed = humanoid.WalkSpeed
        originalCollision = true
        
        -- Guardar estado de colisión original
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        -- Crear efecto visual de ghost (solo cliente)
        ghostPart = Instance.new("Part")
        ghostPart.Name = "GhostPart_" .. HttpService:GenerateGUID(false):sub(1, 8)
        ghostPart.Size = Vector3.new(4, 6, 2)
        ghostPart.Transparency = 0.8
        ghostPart.CanCollide = false
        ghostPart.Anchored = false
        ghostPart.CFrame = rootPart.CFrame
        ghostPart.Parent = workspace
        ghostPart.Color = Color3.fromRGB(100, 100, 255)
        
        -- Conectar para seguir al personaje
        local weld = Instance.new("Weld")
        weld.Part0 = rootPart
        weld.Part1 = ghostPart
        weld.C0 = CFrame.new()
        weld.Parent = ghostPart
        
        humanoid.WalkSpeed = config.FakeLagSpeed
        
    else
        if ghostPart then
            ghostPart:Destroy()
            ghostPart = nil
        end
        
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        
        humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- Función LAGServer (efectos visuales solo en cliente)
local function toggleLAGServer()
    if tick() - lastActivation < 1 then return end
    lastActivation = tick()
    
    states.LAGServer = not states.LAGServer
    
    if states.LAGServer then
        -- Aplicar efectos visuales locales (solo este cliente los ve)
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and isValidPlayer(otherPlayer) then
                local character = otherPlayer.Character
                local root = character:FindFirstChild("HumanoidRootPart")
                
                if root then
                    local fire = Instance.new("Fire")
                    fire.Size = math.random(8, 12)
                    fire.Heat = math.random(10, 20)
                    fire.Parent = root
                    
                    local sparkles = Instance.new("Sparkles")
                    sparkles.SparkleColor = Color3.fromRGB(math.random(255), math.random(255), math.random(255))
                    sparkles.Parent = root
                    
                    table.insert(lagEffects, fire)
                    table.insert(lagEffects, sparkles)
                end
            end
        end
    else
        for _, effect in ipairs(lagEffects) do
            if effect and effect.Parent then
                effect:Destroy()
            end
        end
        lagEffects = {}
    end
end

-- Función Anti-Lag (limpieza visual cliente)
local function toggleAntiLag()
    if tick() - lastActivation < 1 then return end
    lastActivation = tick()
    
    states.AntiLag = not states.AntiLag
    
    if states.AntiLag then
        -- Limpiar efectos visuales del jugador local
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("Fire") or part:IsA("Sparkles") or part:IsA("Smoke") then
                part:Destroy()
            end
        end
    end
end

-- Función Anti-Hit (solo efectos visuales cliente)
local function toggleAntiHit()
    if tick() - lastActivation < 1 then return end
    lastActivation = tick()
    
    states.AntiHit = not states.AntiHit
    
    if states.AntiHit then
        -- Efecto visual de invulnerabilidad
        local forceField = Instance.new("ForceField")
        forceField.Name = "AntiHitShield"
        forceField.Visible = false
        forceField.Parent = character
    else
        local forceField = character:FindFirstChild("AntiHitShield")
        if forceField then
            forceField:Destroy()
        end
    end
end

-- Función AntiSpeedNegative (solo cliente)
local function toggleAntiSpeedNegative()
    if tick() - lastActivation < 1 then return end
    lastActivation = tick()
    
    states.AntiSpeedNegative = not states.AntiSpeedNegative
    
    if states.AntiSpeedNegative then
        originalWalkSpeed = humanoid.WalkSpeed
        
        local speedConnection
        speedConnection = RunService.Heartbeat:Connect(function()
            if humanoid.WalkSpeed < config.AntiSpeedMin then
                humanoid.WalkSpeed = config.AntiSpeedMin
            end
        end)
        
        -- Guardar conexión para limpiar después
        states.AntiSpeedConnection = speedConnection
    else
        if states.AntiSpeedConnection then
            states.AntiSpeedConnection:Disconnect()
            states.AntiSpeedConnection = nil
        end
        humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- Función para toggle UI
local function toggleUI()
    if screenGui then
        screenGui.Enabled = not screenGui.Enabled
    end
end

-- Función para el modo sigilo
local function toggleStealthMode()
    if tick() - lastActivation < 1 then return end
    lastActivation = tick()
    
    states.StealthActive = not states.StealthActive
    
    if states.StealthActive then
        -- Ocultar UI y desactivar funciones
        if screenGui then screenGui.Enabled = false end
        disableAllFeatures()
    else
        if screenGui then screenGui.Enabled = true end
    end
end

-- Función de pánico
local function panicKey()
    disableAllFeatures()
    clearAllEffects()
    if screenGui then screenGui.Enabled = false end
    states.StealthActive = true
end

-- Función para desactivar todas las funciones
local function disableAllFeatures()
    if states.FakeLagNoclip then toggleFakeLagNoclip() end
    if states.LAGServer then toggleLAGServer() end
    if states.AntiLag then toggleAntiLag() end
    if states.AntiHit then toggleAntiHit() end
    if states.AntiSpeedNegative then toggleAntiSpeedNegative() end
end

-- Función para limpiar todos los efectos
local function clearAllEffects()
    for _, effect in ipairs(lagEffects) do
        safeExecute("ClearEffect", function()
            if effect and effect.Parent then
                effect:Destroy()
            end
        end)
    end
    lagEffects = {}
end

-- Sistema de seguridad y auto-reparación
local function securityMonitor()
    while true do
        task.wait(securityCheckInterval)
        
        -- Verificar si las conexiones siguen activas
        if not inputConnection or not inputConnection.Connected then
            inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
                safeExecute("Hotkey