--[[
    ========================================================
心脚本 V9.7 公益开源完美版
    作者: 硝基
    特性: 极限防封 / 屏幕边界防丢 / 定向寻敌优化 / 绝对无报错
    声明: 本脚本完全免费，严禁用于商业倒卖。
    ========================================================
]]

-- ==================== 服务加载 ====================
本地玩家           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
本地RunService        = game:GetService("RunService")
local UserInputService = game:GetService(“UserInputService”)
本地碎片            = game:GetService("Debris")
本地VirtualUser       = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ==================== 状态与变量 ====================
本地状态 = {
Train = 否，Elixir = 否，Egg = 否，Rebirth = 否，
Boss = false，Aura = false，KB = false，Walk = false，
飞行状态 = 否，反挂机功能 = 开启，速度 = 16
}

local isToolEquipping = false
本地冷却时间 = {攻击：0，灵药：0，重生：0，首领战斗：0，光环效果：0，离线状态：0}
本地飞行速度、飞行力
本地 MuscleEvent = LocalPlayer:FindFirstChild("muscleEvent") 或 ReplicatedStorage:FindFirstChild("muscleEvent")

如果不是MuscleEvent，则
    task.spawn(函数()
MuscleEvent = LocalPlayer:WaitForChild(“muscleEvent”, 10) 或 ReplicatedStorage:WaitForChild(“muscleEvent”, 10)
    结束）
结束

-- ==================== 核心工具函数 ====================

-- 获取角色核心组件
局部函数 getCharacter()
本地 char = LocalPlayer.Character
如果该字符不存在，或者其父节点也不存在，则返回无, 无, 无。
本地 hum = char:FindFirstChildOfClass(“类人形态”)
本地 hrp = char:FindFirstChild(“人类形根部部件”)
如果 hum 为假，或者 hrp 为假，又或者 hum.Health 小于或等于0，则返回 无, 无, 无。
返回字符、hum值和hrp值
结束

-- 智能攻击 (防卡死、防动作阻塞)
局部函数 executeHit()
    pcall(函数())
本地 char, hum = getCharacter()
如果char为空或hum为空，则返回结束。
        
本地 punch = char:FindFirstChild("Punch") 或 LocalPlayer.Backpack:FindFirstChild("Punch")
如果进行拳击攻击的话
如果 punch的父节点不等于char，则
                如果 hum：存在名为“Tool”的类中的子对象，则
hum：UnequipTools()
                    task.wait(0.1) -- 防止动作导致缓冲区堵塞
                结束
punch.Parent = char
            结束
            
如果 char:FindFirstChildWhichIsA("Tool") 不等于 punch，则
                hum：装备工具（冲头）
                task.wait(0.1)
            结束
            
punch：Activate()
结束
        
如果存在MuscleEvent，则
MuscleEvent：向服务器发送“rep”指令
结束
    结束）
结束

-- 智能使用道具 (防死锁)
局部函数 useTool(toolName)
如果正在安装工具，则返回，结束。
isToolEquipping =真实
    
    task.spawn(function()
        pcall(function())
            本地 char, hum = 获取字符()
如果字符不存在或人类用户不存在，则返回结束。
            
本地 tool = LocalPlayer.Backpack:FindFirstChild(toolName) 或 char:FindFirstChild(toolName)
如果存在工具，则
                如果 hum：存在名为“Tool”的类中的子对象，则
hum：UnequipTools()
                    task.wait(0.1)
                结束
tool.Parent = char
                hum:装备工具（工具）
task.wait(0.2)
工具：Activate()
task.wait(0.4)
            结束
        结束）
isToolEquipping =虚假
    结束）
结束

-- 飞行引擎启动
局部函数 startFly()
本地_, 嗯，hrp = 获取角色()
如果 hum 和 hrp 均为假，则返回，结束。
    
如果FlyVelocity存在，则执行FlyVelocity:Destroy()操作。
如果FlyForce为真，则执行FlyForce:Destroy()操作。
    
hum.PlatformStand = 真实
    
FlyVelocity = Instance.new(“身体速度”, hrp)
FlyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
FlyVelocity.Velocity = Vector3.new(0, 0, 0)
    
FlyForce = Instance.new(“BodyForce”, hrp)
FlyForce.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass() * 1.2, 0)
结束

-- 飞行引擎关闭 (带落地缓冲)
局部函数 stopFly()
如果FlyVelocity存在，则将其销毁；同时将FlyVelocity设置为无。
如果FlyForce存在，则执行FlyForce:Destroy()；随后将FlyForce设置为无。
    
本地 _, hum, hrp = 获取角色()
如果hum和hrp都为真，则
hum.PlatformStand =虚假
本地 buffer = Instance.new(“身体速度”, hrp)
buffer.Velocity = Vector3.new(0, -30, 0) -- 提高下落速度以避免悬停
buffer.MaxForce = Vector3.new(0, 1e4, 0)
碎片：AddItem缓冲区，0.15)
    结束
结束

-- 角色死亡/重生清理
LocalPlayer.CharacterRemoving:Connect函数()
如果FlyVelocity存在，则将其销毁；同时将FlyVelocity设置为无。
如果FlyForce存在，则执行FlyForce:Destroy()；随后将FlyForce设置为无。
结束）

-- ==================== 主循环逻辑 ====================
RunService.Heartbeat:Connect函数()
本地 now = os.clock()
本地 char, hum, hrp = 获取字符()
如果（char、hum和hrp）均不存在，则返回结束。

    -- 极限防挂机 (物理动作防踢，无视反作弊)
