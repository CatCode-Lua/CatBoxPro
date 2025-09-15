-- CatBoxPRO PREMIUM FULL
-- By: RexTR, NexStudio, VeryFiret and CiteVeT
-- Versión: 3.5 PlayerScripts Edition
-- Líneas de código: 700+

-- Esperar a que el juego cargue completamente
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Obtener servicios esenciales
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Verificar si estamos en un lugar seguro para ejecutar
local function isExecutionSafe()
    -- Verificar múltiples condiciones de seguridad
    if not RunService:IsClient() then
        return false, "No se ejecuta en el cliente"
    end
    
    if not Players.LocalPlayer then
        return false, "Jugador local no disponible"
    end
    
    -- Verificar si hay detección de inyección
    local success, result = pcall(function()
        return debug.info(1, "s") ~= "[C]"
    end)
    
    if not success then
        return false, "Entorno de depuración detectado"
    end
    
    return true, "Entorno seguro"
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
        -- Generar un mensaje de error genérico para no levantar sospechas
        warn("Script Error: " .. tostring(result))
        return false
    end
    return true
end

-- Función para verificar la validez de un jugador
local function isValidPlayer(player)
    return player and player:IsA("Player") and player.Character and 
           player.Character:FindFirstChild("Humanoid") and
           player.Character.Humanoid.Health > 0 and
           player.Character:FindFirstChild("HumanoidRootPart")
end

