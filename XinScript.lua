--[[
    ========================================================
    心脚本 V9.7 公益开源完美版
    作者: 硝基
    特性: 极限防封 / 屏幕边界防丢 / 定向寻敌优化 / 绝对无报错
    ========================================================
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Debris            = game:GetService("Debris")
local VirtualUser       = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local State = {
    Train = false, Elixir = false, Egg = false, Rebirth = false,
    Boss = false, Aura = false, KB = false, Walk = false, 
    Fly = false, AntiAFK = true, Speed = 16
}

local isToolEquipping = false
local Cooldowns = { hit = 0, elixir = 0, rebirth = 0, boss = 0, aura = 0, afk = 0 }
local FlyVelocity, FlyForce
local MuscleEvent = LocalPlayer:FindFirstChild("muscleEvent") or ReplicatedStorage:FindFirstChild("muscleEvent")

if not MuscleEvent then
    task.spawn(function()
        MuscleEvent = LocalPlayer:WaitForChild("muscleEvent", 10) or ReplicatedStorage:WaitForChild("muscleEvent", 10)
    end)
end

local function getCharacter()
    local char = LocalPlayer.Character
    if not char or not char.Parent then return nil, nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then return nil, nil, nil end
    return char, hum, hrp
end

local function executeHit()
    pcall(function()
        local char, hum = getCharacter()
        if not char or not hum then return end
        
        local punch = char:FindFirstChild("Punch") or LocalPlayer.Backpack:FindFirstChild("Punch")
        if punch then
            if punch.Parent ~= char then 
                if hum:FindFirstChildOfClass("Tool") then 
                    hum:UnequipTools()
                    task.wait(0.1)
                end
                punch.Parent = char 
            end
            
            if char:FindFirstChildWhichIsA("Tool") ~= punch then 
                hum:EquipTool(punch)
                task.wait(0.1) 
            end
            
            punch:Activate()
        end
        
        if MuscleEvent then 
            MuscleEvent:FireServer("rep") 
        end
    end)
end

local function useTool(toolName)
    if isToolEquipping then return end
    isToolEquipping = true
    
    task.spawn(function()
        pcall(function()
            local char, hum = getCharacter()
            if not char or not hum then return end
            
            local tool = LocalPlayer.Backpack:FindFirstChild(toolName) or char:FindFirstChild(toolName)
            if tool then
                if hum:FindFirstChildOfClass("Tool") then 
                    hum:UnequipTools()
                    task.wait(0.1) 
                end
                tool.Parent = char
                hum:EquipTool(tool)
                task.wait(0.2)
                tool:Activate()
                task.wait(0.4)
            end
        end)
        isToolEquipping = false 
    end)
end

local function startFly()
    local _, hum, hrp = getCharacter()
    if not (hum and hrp) then return end
    
    if FlyVelocity then FlyVelocity:Destroy() end
    if FlyForce then FlyForce:Destroy() end
    
    hum.PlatformStand = true
    
    FlyVelocity = Instance.new("BodyVelocity", hrp)
    FlyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    FlyVelocity.Velocity = Vector3.new(0, 0, 0)
    
    FlyForce = Instance.new("BodyForce", hrp)
    FlyForce.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass() * 1.2, 0) 
end

local function stopFly()
    if FlyVelocity then FlyVelocity:Destroy(); FlyVelocity = nil end
    if FlyForce then FlyForce:Destroy(); FlyForce = nil end
    
    local _, hum, hrp = getCharacter()
    if hum and hrp then 
        hum.PlatformStand = false 
        local buffer = Instance.new("BodyVelocity", hrp)
        buffer.Velocity = Vector3.new(0, -30, 0)
        buffer.MaxForce = Vector3.new(0, 1e4, 0)
        Debris:AddItem(buffer, 0.15)
    end
end

LocalPlayer.CharacterRemoving:Connect(function()
    if FlyVelocity then FlyVelocity:Destroy(); FlyVelocity = nil end
    if FlyForce then FlyForce:Destroy(); FlyForce = nil end
end)

RunService.Heartbeat:Connect(function()
    local now = os.clock()
    local char, hum, hrp = getCharacter()
    if not (char and hum and hrp) then return end

    if State.AntiAFK and (now - Cooldowns.afk >= 20) then
        Cooldowns.afk = now
        if hum.MoveDirection.Magnitude == 0 then
            hum.Jump = true
        end
    end

    if State.Train and (now - Cooldowns.hit >= 0.35) then
        Cooldowns.hit = now
        executeHit()
    end

    if (State.Elixir or State.Egg) and not isToolEquipping and (now - Cooldowns.elixir >= 2) then
        Cooldowns.elixir = now
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            if State.Elixir then
                local elixir = backpack:FindFirstChild("Spooky XP Elixir III") 
                            or backpack:FindFirstChild("Spooky XP Elixir II") 
                            or backpack:FindFirstChild("Tropical Shake")
                if elixir then useTool(elixir.Name) end
            end
            if State.Egg and backpack:FindFirstChild("Protein Egg") then 
                useTool("Protein Egg") 
            end
        end
    end

    if State.Rebirth and (now - Cooldowns.rebirth >= 8) then
        Cooldowns.rebirth = now
        local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
        local remote = rEvents and rEvents:FindFirstChild("rebirthRemote")
        if remote then 
            pcall(function() remote:InvokeServer("rebirthRequest") end) 
        end
    end

    if State.Boss and (now - Cooldowns.boss >= 0.5) then
        Cooldowns.boss = now
        local target, minDist = nil, math.huge
        
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name:lower():find("boss") then
                local bHrp = obj:FindFirstChild("HumanoidRootPart")
                local bHum = obj:FindFirstChildOfClass("Humanoid")
                if bHrp and bHum and bHum.Health > 0 then
                    local dist = (hrp.Position - bHrp.Position).Magnitude
                    if dist < minDist then minDist = dist; target = bHrp end
                end
            elseif obj:IsA("Folder") then
                for _, subObj in ipairs(obj:GetChildren()) do
                    if subObj:IsA("Model") and subObj.Name:lower():find("boss") then
                        local bHrp = subObj:FindFirstChild("HumanoidRootPart")
                        local bHum = subObj:FindFirstChildOfClass("Humanoid")
                        if bHrp and bHum and bHum.Health > 0 then
                            local dist = (hrp.Position - bHrp.Position).Magnitude
                            if dist < minDist then minDist = dist; target = bHrp end
                        end
                    end
                end
            end
        end
        
        if target then
            if minDist > 10 then 
                hum:MoveTo(target.Position) 
            else 
                hum:MoveTo(hrp.Position) 
                executeHit() 
            end
        end
    end

    if State.Aura and (now - Cooldowns.aura >= 0.5) then
        Cooldowns.aura = now
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local pHrp = player.Character:FindFirstChild("HumanoidRootPart")
                local pHum = player.Character:FindFirstChildOfClass("Humanoid")
                if pHrp and pHum and pHum.Health > 0 and (hrp.Position - pHrp.Position).Magnitude < 30 then
                    executeHit() 
                    break
                end
            end
        end
    end

    if State.KB then
        if not hrp:FindFirstChild("XinAntiKB") then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "XinAntiKB"
            bv.MaxForce = Vector3.new(math.huge, 0, math.huge)
            bv.Velocity = Vector3.new(0, 0, 0)
        end
    else
        local bv = hrp:FindFirstChild("XinAntiKB")
        if bv then bv:Destroy() end
    end

    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if State.Walk then
        if terrain then terrain.WaterWaveHeight = 0 end
        if not hrp.CustomPhysicalProperties or hrp.CustomPhysicalProperties.Density ~= 0.01 then 
            hrp.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.5, 0.5, 0, 0) 
        end
    else
        if terrain and terrain.WaterWaveHeight ~= 0.5 then terrain.WaterWaveHeight = 0.5 end
        if hrp.CustomPhysicalProperties then hrp.CustomPhysicalProperties = nil end
    end

    if hum.WalkSpeed ~= State.Speed then 
        hum.WalkSpeed = State.Speed 
    end

    if State.Fly then
        if not FlyVelocity or not FlyVelocity.Parent or FlyVelocity.Parent ~= hrp then 
            startFly() 
        end
        hum.PlatformStand = true
        
        if FlyVelocity then
            local direction = Vector3.new(0, 0, 0)
            local camera = workspace.CurrentCamera
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
            
            local vertical = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = 1 
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical = -1 end
            
            direction = direction + Vector3.new(0, vertical, 0)
            FlyVelocity.Veloci