如果 State.AntiAFK 为真，且 (现在时间 – Cooldowns.afk) 大于等于20，则
Cooldowns.afk = 当前时间
如果hum.MoveDirection的模值等于0，则
-- 模拟物理跳跃，比VirtualUser更安全，不会被封
hum.Jump = 真实
结束
    结束

    -- 自动训练
如果 State.Train 为真，且 (现在时间 – Cooldowns.hit) 的值大于或等于0.35，则……
冷却时间结束时间 = 当前时间
        执行命中处理()
    结束

    -- 自动药水与蛋白蛋
如果（State.Elixir或State.Egg为真），且当前没有正在装备工具，同时（现在的时间减去Cooldowns.elixir的值大于或等于2），那么
Cooldowns.elixir = 当前时间
本地背包 = LocalPlayer:FindFirstChild(“背包”)
如果带有背包的话
如果State.Elixir为真，则
本地灵药 = 背包：FindFirstChild(“恐怖经验值灵药III”)
或者使用背包：查找名为“Spooky XP Elixir II”的物品。
或者使用背包：FindFirstChild(“Tropical Shake”)
如果elixir存在，则使用Tool(elixir.Name)；否则不执行任何操作。
            结束
如果State.Egg为真，且背包中存在“Protein Egg”这个物品，则执行相应操作。
使用工具“蛋白质蛋”
            结束
结束
    结束

    -- 自动重生
如果State.Rebirth为真，且（现在时间 – Cooldowns.rebirth）大于或等于8，则
Cooldowns.rebirth = 当前时间
本地 rEvents = ReplicatedStorage:FindFirstChild(“r事件”)
本地 remote = rEvents 和 rEvents:FindFirstChild(“重生远程”)
如果是在远程环境中的话，则
pcall(函数() remote:InvokeServer(“重生请求”) 结束)
        结束
    结束

-- 自动攻击Boss（高性能定向寻敌）
如果 State.Boss 为真，且 (现在时间 – Cooldowns.boss) 大于或等于0.5，则
Cooldowns.boss = 当前时间
本地目标，最小距离 = 无，math.huge
        
        -- 优化：不全图扫描，只扫描根目录，如果没有再扫一层
用于 _，obj在ipairs(workspace:GetChildren())中使用
如果 obj 是“模型”类型，并且其名称的 lowercase 版本中包含“boss”这个词，那么
本地 bHrp = obj:FindFirstChild(“人类形根部部件”)
本地 bHum = obj:FindFirstChildOfClass(“类人形态”)
如果bHrp、bHum以及bHum.Health的值都大于0，则
局部距离 = (hrp.Position - bHrp.Position).Magnitude
如果dist小于minDist，则令minDist等于dist；同时将target设置为bHrp。
                结束
            否则，如果对象是“文件夹”类型，则
-- 找文件夹里的 Boss
用于 _，subObj在ipairs(obj:GetChildren())中执行操作
如果subObj属于“Model”类型，并且其名称的小写形式中包含“boss”这个词，那么
本地bHrp = subObj:FindFirstChild(“人类形根部部件”)
本地bHum = subObj:FindFirstChildOfClass(“类人形态”)
如果bHrp、bHum以及bHum.Health的值都大于0，则
局部距离 = (hrp.Position - bHrp.Position).Magnitude
如果dist小于minDist，则令minDist等于dist；同时将target设置为bHrp。
                        结束
                    结束
                结束
            结束
结束
        
如果存在目标，则
如果最小距离大于10，则
hum：移动到目标位置
            否则 
hum：移动到hrp的位置
                执行命中处理()
            结束
结束
    结束

    -- 光环攻击
如果State.Aura为真，且（现在时间 – Cooldowns.aura）大于或等于0.5，则……
冷却时间。光环效果 = 当前时间
用于 _，玩家在ipairs(Players:GetPlayers())中操作
            如果玩家不是本地玩家，且该玩家拥有角色的话
本地pHrp = player.Character:FindFirstChild(“人类形根部部件”)
本地pHum = player.Character:FindFirstChildOfClass(“类人形态”)
如果pHrp、pHum以及pHum.Health的值都大于0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……0，并且(hrp.Position – pHrp.Position)的绝对值小于30，那么……
                    执行命中处理()
                    打破
                结束
            结束
结束
    结束

    -- 反击退
如果 State.KB 为真，则
如果 hrp：FindFirstChild(“XinAntiKB”) 的返回值为假，则
            本地bv = Instance.new(“身体速度”, hrp)
bv.Name = “XinAntiKB”
，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)math.huge)math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)0，math.huge)
bv.Velocity = Vector3.new(0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)0, 0, 0)
结束
    否则
本地bv = hrp:FindFirstChild(“XinAntiKB”)
ifbv那么bv:Destroy()结束
    结束

    -- 水上行走
本地地形 = 工作区：查找属于“地形”类别的第一个元素
如果 State.Walk 为真，则
如果存在地形，则将地形的水波高度设置为0。
如果 hrp.CustomPhysicalProperties 不存在，或者其密度不等于0.01，则
hrp.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.5, 0.5, 0, 0)
结束
    否则
如果地形参数以及地形的水波高度不等于0.5，那么就将地形的水波高度设置为0.5。
如果hrp.CustomPhysicalProperties存在，则将其设置为无。
    结束

    -- 速度同步
如果hum.WalkSpeed不等于State.Speed，则
hum.WalkSpeed = State.Speed
    结束

    -- 飞行控制
如果State.Fly为真，则
如果FlyVelocity不存在，或者其父节点不存在，又或者FlyVelocity的父节点并非hrp，则……
            开始飞行()
结束
hum.PlatformStand =真实
        
如果FlyVelocity为真，则
            当地方向 = Vector3.new(0, 0, 0)
            洛
