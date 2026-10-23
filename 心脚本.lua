--[[
    ============================================================
心脚本 (Xin Script) - 力量传奇
    制作人: 硝基 | 群号: 1012867682
GitHub专用版 | 适配PC/移动端 | 防封限流 | 极致流畅
    ============================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- 🔐 1. 密钥认证系统 (密钥: mj)
-- ============================================================
本地 CONFIG = {
SecretKey = “mj”，
KeyFile = “XinScript_Auth.txt”
}

局部函数 CheckAuth()
如果（isfile为真且readfile为真）不成立，则返回false。结束。
如果 CONFIG.KeyFile 不是文件，则返回 false。
本地成功，内容 = pcall(readfile, CONFIG.KeyFile)
返回成功状态，且内容等于CONFIG.SecretKey
结束

如果CheckAuth()返回假值，则
local AuthGui = Instance.new("ScreenGui")
AuthGui.Name = “XinAuthUI”
AuthGui.ResetOnSpawn = false
AuthGui.DisplayOrder = 999999
AuthGui.Parent = PlayerGui

local Bg = Instance.new("Frame", AuthGui)
Bg.Size = UDim2.new(1, 0, 1, 0)
Bg.BackgroundColor3 = Color3.new(0, 0, 0)
Bg.BackgroundTransparency = 0.5

local Panel = Instance.new("Frame", AuthGui)
Panel.Size = UDim2.new(0, 300, 0, 200)
Panel.Position = UDim2.new(0.5, -150, 0.5, -100)
Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Panel.Active = true
Panel.Draggable = true
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1, 0, 0, 40)
标题.背景透明度 = 1
    Title.Text = "🔐 心脚本 认证"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local Input = Instance.new("TextBox", Panel)
Input.Size = UDim2.new(1, -40, 0, 40)
Input.Position = UDim2.new(0, 20, 0, 55)
Input.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Input.TextColor3 = Color3.new(1, 1, 1)
Input.PlaceholderText = “请输入密钥...”
Input.Text = ""
Input.ClearTextOnFocus = false
Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 6)

local Btn = Instance.new("TextButton", Panel)
Btn.Size = UDim2.new(1, -40, 0, 40)
Btn.Position = UDim2.new(0, 20, 0, 110)
Btn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Text = “验证并启动”
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 16
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

本地验证状态 = 否
Btn.MouseButton1Click:连接函数()
如果 Input.Text 的小写形式等于 CONFIG.SecretKey，那么
如果writefile为真，则调用pcall函数，传入参数为WRITEFILE、CONFIG.KeyFile以及CONFIG.SecretKey。
AuthGui:Destroy()
            已验证 = true
        否则
            Input.Text = ""
        结束
）结束）

重复执行 task.wait(0.1) 操作，直到验证通过为止。
结束

-- ============================================================
-- ⚙️ 2. 令牌桶限流器 (防封核心)
-- ============================================================
local RateLimiter = {}
RateLimiter.__index = RateLimiter

function RateLimiter.new(rate, burst)
    返回 setmetatable({
        rate = rate,       -- 每秒恢复的令牌数
        burst = burst,     -- 最大容量
        tokens = burst,    -- 当前的令牌数量
lastTick = tick()
}, RateLimiter)
结束

函数 RateLimiter:Consume()
局部变量 now = tick()
    local delta = math.min(now - self.lastTick, 1) -- 限制单次最大恢复时间
self.lastTick = 现在的时间
self.tokens = math.min(self.burst, self.tokens + (self.rate * delta))
    
如果 self.tokens >= 1，则
        self.tokens -= 1
返回true
    结束
返回 false
结束

-- 设置发包频率：锻炼每秒最多3次，吃药每2秒最多1次，防止服务器踢人
本地限流器：Train = RateLimiter.new(3, 5)
本地限流器Eat = RateLimiter.new(0.5, 2)

-- ============================================================
-- 🧠 3. 游戏核心逻辑 (状态与函数)
-- ============================================================
本地状态 = {
AutoTrain = false，AutoEgg = false，AutoElixir = false，AutoRebirth = false，
AutoBoss = false，KillAura = false，AntiKB = false，WaterWalk = false
}

local isUsingTool = false
本地lastRebirth = 0

