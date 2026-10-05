-- Servicios esenciales de Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Variables del jugador y la cámara
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local triggerbotActivo = false 
local interfazVisible = true 
local modoDeteccion = "Cuerpo" -- Opciones: "Cuerpo" o "Letal"

----------------------------------------------------------------
-- INTERFAZ GRÁFICA AMPLIADA Y CLICKEABLE
----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DH_InteractiveTrigger"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Contenedor principal más alto para alojar los botones
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 120) 
frame.Position = UDim2.new(0.5, -110, 0, 15) 
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = frame

-- Texto de Estado del Bot
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.25, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 15
statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50) 
statusLabel.Text = "MIRA MANDO: DESACTIVADO"
statusLabel.Parent = frame

-- Botón 1: Cuerpo Completo
local btnCuerpo = Instance.new("TextButton")
btnCuerpo.Size = UDim2.new(0.9, 0, 0.22, 0)
btnCuerpo.Position = UDim2.new(0.05, 0, 0.28, 0)
btnCuerpo.BackgroundColor3 = Color3.fromRGB(50, 120, 255) -- Azul activo por defecto
btnCuerpo.Font = Enum.Font.SourceSansBold
btnCuerpo.TextSize = 13
btnCuerpo.TextColor3 = Color3.fromRGB(255, 255, 255)
btnCuerpo.Text = "Zona: Cuerpo Completo"
btnCuerpo.Parent = frame

local cornerCuerpo = Instance.new("UICorner")
cornerCuerpo.CornerRadius = UDim.new(0, 4)
cornerCuerpo.Parent = btnCuerpo

-- Botón 2: Solo Cabeza/Torso
local btnLetal = Instance.new("TextButton")
btnLetal.Size = UDim2.new(0.9, 0, 0.22, 0)
btnLetal.Position = UDim2.new(0.05, 0, 0.53, 0)
btnLetal.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Gris inactivo
btnLetal.Font = Enum.Font.SourceSansBold
btnLetal.TextSize = 13
btnLetal.TextColor3 = Color3.fromRGB(180, 180, 180)
btnLetal.Text = "Zona: Solo Cabeza / Torso"
btnLetal.Parent = frame

local cornerLetal = Instance.new("UICorner")
cornerLetal.CornerRadius = UDim.new(0, 4)
cornerLetal.Parent = btnLetal

-- Texto de Ayuda Inferior
local hideHintLabel = Instance.new("TextLabel")
hideHintLabel.Size = UDim2.new(1, 0, 0.2, 0)
hideHintLabel.Position = UDim2.new(0, 0, 0.8, 0)
hideHintLabel.BackgroundTransparency = 1
hideHintLabel.Font = Enum.Font.SourceSansItalic
hideHintLabel.TextSize = 11
hideHintLabel.TextColor3 = Color3.fromRGB(150, 150, 150) 
hideHintLabel.Text = "R3: Activar/Apagar | L3: Ocultar"
hideHintLabel.Parent = frame

-- Cambios estéticos al seleccionar los modos
local function actualizarModosVisuales()
    if modoDeteccion == "Cuerpo" then
        btnCuerpo.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
        btnCuerpo.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnLetal.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btnLetal.TextColor3 = Color3.fromRGB(180, 180, 180)
    else
        btnCuerpo.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btnCuerpo.TextColor3 = Color3.fromRGB(180, 180, 180)
        btnLetal.BackgroundColor3 = Color3.fromRGB(255, 75, 75) -- Rojo activo para letal
        btnLetal.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Conexiones Clickeables de los Botones
btnCuerpo.MouseButton1Click:Connect(function()
    modoDeteccion = "Cuerpo"
    actualizarModosVisuales()
end)

btnLetal.MouseButton1Click:Connect(function()
    modoDeteccion = "Letal"
    actualizarModosVisuales()
end)

local function actualizarInterfaz()
    if triggerbotActivo then
        statusLabel.Text = "MIRA MANDO: ACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50) 
    else
        statusLabel.Text = "MIRA MANDO: DESACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end

----------------------------------------------------------------
-- LÓGICA DE DETECCIÓN ADAPTATIVA (0 DELAY)
----------------------------------------------------------------
local function comprobarMiraMando()
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = Camera.CFrame.LookVector * 400 
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    if LocalPlayer.Character then
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, workspace.CurrentCamera}
    end
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if raycastResult and raycastResult.Instance then
        local parteTocada = raycastResult.Instance
        local nombreParte = parteTocada.Name
        local character = parteTocada:FindFirstAncestorOfClass("Model")
        
        if character and character:FindFirstChild("Humanoid") then
            local enemigo = Players:GetPlayerFromCharacter(character)
            if enemigo ~= LocalPlayer and character.Humanoid.Health > 0 then
                
                -- SI EL MODO ES CUERPO COMPLETO: Dispara de inmediato sin importar qué tocó
                if modoDeteccion == "Cuerpo" then
                    return true
                
                -- SI EL MODO ES LETAL: Solo dispara si tocó hitboxes principales de DH
                elseif modoDeteccion == "Letal" then
                    if nombreParte == "Torso" or nombreParte == "UpperTorso" or nombreParte == "LowerTorso" or nombreParte == "Head" or nombreParte == "HumanoidRootPart" then
                        return true
                    end
                end
                
            end
        end
    end
    return false
end

local function forzarDisparo()
    local character = LocalPlayer.Character
    if character then
        local armaEquipada = character:FindFirstChildOfClass("Tool")
        if armaEquipada then
            local nombreArma = armaEquipada.Name
            
            -- FILTRO ANTI-CUCHILLO Y PUÑOS REQUERIDO PARA DH
            if string.match(nombreArma, "Knife") or string.match(nombreArma, "combat") or string.match(nombreArma, "Combat") then
                return 
            end
            
            -- ¡0 DELAY!
            armaEquipada:Activate()
            
            local clickDetector = armaEquipada:FindFirstChild("Click") or armaEquipada:FindFirstChild("OnFire")
            if clickDetector and clickDetector:IsA("BindableEvent") then
                clickDetector:Fire()
            end
        end
    end
end

-- Bucle de fotogramas enganchado al refresco de la pantalla
RunService.RenderStepped:Connect(function()
    if triggerbotActivo then
        if comprobarMiraMando() then
            forzarDisparo()
        end
    end
end)

----------------------------------------------------------------
-- CONTROL POR MANDOS (R3 = ACTIVAR | L3 = OCULTAR INTERFAZ)
----------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input)
    if string.find(tostring(input.UserInputType), "Gamepad") then
        if input.KeyCode == Enum.KeyCode.ButtonR3 then 
            triggerbotActivo = not triggerbotActivo
            actualizarInterfaz()
        end
        
        if input.KeyCode == Enum.KeyCode.ButtonL3 then
            interfazVisible = not interfazVisible
            frame.Visible = interfazVisible
        end
    end
end)
