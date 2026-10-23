-- ============================================================
-- 心脚本 V8.0 终极完全体 | 制作人: 硝基 | 密钥: mj
-- 全功能集成 | 智能限流防封 | 双端完美拖拽 | 极限防错
-- ============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local CONFIG = { Key = "mj", KF = "Xin_Auth.txt", CF = "Xin_Config.txt" }

-- ============================================================
-- 1. 密钥认证系统
-- ============================================================
local function checkAuth()
    if not (isfile and readfile) then return false end
    if not isfile(CONFIG.KF) then return false end
    local ok, content = pcall(readfile, CONFIG.KF)
    return ok and content == CONFIG.Key
end

if not checkAuth() then
    local g = Instance.new("ScreenGui", PG); g.Name = "AuthUI"; g.DisplayOrder = 999999
    local b = Instance.new("Frame", g); b.Size = UDim2.new(1,0,1,0); b.BackgroundColor3 = Color3.new(0,0,0); b.BackgroundTransparency = 0.5
    local p = Instance.new("Frame", g); p.Size = UDim2.new(0,300,0,200); p.Position = UDim2.new(0.5,-150,0.5,-100); p.BackgroundColor3 = Color3.fromRGB(20,20,25)
    Instance.new("UICorner", p).CornerRadius = UDim.new(0,10)
    local t = Instance.new("TextLabel", p); t.Size = UDim2.new(1,0,0,40); t.BackgroundTransparency = 1; t.Text = "🔐 心脚本 认证"; t.TextColor3 = Color3.new(1,1,1); t.Font = Enum.Font.GothamBold
    local inp = Instance.new("TextBox", p); inp.Size = UDim2.new(1,-40,0,40); inp.Position = UDim2.new(0,20,0,60); inp.BackgroundColor3 = Color3.fromRGB(35,35,40); inp.TextColor3 = Color3.new(1,1,1); inp.PlaceholderText = "请输入密钥 (mj)"
    local btn = Instance.new("TextButton", p); btn.Size = UDim2.new(1,-40,0,40); btn.Position = UDim2.new(0,20,0,115); btn.BackgroundColor3 = Color3.fromRGB(50,160,80); btn.TextColor3 = Color3.new(1,1,1); btn.Text = "验证"
    local v = false
    btn.MouseButton1Click:Connect(function() 
        if inp.Text:lower() == CONFIG.Key then 
            if writefile then pcall(writefile, CONFIG.KF, CONFIG.Key) end
            g:Destroy(); v = true 
        end 
    end)
    repeat task.wait(0.1) until v
end

-- ============================================================
-- 2. 智能限流器 (防封核心)
-- ============================================================
local RL = {} RL.__index = RL
function RL.new(r,b) return setmetatable({r=r,b=b,t=b,l=tick()}, RL) end
function RL:Use() 
    local n=tick(); local d=math.min(n-self.l,1); self.l=n; self.t=math.min(self.b,self.t+self.r*d)
    if self.t>=1 then self.t=self.t-1; return true end; return false 
end
local limTrain, limEat = RL.new(3,5), RL.new(0.5,2)

-- ============================================================
-- 3. 全局状态与配置保存
-- ============================================================
local State = { Train=false, Egg=false, Elixir=false, Rebirth=false, Boss=false, Aura=false, KB=false, Walk=false, Speed=16 }
local function saveCfg()
    if not writefile then return end
    本地 str = ""
    为了 k,v 在……里面 pairs(State) 做 
        str = str..k.."="..(type(v)=="boolean" 和 (v 和 "1" 或 "0") or tostring(v)).."\n" 
    结束
pcall(writefile, CONFIG.CF, str)
结束
如果 isfile 和 readfile 和 isfile(CONFIG.CF) 然后
    为了 line in readfile(CONFIG.CF):gmatch("[^\n]+") do
        本地 k,v = line:match("^([^=]+)=([^=]+)$")
        如果 k and v 然后
            如果 v=="1" 然后 State[k]=真实
            elseif v=="0" 然后 State[k]=虚假
            否则 State[k]=tonumber(v) or v 结束
        结束
    结束
