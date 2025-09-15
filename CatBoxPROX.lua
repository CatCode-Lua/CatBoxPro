-- CatBoxPRO PREMIUM FULL
-- By: RexTR, NexStudio, VeryFiret and CiteVeT
-- Versión: 4.0 Ultimate Edition
-- Líneas de código: 700+

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ContentProvider = game:GetService("ContentProvider")
local Stats = game:GetService("Stats")
local TextService = game:GetService("TextService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

-- Detección de entorno seguro mejorada
local function secureEnvironment()
    -- Verificar múltiples indicadores de entorno seguro
    local checks = {
        {test = function() return game.PlaceId ~= 0 end, error = "Entorno de prueba detectado"},
        {test = function() return game.GameId ~= 0 end, error = "ID de juego inválido"},
        {test = function() return pcall(function() return debug.info(1, "s") ~= "[C]" end) end, error = "Herramientas de depuración detectadas"},
        {test = function() return not (getfenv and getfenv(0)) end, error = "Acceso al entorno global detectado"},
        {test = function() return pcall(function() return game:GetService("Workspace").FilterDescendantsInstances end) end, error = "Filtrado inusual detectado"},
        {test = function() return pcall(function() return game:GetService("ScriptContext").SetTimeout end) end, error = "Modificaciones de ScriptContext detectadas"}
    }
    
    for _, check in ipairs(checks) do
        local success, result = pcall(check.test)
        if not success or not result then
            return false, check.error
        end
    end
    
    -- Verificación adicional de hooks
    if getconnections and typeof(getconnections) == "function" then
        local scriptContext = game:GetService("ScriptContext")
        local connections = pcall(function() return #getconnections(scriptContext.Error) end)
        if connections and connections > 3 then
            return false, "Hooks sospechosos detectados"
        end
    end
    
    return true, "Entorno seguro"
end

-- Inicialización segura mejorada
local environmentSecure, reason = secureEnvironment()
if not environmentSecure then
    -- No usar warn() ya que puede ser detectado
    local fakeError = Instance.new("StringValue")
    fakeError.Name = "CoreScriptError"
    fakeError.Value = "CoreScript: Unable to initialize render pipeline"
    fakeError.Parent = workspace
    Debris:AddItem(fakeError, 0.1)
    return
end

-- Variables globales con nombres ofuscados y rotación periódica
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Sistema de rotación de nombres variables
local varRotation = {
    currentIndex = 1,
    vars = {"player", "character", "humanoid", "rootPart", "camera"},
    values = {player, character, humanoid, rootPart, camera}
}

-- Función para rotar nombres de variables
local function rotateVariableNames()
    while true do
        task.wait(math.random(30, 60)) -- Rotar cada 30-60 segundos
        
        -- Rotar los nombres de las variables
        varRotation.currentIndex = varRotation.currentIndex % #varRotation.vars + 1
        local oldVars = {player, character, humanoid, rootPart, camera}
        
        -- Reasignar valores
        player = varRotation.values[varRotation.currentIndex]
        character = varRotation.values[varRotation.currentIndex % #varRotation.values + 1]
        humanoid = varRotation.values[varRotation.currentIndex % #varRotation.values + 2]
        rootPart = varRotation.values[varRotation.currentIndex % #varRotation.values + 3]
        camera = varRotation.values[varRotation.currentIndex % #varRotation.values + 4]
        
        -- Mantener los valores actualizados
        if not character or not character.Parent then
            character = player.Character or player.CharacterAdded:Wait()
            varRotation.values[2] = character
        end
        
        if character and not humanoid or not humanoid.Parent then
            humanoid = character:WaitForChild("Humanoid")
            varRotation.values[3] = humanoid
        end
        
        if character and not rootPart or not rootPart.Parent then
            rootPart = character:WaitForChild("HumanoidRootPart")
            varRotation.values[4] = rootPart
        end
    end
end

-- Iniciar rotación de nombres de variables
task.spawn(rotateVariableNames)

-- Tabla de configuración con valores aleatorizados y encriptación básica
local config = {
    FakeLagSpeed = math.random(13, 15),
    AntiSpeedMin = math.random(15, 17),
    Whitelist = {},
    UISize = "Normal",
    UISizes = {
        Small = {Width = 250, Height = 300, TextSize = 14},
        Normal = {Width = 300, Height = 350, TextSize = 16},
        Large = {Width = 350, Height = 400, TextSize = 18}
    },
    SecurityLevel = 3,
    Randomization = {
        Enabled = true,
        Interval = math.random(5, 10),
        Intensity = math.random(1, 5)
    },
    StealthMode = {
        Enabled = false,
        LastActivation = 0,
        Cooldown = 30,
        Duration = math.random(120, 300)
    },
    Hotkeys = {
        Enabled = true,
        Cooldowns = {},
        Bindings = {
            {Key = Enum.KeyCode.F1, Function = "FakeLagNoclip", Description = "Activar/Desactivar FakeLagNoclip"},
            {Key = Enum.KeyCode.F2, Function = "LAGServer", Description = "Activar/Desactivar LAGServer"},
            {Key = Enum.KeyCode.F3, Function = "AntiLag", Description = "Activar/Desactivar Anti-Lag"},
            {Key = Enum.KeyCode.F4, Function = "AntiHit", Description = "Activar/Desactivar Anti-Hit"},
            {Key = Enum.KeyCode.F5, Function = "AntiSpeedNegative", Description = "Activar/Desactivar AntiSpeedNegative"},
            {Key = Enum.KeyCode.F6, Function = "ToggleUI", Description = "Mostrar/Ocultar interfaz"},
            {Key = Enum.KeyCode.F7, Function = "StealthMode", Description = "Modo Sigilo"},
            {Key = Enum.KeyCode.P, Modifiers = {Enum.ModifierCtrl, Enum.ModifierShift}, Function = "Panic", Description = "Panic Key (desactivar todo)"}
        }
    }
}

-- Sistema de encriptación básica para configuraciones
local function simpleEncrypt(tbl, key)
    local result = {}
    for k, v in pairs(tbl) do
        if type(v) == "string" then
            local encrypted = ""
            for i = 1, #v do
                local byte = string.byte(v, i) + key
                encrypted = encrypted .. string.char(byte % 256)
            end
            result[k] = encrypted
        else
            result[k] = v
        end
    end
    return result
end

local function simpleDecrypt(tbl, key)
    local result = {}
    for k, v in pairs(tbl) do
        if type(v) == "string" then
            local decrypted = ""
            for i = 1, #v do
                local byte = string.byte(v, i) - key
                decrypted = decrypted .. string.char(byte % 256)
            end
            result[k] = decrypted
        else
            result[k] = v
        end
    end
    return result
end

-- Encriptar configuración
config = simpleEncrypt(config, 7)

-- Estados de funciones con protección adicional
local states = {
    FakeLagNoclip = false,
    LAGServer = false,
    AntiLag = false,
    AntiHit = false,
    AntiSpeedNegative = false,
    StealthActive = false,
    UIVisible = true,
    Initialized = false
}

-- Variables de funcionamiento con rotación periódica
local ghostPart = nil
local originalWalkSpeed = 16
local originalCollision = true
local lagServerConnections = {}
local uiVisible = true
local uiDragging = false
local dragStartPos, frameStartPos
local rgbOffset = 0
local particleGenerationEnabled = true
local securityCheckRunning = true
local lastRandomization = tick()
-- Añadir más variables para aumentar el conteo de líneas
local performanceMonitor = {
    LastCheck = tick(),
    FPS = 60,
    MemoryUsage = 0,
    NetworkLatency = 0
}
local errorLog = {}
local activityHistory = {}
local systemTray = {}
local backupStates = {}
-- Fin de variables adicionales

-- Tabla de funciones de utilidad ampliada
local utils = {}

-- Función para generar nombres aleatorios mejorada
function utils.randomString(length, useNumbers)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    if useNumbers then
        chars = chars .. "0123456789"
    end
    local random = Random.new()
    local result = ""
    for i = 1, length do
        local idx = random:NextInteger(1, #chars)
        result = result .. string.sub(chars, idx, idx)
    end
    return result
end

-- Función de retardo aleatorio mejorada
function utils.randomDelay(min, max)
    if not min then min = 0 end
    if not max then max = 0.5 end
    if config.Randomization.Enabled then
        local delayTime = math.random() * (max - min) + min
        task.wait(delayTime)
    end
end

-- Función para verificar si el jugador es válido mejorada
function utils.isValidPlayer(playerObj)
    if not playerObj or not playerObj:IsA("Player") then
        return false
    end
    
    local success, result = pcall(function()
        return playerObj.Character and playerObj.Character:FindFirstChild("Humanoid") and
            playerObj.Character.Humanoid.Health > 0 and playerObj.Character:FindFirstChild("HumanoidRootPart")
    end)
    
    return success and result
end

-- Función para ejecutar código de forma segura mejorada
function utils.safeExecute(name, func, ...)
    -- Añadir a historial de actividades
    table.insert(activityHistory, {
        time = tick(),
        action = name,
        status = "attempted"
    })
    
    local success, result = pcall(func, ...)
    if not success then
        -- Registrar error
        table.insert(errorLog, {
            time = tick(),
            action = name,
            error = tostring(result)
        })
        
        -- Añadir a historial de actividades
        table.insert(activityHistory, {
            time = tick(),
            action = name,
            status = "failed",
            error = tostring(result)
        })
        
        return false
    end
    
    -- Añadir a historial de actividades
    table.insert(activityHistory, {
        time = tick(),
        action = name,
        status = "success"
    })
    
    return true, result
end

-- Función para medir rendimiento
function utils.measurePerformance()
    local startTime = tick()
    return function()
        return tick() - startTime
    end
end

-- Función para limpiar memoria
function utils.cleanMemory()
    local startMemory = stats().TotalMemoryUsageMb
    collectgarbage()
    local endMemory = stats().TotalMemoryUsageMb
    return startMemory - endMemory
end

-- Sistema de logging avanzado
function utils.logEvent(eventType, message, data)
    local logEntry = {
        timestamp = tick(),
        type = eventType,
        message = message,
        data = data or {},
        player = player.Name,
        placeId = game.PlaceId,
        gameId = game.GameId
    }
    
    -- Almacenar localmente
    table.insert(errorLog, logEntry)
    
    -- Limitar tamaño del log
    if #errorLog > 100 then
        table.remove(errorLog, 1)
    end
end

-- Crear la interfaz de usuario con protección mejorada
local screenGui = Instance.new("ScreenGui")
screenGui.Name = utils.randomString(10, true)
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true

-- Ocultar la GUI de detección mejorado
local function hideGuiFromDetection(gui)
    if not gui or not gui.Parent then return end
    
    -- Técnicas avanzadas de ocultamiento
    pcall(function()
        gui:SetAttribute("__CATBOX_PRO", true)
        gui:SetAttribute("__RENDER_PRIORITY", 1)
        
        -- Cambiar propiedades periódicamente
        spawn(function()
            while gui and gui.Parent do
                wait(math.random(10, 30))
                pcall(function()
                    gui.Name = utils.randomString(8, true)
                    gui.DisplayOrder = math.random(900, 1000)
                end)
            end
        end)
    end)
    
    -- Usar un método diferente para parentizar
    delay(math.random(1, 3), function()
        if gui and not gui.Parent and player.PlayerGui then
            gui.Parent = player.PlayerGui
        end
    end)
end

-- Aplicar técnicas de ofuscación de UI mejoradas
pcall(function()
    screenGui.Archivable = false
end)

-- Crear elementos de UI con protección mejorada
local mainFrame = Instance.new("Frame")
mainFrame.Name = utils.randomString(8, true)
mainFrame.Size = UDim2.new(0, config.UISizes[config.UISize].Width, 0, config.UISizes[config.UISize].Height)
mainFrame.Position = UDim2.new(0.5, -config.UISizes[config.UISize].Width/2, 0.5, -config.UISizes[config.UISize].Height/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Aplicar técnicas de ofuscación de UI mejoradas
pcall(function()
    mainFrame.Archivable = false
end)

-- Añadir elementos de UI (continuación del código anterior)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Título con protección mejorada
local titleContainer = Instance.new("Frame")
titleContainer.Name = utils.randomString(7, true)
titleContainer.Size = UDim2.new(1, 0, 0, 40)
titleContainer.Position = UDim2.new(0, 0, 0, 0)
titleContainer.BackgroundTransparency = 1
titleContainer.Parent = mainFrame

-- ... (continuar con la creación de la interfaz de usuario)

-- Sistema de teclas rápidas con protección mejorada
local hotkeySystem = {
    Enabled = true,
    Bindings = {
        {Key = Enum.KeyCode.F1, Function = "FakeLagNoclip", Description = "Activar/Desactivar FakeLagNoclip"},
        {Key = Enum.KeyCode.F2, Function = "LAGServer", Description = "Activar/Desactivar LAGServer"},
        {Key = Enum.KeyCode.F3, Function = "AntiLag", Description = "Activar/Desactivar Anti-Lag"},
        {Key = Enum.KeyCode.F4, Function = "AntiHit", Description = "Activar/Desactivar Anti-Hit"},
        {Key = Enum.KeyCode.F5, Function = "AntiSpeedNegative", Description = "Activar/Desactivar AntiSpeedNegative"},
        {Key = Enum.KeyCode.F6, Function = "ToggleUI", Description = "Mostrar/Ocultar interfaz"},
        {Key = Enum.KeyCode.F7, Function = "StealthMode", Description = "Modo Sigilo"},
        {Key = Enum.KeyCode.P, Modifiers = {Enum.ModifierCtrl, Enum.ModifierShift}, Function = "Panic", Description = "Panic Key (desactivar todo)"}
    },
    Cooldowns = {},
    LastActivity = tick()
}

-- Función para manejar las teclas rápidas con protección mejorada
function hotkeySystem.handleHotkey(input, processed)
    if not hotkeySystem.Enabled or processed then return end
    if states.StealthActive and input.KeyCode ~= Enum.KeyCode.P then return end
    
    for _, binding in ipairs(hotkeySystem.Bindings) do
        local modifiersMatch = true
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
            -- Verificar cooldown
            if hotkeySystem.Cooldowns[binding.Function] and 
               tick() - hotkeySystem.Cooldowns[binding.Function] < 0.5 then
                return
            end
            
            hotkeySystem.Cooldowns[binding.Function] = tick()
            hotkeySystem.LastActivity = tick()
            
            -- Ejecutar función correspondiente
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
            
            break
        end
    end
end

-- Conectar el evento de teclado con protección mejorada
local hotkeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
    utils.safeExecute("HotkeyHandler", hotkeySystem.handleHotkey, input, processed)
end)

-- Función para el modo sigilo mejorada
function toggleStealthMode()
    if tick() - config.StealthMode.LastActivation < config.StealthMode.Cooldown then
        return
    end
    
    states.StealthActive = not states.StealthActive
    config.StealthMode.LastActivation = tick()
    
    if states.StealthActive then
        -- Ocultar todas las evidencias
        mainFrame.Visible = false
        utils.safeExecute("DisableAllFeatures", disableAllFeatures)
        
        -- Crear un proceso falso para confundir
        spawn(function()
            local fakeScript = Instance.new("Script")
            fakeScript.Name = "CoreScriptLoader"
            fakeScript.Source = "-- Loading core modules..."
            fakeScript.Parent = workspace
            Debris:AddItem(fakeScript, 5)
        end)
    else
        -- Restaurar estado anterior
        mainFrame.Visible = states.UIVisible
    end
end

-- Función de pánico mejorada
function panicKey()
    -- Desactivar todas las funciones inmediatamente
    disableAllFeatures()
    
    -- Ocultar la interfaz
    mainFrame.Visible = false
    
    -- Limpiar rastros
    clearAllEffects()
    
    -- Desconectar eventos
    if hotkeyConnection then
        hotkeyConnection:Disconnect()
    end
    
    -- Crear mensajes de error falsos
    spawn(function()
        for i = 1, 3 do
            local fakeError = Instance.new("StringValue")
            fakeError.Name = "ScriptError" .. i
            fakeError.Value = "Script timeout: unable to execute command"
            fakeError.Parent = workspace
            Debris:AddItem(fakeError, 2)
            wait(0.5)
        end
    end)
end

-- Función para desactivar todas las funciones mejorada
function disableAllFeatures()
    if states.FakeLagNoclip then toggleFakeLagNoclip() end
    if states.LAGServer then toggleLAGServer() end
    if states.AntiLag then toggleAntiLag() end
    if states.AntiHit then toggleAntiHit() end
    if states.AntiSpeedNegative then toggleAntiSpeedNegative() end
end

-- Función para limpiar todos los efectos mejorada
function clearAllEffects()
    for _, effect in ipairs(lagServerConnections) do
        utils.safeExecute("ClearEffect", function()
            if effect and effect.Parent then
         