-- 异步安全使用工具（防止卡顿）
局部函数 UseToolAsync(toolName)
如果正在使用工具，则返回。
    task.spawn(function()
isUsingTool = true
pcall(function())
            局部字符 = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
如果不是hum，则返回，结束。
            
local tool = LocalPlayer.Backpack:FindFirstChild(toolName) 或 char:FindFirstChild(toolName)
            如果 tool 且 tool:IsA("Tool")，那么
tool.Parent = char
hum:装备工具（工具）
task.wait(0.1)
工具：Activate()
task.wait(0.2)
            结束
        结束）
task.wait(0.2)
isUsingTool = false
）结束）
结束

-- 出拳攻击逻辑
局部函数 PerformHit()
local char = LocalPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
如果既不是字符也不是人类，则返回结束。
    
pcall(function())
local punch = char:FindFirstChild("Punch") 或 LocalPlayer.Backpack:FindFirstChild("Punch")
如果进行打击的话，那么
if punch.Parent ~= char then punch.Parent = char end
hum：装备工具（冲头）
punch：Activate()
        结束
        -- 双触发确保服务器判定有效
LocalPlayer.muscleEvent：向服务器发送“rep”指令。
LocalPlayer.muscleEvent：向服务器发送“punch”指令，指定使用“leftHand”手部进行攻击。
LocalPlayer.muscleEvent：向服务器发送“punch”指令，指定使用右手攻击。
）结束）
结束

-- 寻找最近敌人/BOSS（优化性能）
局部函数 GetNearestEnemy()
local char = LocalPlayer.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
如果 hrp 为假，则返回 nil 结束。

本地最近值，minDist = nil, 100
    -- 只遍历特定文件夹，绝不扫全图
    local搜索文件夹列表 = {
workspace:FindFirstChild("Enemies"),
workspace:查找是否存在名为“Events”的元素，如果存在，则再查找该元素中是否包含名为“BossArena”的元素。
    }

for _, folder in ipairs(searchFolders) do
如果存在文件夹，则
            for _, v in ipairs(folder:GetDescendants()) do
如果 v 是“模型”类型，并且 v 包含名为“Humanoid”的子元素，那么
local vHrp = v:FindFirstChild("HumanoidRootPart") 或 v.PrimaryPart
如果vHrp为真，则
local dist = (hrp.Position - vHrp.Position).Magnitude
                        如果 dist 小于 minDist，则
minDist = dist
最近值 = v
                        结束
                    结束
                结束
            结束
        结束
结束
返回最近的
结束

-- ============================================================
-- 🔄 4. 主循环（心跳节流100ms）
-- ============================================================
本地tickAccumulator = 0
RunService.Heartbeat:Connect函数（参数：dt）
tickAccumulator += dt
如果tickAccumulator小于0.1，则返回结束。
tickAccumulator = 0

local char = LocalPlayer.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
    
如果 hrp 为假，或者 hum 为假，又或者 hum.Health 小于或等于 0，则返回即可。

    -- 自动锻炼 (限流保护)
如果 State.AutoTrain 为真且 limiterTrain:Consume() 的返回值为真，则执行相应操作。
        执行命中处理()
结束

    -- 自动吃药水
如果 State.AutoElixir 为真，且未使用工具，同时满足 limiterEat:Consume() 的条件，则执行相应操作。
local elixir = LocalPlayer.Backpack:FindFirstChild("Spooky XP Elixir III")
或者使用LocalPlayer.Backpack：FindFirstChild(“Spooky XP Elixir II”)
或者使用LocalPlayer.Backpack：FindFirstChild(“Spooky XP Elixir I”)
或者使用LocalPlayer.Backpack：FindFirstChild(“Tropical Shake”)
如果存在elixir，则使用异步方式调用UseToolAsync函数，传入elixir的名称作为参数。
结束

    -- 自动吃蛋
如果 State.AutoEgg为真，且未使用工具，同时limiterEat：Consume()函数被调用，则执行相应操作。
如果LocalPlayer.Backpack中存在名为“Protein Egg”的元素，则
UseToolAsync("蛋白质蛋”)
        结束
结束

    -- 自动重生 (5秒硬冷却)
如果 State.AutoRebirth 为真，且 tick() – lastRebirth 的值大于5，则
lastRebirth = tick()
pcall(function())
ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
        结束）
结束

-- 自动打BOSS
如果State.AutoBoss为真，则
        当前附近的敌人 = 获取最近的敌人()
如果存在敌人，则
本地eHrp = enemy:FindFirstChild(“人形根部部件”) 或 enemy.PrimaryPart
如果eHrp为真，则
局部距离 = (hrp.Position - eHrp.Position).Magnitude
                如果距离大于12，则
哼：MoveTo(eHrp.Position)-- 自动寻路
                否则
hum：移动到(hrp.Position)位置-- 停止攻击
如果limiterTrain:Consume()返回真值，则执行PerformHit()操作。
                结束
            结束
        结束
结束

-- 消除光环
如果State.KillAura为真，则
为了_，玩家在 ipairs(Players:GetPlayers()) 中进行操作
如果玩家不是本地玩家，且该玩家拥有角色的话
本地pHrp = player.Character:FindFirstChild(“人形根部部件”)
本地pHum = player.Character:FindFirstChildOfClass(“类人生物”)
如果pHrp、pHum以及pHum.Health的值都大于0，则
如果 (hrp.Position - pHrp.Position).Magnitude <30，那么
如果limiterTrain:Consume()返回真值，则执行PerformHit()操作。
                        中断
                    结束
                结束
            结束
        结束
结束

    -- 防击飞
如果State.AntiKB为真，则
如果 hrp：FindFirstChild(“AntiKB_Velocity”) 的返回值为假，则
            本地bv = Instance.new(
bv.Name = “AntiKB_Velocity”
bv.MaxForce = Vector3.ne