结束

-- ============================================================
-- 4. 核心执行逻辑
-- ============================================================
本地 isTool, lastR = false, 0

本地 函数 useTool(name)
    如果 isTool 然后 return 结束
    task.spawn(函数()
        isTool=真实
        pcall(function()
            本地 c=LP.Character
            本地 h=c and c:FindFirstChildOfClass(“类人生物”)
            如果 不 h 然后 return 结束
            本地 t=LP.Backpack:FindFirstChild(name) or c:FindFirstChild(name)
            如果 t 然后
t.Parent=c
h:装备工具(t)
                task.wait(0.1)
t:激活()
                task.wait(0.2)
            结束
        结束)
        task.wait(0.2)
        isTool=false
    结束)
结束

本地 function hit()
    pcall(function()
        本地 c=LP.Character
        本地 h=c 和 c:FindFirstChildOfClass(“类人生物”)
        如果 不 h 然后 return 结束
        本地 p=c:FindFirstChild("Punch") 或 LP.Backpack:FindFirstChild("Punch")
        如果 p 然后
            如果 p.Parent~=c 然后 p.Parent=c 结束
h:装备工具(p)
p:激活()
        结束
        LP.muscleEvent:FireServer("rep")
        LP.muscleEvent:FireServer("punch","leftHand")
        LP.muscleEvent:FireServer("punch","rightHand")
    结束)
结束

本地 函数 getEnemy(hrp)
    本地 n,md=无,100
    本地 folders={workspace:FindFirstChild("Enemies"),workspace:FindFirstChild("Events") 和 workspace.Events:FindFirstChild("BossArena")}
    为了 _,f 在……里面 ipairs(folders) 做
        如果 f 然后
            for _,v in ipairs(f:GetChildren()) do
                如果 v:IsA("Model") 和 v:FindFirstChildOfClass("Humanoid") 然后
                    本地 h=v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                    如果 h 然后
                        本地 d=(hrp.Position-h.Position).Magnitude
                        如果 d<md 然后 md=d n=v 结束
                    结束
                结束
            结束
        结束
    结束
    return n
结束

-- 防挂机踢出
LP.Idled:Connect(函数() 
    如果 State.Aura or State.Train 然后 
        pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) 结束) 
    end 
end)

-- 主循环
本地 tickAcc = 0
RunService.Heartbeat:Connect函数（参数：dt）
tickAcc+=dt
    如果 tickAcc<0.1 then return 结束
tickAcc=0
    
    本地 c=LP.Character
    本地 h=c 和 c:FindFirstChild("HumanoidRootPart")
    本地 m=c 和 c:FindFirstChildOfClass("Humanoid")
    如果 不 h 或 不 m 或 m.Health<=0 然后 return 结束

    -- 锻炼
    如果 State.Train 和 limTrain:Use() 然后 hit() 结束
    
    -- 吃药水
    如果 State.Elixir 和 State.KB isTool 和 limEat:Use() 然后
        本地 e=LP.Backpack:FindFirstChild("Spooky XP Elixir III") 或 LP.Backpack:FindFirstChild("Spooky XP Elixir II") or LP.Backpack:FindFirstChild("Spooky XP Elixir I") or LP.Backpack:FindFirstChild("Tropical Shake")
        如果 e 然后 useTool(e.Name) 结束
    结束
    
    -- 吃蛋
如果 State.Egg 且 不是Tool 且 limEat:Use()，那么
如果 LP.Backpack:FindFirstChild(“蛋白蛋”)，然后使用工具(“蛋白蛋”)即可结束。
    结束
    
    -- 重生
如果 State.Rebirth和 tick()-lastR>5 然后
lastR=tick()
pcall(函数() ReplicatedStorage.rEvents.rebirthRemote:InvokeServer(“重生请求”) 结束)
    结束
    
-- 打BOSS
如果 State.Boss 然后
        本地 en=getEnemy(h)
