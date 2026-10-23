--[[
    ============================================================
    心脚本 (Xin Script) - V6.0 工程化终极版
    制作人: 硝基 | 群号: 1012867682
    密钥: mj | 架构: 模块化 UI | 状态自动保存 | 智能防封
    ============================================================
]]

-- ============================================================
-- 模块 1: 依赖引入与全局配置
-- ============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService(“RunService”)
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

本地 CONFIG = {
SecretKey = “mj”，
    KeyFile = "XinScript_Auth.txt",
    ConfigFile = "XinScript_Config.txt"
}

-- ============================================================
-- 模块 2: 文件读写与数据序列化
-- ============================================================
local FileManager = {}

function FileManager.SaveConfig(data)
    if not writefile then return false end
    local serialized = ""
    for k, v in pairs(data) do
        if type(v) == "boolean" then
            serialized = serialized .. k .. "=" .. (v and "1" or "0") .. "\n"
        elseif type(v) == "number" then
            serialized = serialized .. k .. "=" .. tostring(v) .. "\n"
结束
结束
    return pcall(writefile, CONFIG.ConfigFile, serialized)
结束

function FileManager.LoadConfig()
    local data = {}
    if not (isfile and readfile) then return data end
    if not isfile(CONFIG.ConfigFile) then return data end
    
    local success, content = pcall(readfile, CONFIG.ConfigFile)
    if not success or not content then return data end
    
    for line in content:gmatch("[^\n]+") do
        local key, value = line:match("^([^=]+)=([^=]+)$")
        if key and value then
            if value == "1" or value == "0" then
                data[key] = (value == "1")
            else
                data[key] = tonumber(value) or value
            结束
结束
结束
    return data
结束

-- ============================================================
-- 模块 3: 密钥认证系统
-- ============================================================
局部函数 CheckAuth()
如果（isfile为真且readfile为真）不成立，则返回false。结束。
如果 CONFIG.KeyFile 不是文件，则返回 false。
本地成功，内容 = pcall(readfile, CONFIG.KeyFile)
如果成功且内容等于CONFIG.SecretKey，则返回。
结束

local function StartAuthUI()
local AuthGui = Instance.new("ScreenGui")
    AuthGui.Name = "XinAuthUI"
    AuthGui.ResetOnSpawn = false
    AuthGui.DisplayOrder = 999999
    AuthGui.Parent = PlayerGui

local Bg = Instance.new("Frame", AuthGui)
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.BackgroundColor3 = Color3.new(0, 0, 0)
    Bg.BackgroundTransparency = 0.5

local Panel = Instance.new("Frame", AuthGui)
    Panel.Size = UDim2.new(0, 320, 0, 220)
    Panel.Position = UDim2.new(0.5, -160, 0.5, -110)
    Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Panel.Active = true
    Panel.Draggable = true
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Panel)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "🔐 心脚本 V6.0 认证"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18

local Input = Instance.new("TextBox", Panel)
    Input.Size = UDim2.new(1, -40, 0, 40)
    Input.Position = UDim2.new(0, 20, 0, 60)
    Input.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Input.TextColor3 = Color3.new(1, 1, 1)
    Input.PlaceholderText = "请输入密钥..."
    Input.Text = ""
    Input.ClearTextOnFocus = false
Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 6)

local Btn = Instance.new("TextButton", Panel)
    Btn.Size = UDim2.new(1, -40, 0, 40)
    Btn.Position = UDim2.new(0, 20, 0, 115)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Text = "验证并启动"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

local Status = Instance.new("TextLabel", Panel)
    Status.Size = UDim2.new(1, 0, 0, 20)
    Status.Position = UDim2.new(0, 0, 0, 170)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 13

Btn.MouseButton1Click:连接函数()
如果 Input.Text 的小写形式等于 CONFIG.SecretKey，那么
            Status.TextColor3 = Color3.fromRGB(100, 255, 100)
            Status.Text = "✅ 验证成功，正在加载..."
如果writefile为真，则调用pcall函数，传入参数为writefile、CONFIG.KeyFile以及CONFIG.SecretKey。
            task.wait(0.8)
AuthGui:Destroy()
            getgenv().XinScript_AuthPass = true
否则
            Status.Text = "❌ 密钥错误"
            Input.Text = ""
