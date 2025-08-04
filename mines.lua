-- loadstring(game:HttpGet("https://raw.githubusercontent.com/TokkenDev/clock.lua-v2/refs/heads/main/mines.lua"))() --

-- Library --
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
local Window = OrionLib:MakeWindow({Name = "clock.lua", HidePremium = false, SaveConfig = true, ConfigFolder = "clock.lua.mines"})
local MineTab = Window:MakeTab({
    Name = "Mining",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
local ShopTab = Window:MakeTab({
    Name = "Shop",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Init --
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local root = plr.Character:FindFirstChild("HumanoidRootPart")
local Mine = ReplicatedStorage["shared/network/MiningNetwork@GlobalMiningEvents"].Mine
local Drill = ReplicatedStorage["shared/network/MiningNetwork@GlobalMiningFunctions"].Drill
local items = workspace:FindFirstChild("Items")

Drill:FireServer(
    42,
    {
        direction = Vector3.new(-2, -5, -9),
        heat = 97.03280401229858,
        overheated = false
    }
)


-- Variables --
local AutoMine = false
local ColOres = false
local AutoDrill = false
local MiningStrength = 1
local MiningThread = nil
local OresThread = nil
local DrillingThread = nil

-- Functions --
local function MineOres()
    while AutoMine do
        local camera = workspace.CurrentCamera.CFrame.LookVector
        local minePos = Vector3.new(
            math.round(math.clamp(camera.X * 10, -10, 10)),
            math.round(math.clamp(camera.Y * 10, -10, 10)),
            math.round(math.clamp(camera.Z * 10, -10, 10))
        )
        Mine:FireServer(minePos, MiningStrength)
        task.wait(0.1)
    end
end

local function MineOresDrill()
    while AutoDrill do
        local camera = workspace.CurrentCamera.CFrame.LookVector
        local minePos = Vector3.new(
            math.round(math.clamp(camera.X * 10, -10, 10)),
            math.round(math.clamp(camera.Y * 10, -10, 10)),
            math.round(math.clamp(camera.Z * 10, -10, 10))
        )
        Drill:FireServer(math.random(0,100), {minePos, 0, false})
        task.wait(0.05)
    end
end

local function CollectOres()
    local miningNetwork = ReplicatedStorage:FindFirstChild("shared/network/MiningNetwork@GlobalMiningEvents")
    local collectItem = miningNetwork and miningNetwork:FindFirstChild("CollectItem")
    while ColOres do
        local items = items:GetChildren()
        if #items > 0 then
            for _, item in ipairs(items) do
                if not ColOres then
                    break
                end
                local success, err = pcall(function()
                    collectItem:FireServer(item.Name)
                end)
                if not success then
                    warn("Error collecting item:", err)
                end
                task.wait(0.5)
            end
        end
        task.wait(0.5)
    end
end

local function SellInventory()
    local lastPos = root.CFrame
    for _, npc in pairs(workspace:GetChildren()) do
        if npc:IsA("Model") and npc:GetAttribute("Name") == "Trader Tom" and npc:FindFirstChild("HumanoidRootPart") then
            root.CFrame = npc.HumanoidRootPart.CFrame
            task.wait(0.5)
            game.ReplicatedStorage.Ml.SellInventory:FireServer()
            task.wait(0.5)
            root.CFrame = lastPos
            break
        end
    end
end

-- Tab Elements --

-- Mining --
local AutoMineToggle = MineTab:AddToggle({Name = "Auto Mine",  Default = false,  Callback = function(bool)
    AutoMine = bool
    if AutoMine then
        if MiningStrength then
            MiningThread = task.spawn(MineOres)
            OrionLib:MakeNotification({
                Name = "Auto Mining",
                Content = "Auto mining is now active.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Mining Strength Missing!",
                Content = "Please set the mining strength first.",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
            AutoMine = false
            AutoMineToggle:Set(false)
        end
    else
        if MiningThread then
            task.cancel(MiningThread)
            MiningThread = nil
            OrionLib:MakeNotification({
                Name = "Auto Mining",
                Content = "Auto mining has been disabled.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
end})

MineTab:AddDropdown({
    Name = "Mining Strength", 
    Default = "Max", 
    Options = {"Max", "Good", "Decent", "Bad"}, 
    Callback = function(val)
        if val == "Max" then
            MiningStrength = 1
        elseif val == "Good" then
            MiningStrength = 0.8
        elseif val == "Decent" then
            MiningStrength = 0.7
        elseif val == "Bad" then
            MiningStrength = 0.6
        end
        if AutoMine then
            if MiningThread then
                task.cancel(MiningThread)
            end
            MiningThread = task.spawn(MineOres)
        end
    end
})

local AutoDrillToggle = MineTab:AddToggle({Name = "Auto Drill (REQUIRES ANY DRILL)",  Default = false,  Callback = function(bool)
    AutoDrill = bool
    if AutoDrill then
        DrillingThread = task.spawn(MineOresDrill)
        OrionLib:MakeNotification({
            Name = "Auto Drill",
            Content = "Auto drill is now active.",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    else
        if DrillingThread then
            task.cancel(DrillingThread)
            DrillingThread = nil
            OrionLib:MakeNotification({
                Name = "Auto Drill",
                Content = "Auto drill has been disabled.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
end})

local CollectOresToggle = MineTab:AddToggle({Name = "Collect Ores",  Default = false,  Callback = function(bool)
    ColOres = bool
    if ColOres then
        OresThread = task.spawn(CollectOres)
        OrionLib:MakeNotification({
            Name = "Collecting Ores",
            Content = "Auto Ore Collecting is now active. (Might Cause Slight Lag)",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    else
        if OresThread then
            task.cancel(OresThread)
            OresThread = nil
            OrionLib:MakeNotification({
                Name = "Collecting Ores",
                Content = "Auto Ore Collecting is now disabled.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
end})

MineTab:AddButton({Name = "Sell Everything", Callback = function()
    SellInventory()
end})

-- Teleport --
TeleportTab:AddButton({Name = "Forest", Callback = function()
    local targetPos = Vector3.new(998, 245, -71)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(targetPos)}):Play()
end})

TeleportTab:AddButton({Name = "Mine Passage", Callback = function()
    local targetPos = Vector3.new(1020, 181, -1451)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(targetPos)}):Play()
end})

TeleportTab:AddButton({Name = "Crystal Cave", Callback = function()
    local targetPos = Vector3.new(1011, 177, -2910)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(targetPos)}):Play()
end})

TeleportTab:AddButton({Name = "Merchant Mike (Ores)", Callback = function()
    local targetPos = Vector3.new(1043, 245, -198)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(targetPos)}):Play()
end})

TeleportTab:AddButton({Name = "Driller Dan (Drills)", Callback = function()
    local targetPos = Vector3.new(906, 245, -454)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(targetPos)}):Play()
end})

TeleportTab:AddButton({Name = "Sally (Pickaxes)", Callback = function()
    local targetPos = Vector3.new(1054, 245, -283)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(targetPos)}):Play()
end})

TeleportTab:AddButton({Name = "Bob (Radars)", Callback = function()
    local targetPos = Vector3.new(1085, 245, -468)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(targetPos)}):Play()
end})

TeleportTab:AddButton({Name = "Miner Mike (Offline)", Callback = function()
    local targetPos = Vector3.new(954, 245, -222)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(targetPos)}):Play()
end})

OrionLib:Init()