如果 en 然后
            本地 eh=en：查找现有的子对象（“人形主体部分”）或 en.PrimaryPart
            如果 eh 然后
                如果 (h.Position-eh.Position).Magnitude>12 然后 m:MoveTo(eh.Position)
否则，执行m:MoveTo(h.Position)；如果limTrain:Use()被调用，那么随后执行hit()，之后程序结束。
            结束
        结束
    结束
    
-- 消除光环
如果 State.Aura 然后
为了_，p是通过ipairs(Players:GetPlayers())在……中获取的。
如果 p~=LP，且 p.Character 以及 p.Character:FindFirstChild(“人形主体部分”) 都存在的话，那么
                本地 ph=p.Character:FindFirstChildOfClass(“类人生物”)
                如果 ph 和 ph.Health>0和 (h.Position-p.Character.HumanoidRootPart.Position).Magnitude<30 然后
如果调用 limTrain:Use()，那么 hit() 就会结束
                    中断
                结束
            结束
        结束
    结束
    
    -- 防击飞
如果 State.KB 然后
如果不存在：FindFirstChild(
本地 bv=Instance.new(“身体速度”,h) bv.Name=“AntiKB”bv.MaxForce=Vector3.new(1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero1e5) 例如：速度=Vector3.zero0,1e5) 例如：速度=Vector3.zero
        结束
    否则
        本地 bv=h:FindFirstChild(
“AntiKB”
“XinUI”
    -- 水上行走
如果 State.Walk 然后
; sg.IgnoreGuiInset=
真实0 结束
h.CustomPhysicalProperties=PhysicalProperties.new(0.01,0.5,0.5,0,0)
    否则
本地 ter=workspace:FindFirstChildOfClass(“地形”)
真实如果 State.Speed~= 结束
h.CustomPhysicalProperties=无
    结束
    
    -- 速度
如果 State.Speed~=16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16，则令 m.WalkSpeed=State.Speed，结束。16然后 m.WalkSpeed=State.Speed 结束
结束)

-- ============================================================
-- 5. UI框架（暗黑悬浮窗）
-- ============================================================
如果 getgenv().XinUI，然后 pcall(函数() getgenv().XinUI:Destroy()) 结束，则流程结束。
本地 sg = Instance.new(“ScreenGui”, PG); sg.Name=“XinUI”; sg.ResetOnSpawn=虚假; sg.DisplayOrder=99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实99999; sg.IgnoreGuiInset=真实
getgenv().XinUI = sg
本地 sc = Instance.new(“UIScale”, sg); sc.Scale = (UserInputService.TouchEnabled与UserInputService.KeyboardEnabled的值的)0.85或10.85 或 1

本地mf = Instance.new(0,360,0,400)；mf.Position=UDim2.new(0.3,0,0.2,0)；mf.BackgroundColor3=Color3.fromRGB(18,18,22)；mf.Active=真实；mf.ClipsDescendants=真实0,360,0,400); mf.Position=UDim2.new(0.3,0,0.2,0); mf.BackgroundColor3=Color3.fromRGB(18,18,22); mf.Active=真实; mf.ClipsDescendants=真实
Instance.new(“UICorner”,mf).CornerRadius=UDim.new(0,8)
本地 bg = Instance.new(“图像标签”,mf); bg.Size=UDim2.new(1,0,1,0); 背景透明度=1; 背景图片="rbxassetid://13161221098"; bg.ScaleType=Enum.ScaleType.Crop
Instance.new(“UICorner”,bg).CornerRadius=UDim.new(0,8)0,8)
本地 dm = Instance.new(“框架”,mf); dm.Size=UDim2.new(1,0,1,0); dm.BackgroundColor3=Color3.new(0,0,0); dm.BackgroundTransparency=0.4 
Instance.new(“UICorner”,dm).CornerRadius=UDim.new(0,8)0,8)
本地 tb = Instance.new(“文本标签”,mf); tb.Size=UDim2.new(1,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.01,0,0,35); tb.BackgroundTransparency=1; tb.Text=“心脚本 V8.0
