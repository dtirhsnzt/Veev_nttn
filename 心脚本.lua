-- ============================================================
-- 心脚本 | 套用暗黑悬浮窗模板
-- 制作人: 硝基 | 群: 1012867682
-- ============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- 清理旧版
local old = PlayerGui:FindFirstChild("XinScript"); if old then old:Destroy() end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XinScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 99999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local scale = Instance.new("UIScale", ScreenGui)
scale.Scale = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) and 0.85 or 1

--==================== 主窗口 ====================
local MainWindow = Instance.new("Frame")
MainWindow.Name = "GenericHubUI"
MainWindow.Parent = ScreenGui
MainWindow.Size = UDim2.new(0, 360, 0, 360)
MainWindow.Position = UDim2.new(0.3, 0, 0.2, 0)
MainWindow.ClipsDescendants = true
MainWindow.Active = true
Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 8)

-- 窗口背景图（替换图片ID即可）
local BGImage = Instance.new("ImageLabel")
BGImage.Parent = MainWindow
BGImage.Size = UDim2.new(1, 0, 1, 0)
BGImage.Position = UDim2.new(0, 0, 0, 0)
BGImage.BackgroundTransparency = 1
BGImage.Image = "rbxassetid://13161221098" -- 随便找了个暗黑背景图，你可以替换成你自己的
BGImage.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", BGImage).CornerRadius = UDim.new(0, 8)

-- 半透明黑色遮罩，提升文字可读性
local DarkMask = Instance.new("Frame")
DarkMask.Parent = MainWindow
DarkMask.Size = UDim2.new(1, 0, 1, 0)
DarkMask.Position = UDim2.new(0, 0, 0, 0)
DarkMask.BackgroundColor3 = Color3.new(0, 0, 0)
DarkMask.BackgroundTransparency = 0.4
Instance.new("UICorner", DarkMask).CornerRadius = UDim.new(0, 8)

-- 窗口标题
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainWindow
TitleLabel.Size = UDim2.new(1, 0, 0, 32)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "心脚本"
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.Active = false -- 防止拖拽被拦截

-- 关闭按钮
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = MainWindow
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 14
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

--==================== 标签栏 (切换页面) ====================
local TabBar = Instance.new("Frame")
TabBar.Parent = MainWindow
TabBar.Size = UDim2.new(1, -10, 0, 28)
TabBar.Position = UDim2.new(0, 5, 0, 35)
TabBar.BackgroundTransparency = 1
local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)

-- 存放各个页面的容器
local PageContainer = Instance.new("Frame")
PageContainer.Parent = MainWindow
PageContainer.Size = UDim2.new(1, -10, 1, -70)
PageContainer.Position = UDim2.new(0, 5, 0, 65)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function SwitchPage(pageName)
    for _, p in pairs(Pages) do p.frame.Visible = false end
    for _, b in pairs(TabBar:GetChildren()) do
        if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(30, 30, 35) end
    end
    if Pages[pageName] then
        Pages[pageName].frame.Visible = true
        Pages[pageName].btn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
    end
end

local function CreatePage(name)
    local btn = Instance.new("TextButton")
    btn.Parent = TabBar
    btn.Size = UDim2.new(0.25, -4, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local frame = Instance.new("ScrollingFrame")
    frame.Parent = PageContainer
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 3
    frame.Visible = false
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 4)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    Pages[name] = {btn = btn, frame = frame}
    btn.MouseButton1Click:Connect(function() SwitchPage(name) end)
    return frame
end

--==================== 控件生成函数 ====================
-- 改造后的开关函数，带真实点击逻辑
local function CreateToggleOption(parent, optionName, callback)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.Size = UDim2.new(1, -10, 0, 30)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 4)

    local nameText = Instance.new("TextLabel")
    nameText.Parent = container
    nameText.Size = UDim2.new(1, -45, 1, 0)
    nameText.Position = UDim2.new(0, 10, 0, 0)
    nameText.BackgroundTransparency = 1
    nameText.Text = optionName
    nameText.TextColor3 = Color3.new(1, 1, 1)
    nameText.TextSize = 13
    nameText.Font = Enum.Font.SourceSans
    nameText.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = container
    toggleBtn.Size = UDim2.new(0, 34, 0, 18)
    toggleBtn.Position = UDim2.new(1, -44, 0.5, -9)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Parent = toggleBtn
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = false
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
            knob.Position = UDim2.new(1, -16, 0.5, -7)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            knob.Position = UDim2.new(0, 2, 0.5, -7)
        end
        callback(state)
    end)
end

-- 传送按钮函数
local function CreateButtonOption(parent, btnText, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(50, 80, 140)
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = btnText
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
end

--==================== 状态与核心逻辑 ====================
local S = { Train = false, Reb = false, Aura = false, Boss = false, EatEgg = false, EatItem = false }
local cooldowns = { Reb = 0, Eat = 0, Train = 0 }
local isUsingTool = false

local function UseToolAsync(toolName, hum, char)
    if isUsingTool then return end
    task.spawn(function()
        isUsingTool = true
        pcall(function()
            local tool = LP.Backpack:FindFirstChild(toolName) or char:FindFirstChild(toolName)
            if tool and tool:IsA("Tool") then
                tool.Parent = char
                hum:EquipTool(tool)
                task.wait(0.1)
                tool:Activate()
                task.wait(0.2)
            end
        end)
        task.wait(0.3)
        isUsingTool = false
    end)
end

local function GetNearestEnemy()
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearest, minDist = nil, 100
    local searchFolders = {
工作区：查找是否存在满足“当前时间 > 冷却时间。已进食”条件的元素。
工作区：FindFirstChild("Events") 以及workspace.Events:FindFirstChild(
    }

如果 S.EatItem 和
ipairs(folder:GetDescendants())如果 folder 然后
            为了 _，v在……中通过ipairs(folder:GetDescendants())来获取。
ifv：是否为“模型”；v：FindFirstChildOfClass(“类人形态”)，然后
                    本地vHrp = v:FindFirstChild(“人类形根部部件”) 或 v.主要部分
                    如果 vHrp 然后
                        本地距离 = (hrp.Position - vHrp.Position).Magnitude
                        如果距离 < 最小距离然后
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

-- 后台主循环
本地 tickTimer =0
RunService.Heartbeat:Connect(函数(dt)
tickTimer = tickTimer + dt
如果 tickTimer <0.25 然后 返回 结束 
tickTimer =0
本地 now = tick()

本地 char = LP.Character
如果不是字符，则返回结束。
本地 hrp = char:FindFirstChild(“人类形根部部件”)
本地 hum = char:FindFirstChildOfClass(“类人形态”)
如果没有hrp，或者没有hum，又或者hum.Health的值小于等于0 然后 返回 结束

如果 S.EatItem 为真、isUsingTool 也为真，并且当前时间大于 cooldowns.Eat 的值，那么
冷却时间.吃 = 现在的时间 +2
pcall(
本地elixir = LP.Backpack:FindFirstChild(“诡异经验药水I”) 或 LP.Backp