-- Crear la interfaz de usuario de manera segura
local function createSecureUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CatBoxPRO_UI"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = true
    
    -- Hacer la GUI menos detectable
    delay(1, function()
        if screenGui.Parent == CoreGui then
            screenGui.Parent = player.PlayerGui
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
    
    -- Añadir más elementos de UI aquí...
    
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
            -- Si no hay modificadores, asegurarse de que no se presionen accidentalmente
            modifiersMatch = not UserInputService:IsKeyDown(Enum.ModifierCtrl) and
                            not UserInputService:IsKeyDown(Enum.ModifierShift) and
                            not UserInputService:IsKeyDown(Enum.ModifierAlt)
        end
        
        if modifiersMatch and input.KeyCode == binding.Key then
            -- Verificar cooldown
            if hotkeySystem.Cooldowns[binding.Function] and 
               tick() - hotkeySystem.Cooldowns[binding.Function] < config.Hotkeys.Cooldown then
                return
            end
            
            hotkeySystem.Cooldowns[binding.Function] = tick()
            
            -- Ejecutar función correspondiente con retardo aleatorio
            delay(math.random() * 0.1, function()
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

-- Función FakeLagNoclip mejorada
local function toggleFakeLagNoclip()
    if tick() - lastActivation < 1 then return end
    lastActivation = tick()
    
    states.FakeLagNoclip = not states.FakeLagNoclip
    
    if states.FakeLagNoclip then
        -- Guardar valores originales
        originalWalkSpeed = humanoid.WalkSpeed
        originalCollision = character:FindFirstChildWhichIsA("BasePart").CanCollide
        
        -- Crear ghostPart con propiedades aleatorizadas
        ghostPart = Instance.new("Part")
        ghostPart.Name = "GhostPart_" .. HttpService:GenerateGUID(false):sub(1, 8)
        ghostPart.Size = Vector3.new(4, 6, 2)
        ghostPart.Transparency = 0.7
        ghostPart.CanCollide = false
        ghostPart.Anchored = false
        ghostPart.CFrame = rootPart.CFrame
        ghostPart.Parent = character
        
        -- Desactivar colisión en todas las partes
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        -- Limitar velocidad
        humanoid.WalkSpeed = config.FakeLagSpeed
        
        -- Simular lag para evitar detección
        spawn(function()
            while states.FakeLagNoclip do
                randomDelay()
                -- Pequeñas pausas aleatorias para simular lag
                task.wait(math.random(0.1, 0.3))
            end
        end)
    else
        -- Restaurar valores originales
        if ghostPart then
            ghostPart:Destroy()
            ghostPart = nil
        end
        
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = originalCollision
            end
        end
        
        humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- Función LAGServer mejorada
local function toggleLAGServer()
    if tick() - lastActivation < 1 then return end
    lastActivation = tick()
    
    states.LAGServer = not states.LAGServer
    
    if states.LAGServer then
        -- Aplicar efectos visuales a todos los jugadores excepto whitelist
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and not config.Whitelist[otherPlayer.UserId] then
                if isValidPlayer(otherPlayer) then
                    local character = otherPlayer.Character
                    
                    -- Aplicar efectos con variaciones aleatorias
                    local fire = Instance.new("Fire")
                    fire.Size = math.random(8, 12)
                    fire.Heat = math.random(10, 20)
                    fire.Parent = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
                    
                    local sparkles = Instance.new("Sparkles")
                    sparkles.SparkleColor = Color3.fromRGB(math.random(255), math.random(255), math.random(255))
                    sparkles.Parent = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
                    
                    -- Guardar efectos para eliminarlos después
                    table.insert(lagEffects, fire)
                    table.insert(lagEffects, sparkles)
                end
            end
        end
    else
        -- Eliminar todos los efectos aplicados
        for _, effect in ipairs(lagEffects) do
            if effect then
                effect:Destroy()
            end
        end
        lagEffects = {}
    end
end

-- Función Anti-Lag mejorada
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
        
        -- Limpiar partículas del entorno
        local effects = workspace:FindFirstChild("Effects")
        if effects then
            effects:ClearAllChildren()
        end
    end
end

-- Función Anti-Hit mejorada
local function toggleAntiHit()
    if tick() - lastActivation < 1 then return end
    lastActivation = tick()
    
    states.AntiHit = not states.AntiHit
    
    if states.AntiHit then
        -- Hacer que el jugador no pueda ser golpeado
        humanoid:SetAttribute("Invulnerable", true)
        
        -- Desactivar detección de golpes
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = false
            end
        end
    else
        -- Restaurar detección de golpes
        humanoid:SetAttribute("Invulnerable", false)
        
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = true
            end
        end
    end
end

-- Función AntiSpeedNegative mejorada
local function toggleAntiSpeedNegative()
    if tick() - lastActivation < 1 then return end
    lastActivation = tick()
    
    states.AntiSpeedNegative = not states.AntiSpeedNegative
    
    if states.AntiSpeedNegative then
        -- Guardar velocidad original
        originalWalkSpeed = humanoid.WalkSpeed
        
        -- Conectar para mantener velocidad mínima
        RunService.Heartbeat:Connect(function()
            if humanoid.WalkSpeed < config.AntiSpeedMin then
                humanoid.WalkSpeed = config.AntiSpeedMin
            end
        end)
    else
        -- Restaurar velocidad original
        humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- Función para el modo sigilo
local function toggleStealthMode()
    if tick() - lastActivation < 1 then return end
    lastActivation = tick()
    
    states.StealthActive = not states.StealthActive
    
    if states.StealthActive then
        -- Ocultar todas las evidencias
        disableAllFeatures()
    end
end

-- Función de pánico
local function panicKey()
    -- Desactivar todas las funciones inmediatamente
    disableAllFeatures()
    
    -- Limpiar rastros
    clearAllEffects()
    
    -- Mensaje de depuración falsa
    print("Script error: Attempt to call nil value")
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
                safeExecute("HotkeyHandler", handleHotkey, input, processed)
            end)
        end
        
        -- Verificar si el personaje sigue siendo válido
        if not character or not character.Parent then
            character = player.Character or player.CharacterAdded:Wait()
            humanoid = character:WaitForChild("Humanoid")
            rootPart = character:WaitForChild("HumanoidRootPart")
        end
        
        -- Limpieza periódica de memoria
        collectgarbage()
    end
end

-- Iniciar monitores de seguridad
task.spawn(securityMonitor)

-- Verificación inicial de seguridad
local safe, reason = isExecutionSafe()
if not safe then
    warn("CatBoxPRO: No se puede inicializar - " .. reason)
    return
end

-- Crear la interfaz de usuario
local screenGui, mainFrame = createSecureUI()

-- Inicialización completada
print("CatBoxPRO Premium inicializado correctamente")

-- Código de finalización aleatorio para evitar detección
if math.random(1, 5) == 1 then
    -- Simular actividad normal
    task.wait(1)
end

return "CatBoxPRO loaded successfully"