结束
）结束）
结束

如果CheckAuth()返回假值，则
    StartAuthUI()
    repeat task.wait(0.1) until getgenv().XinScript_AuthPass == true
结束

-- ============================================================
-- 模块 4: 智能令牌桶限流器 (带失败降速)
-- ============================================================
local RateLimiter = {}
RateLimiter.__index = RateLimiter

function RateLimiter.new(速率, 短期峰值)
    return setmetatable({
        baseRate = rate,
        rate = rate,
        burst = burst,
        tokens = burst,
        lastTick = tick(),
        penalty = 1
    }, RateLimiter)
结束

函数 RateLimiter:Consume()
本地当前时间 = tick()
局部增量 = math.min(现在时间 - 自上次计时时间, 1)
self.lastTick = 现在的时间
self.tokens = math.min(self.burst, self.tokens + (self.rate * delta))
    
如果 self.tokens >= 1，则
        self.tokens -= 1
返回true
结束
返回 false
结束

function RateLimiter:ReportFailure()
    self.penalty = math.max(0.1, self.penalty * 0.5)
    self.rate = self.baseRate * self.penalty
    self.tokens = 0
结束

本地限流器：Train = RateLimiter.new(3, 5)
本地限流器Eat = RateLimiter.new(0.5, 2)
local limiterRebirth = RateLimiter.new(0.2, 1)

-- ============================================================
-- 模块 5: 游戏核心状态与逻辑
-- ============================================================
local State = {
    AutoTrain = false, AutoEgg = false, AutoElixir = false, AutoRebirth = false,
    AutoBoss = false, KillAura = false, AntiKB = false, WaterWalk = false,
    MoveSpeed = 16
}

local isUsingTool = false
本地lastRebirth = 0

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

局部函数 PerformHit()
local char = LocalPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
如果既不是字符也不是人类，则返回结束。
    
    local success = pcall(function()
local punch = char:FindFirstChild("Punch") 或 LocalPlayer.Backpack:FindFirstChild("Punch")
如果进行拳击攻击的话，则
if punch.Parent ~= char then punch.Parent = char end
hum：装备工具（冲头）
punch：Activate()
结束
LocalPlayer.muscleEvent：向服务器发送“rep”指令。
LocalPlayer.muscleEvent：向服务器发送“punch”指令，指定使用左手攻击。
LocalPlayer.muscleEvent：向服务器发送“punch”指令，指定使用右手攻击。
）结束）
    
    if not success then
        limiterTrain:ReportFailure()
结束
结束

局部函数 GetNearestEnemy()
local char = LocalPlayer.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
如果 hrp 为假，则返回 nil 结束

本地最近值，minDist = nil，100
    local searchFolders = {
        workspace:FindFirstChild("Enemies"),
        workspace:FindFirstChild("Events") and workspace.Events:FindFirstChild("BossArena")
    }

for _, folder in ipairs(searchFolders) do
如果存在文件夹，则
            for _, v in ipairs(folder:GetChildren()) do
如果 v 是“模型”类型，并且 v 包含名为“Humanoid”的子元素，则
本地 vHrp = v:FindFirstChild(“人形根部部件”) 或 v.PrimaryPart
嗡声
局部距离 = (hrp.Position - vHrp.Position).Magnitude
如果 dist < minDist，那么
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

-- 防挂机
LocalPlayer.Idled:Connect(函数())
pcall(函数())
VirtualUser：CaptureController()
VirtualUser：点击按钮2（Vector2.new()）
    结束)
结束）

-- ============================================================
-- 模块 6：主循环（心跳）
-- ============================================================
如果 getgenv().XinScript_HB 为真，则
pcall(函数() getgenv().XinScript_HB:Disconnect() 结束)
结束

本地tickAccumulator =0
getgenv().XinScript_HB = RunService.Heartbeat:Connect(函数(dt)
tickAccumulator += dt
如果tickAccumulator小于0.1，则返回。结束。
tickAccumulator =0

本地 char = LocalPlayer.Character
本地 hrp = char 和 char:FindFirstChild(“人形根部部件”)
本地 hum = char 和 char:FindFirstChildOfClass(“类人生物”)
    
如果不是hrp，或者不是nothum，又或者hum.Health小于或等于0th
