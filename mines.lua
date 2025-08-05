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
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local Mouse = plr:GetMouse()
local root = plr.Character:FindFirstChild("HumanoidRootPart")
local Mine = ReplicatedStorage["shared/network/MiningNetwork@GlobalMiningEvents"].Mine
local Drill = ReplicatedStorage["shared/network/MiningNetwork@GlobalMiningFunctions"].Drill
local Dynamite = ReplicatedStorage["shared/network/DynamiteNetwork@GlobalDynamiteFunctions"].UseDynamite
local BuyItem = ReplicatedStorage.Ml.BuyItem
local items = workspace:FindFirstChild("Items")

-- Variables --
local AutoMine = false
local ColOres = false
local AutoDrill = false
local MiningStrength = 1
local MiningThread = nil
local OresThread = nil
local DrillingThread = nil
local DynamiteThread = nil
local PromptButtonHoldBegan = nil
local tradertomPos = nil
local CollectSpeed = 0.5
local CollectMode = "Legit"
local oredistance = nil
local desiredWalkSpeed = 16
local function findtradertom()
    if not tradertomPos then
        root.CFrame = CFrame.new(Vector3.new(998, 245, -71))
        local attempt = 0
        repeat
            for _, npc in pairs(workspace:GetChildren()) do
                if npc:IsA("Model") and npc:GetAttribute("Name") == "Trader Tom" and npc:FindFirstChild("HumanoidRootPart") then
                    tradertomPos = npc.HumanoidRootPart.CFrame
                    break
                end
            end
            task.wait(0.1)
            attempt = attempt + 1
        until tradertomPos or attempt > 20

        if not tradertomPos then
            warn("Could not find Trader Tom after", 20, "attempts")
        end
    end
end

pcall(function()
    findtradertom()
end)

RunService.Heartbeat:Connect(function()
    pcall(function()
        if plr.Character and plr.Character.Humanoid then
            plr.Character.Humanoid.WalkSpeed = desiredWalkSpeed
        end
    end)
end)

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
        Drill:FireServer(math.random(0,9e9), {direction = minePos, heat = 0, overheated = false})
        task.wait(0.05)
    end
end

local function UseDynamite()
    while AutoDynamite do
        local hitPosition = Mouse.Hit.Position
        Dynamite:FireServer(math.random(0,9e9), hitPosition)
        task.wait(0.5)
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
                    if root and item:IsA("MeshPart") then
                        oredistance = (rootPart.Position - item.Position).Magnitude
                    else
                        oredistance = (rootPart.Position - item.Handle.Position).Magnitude
                    end
                    if oredistance then
                        if CollectMode == "Legit" then
                            if oredistance <= 5 then
                                collectItem:FireServer(item.Name)
                            end
                        else
                            collectItem:FireServer(item.Name)
                        end
                    end
                    oredistance = nil
                end)
                if not success then
                    warn("Error collecting item:", err)
                end
                task.wait(CollectSpeed)
            end
        end
        task.wait(CollectSpeed)
    end
end

local function SellInventory()
    if not tradertomPos then
        OrionLib:MakeNotification({
            Name = "Auto Sell Failed",
            Content = "Could not find trader tom's position, retrying search.",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
        findtradertom()
        if not tradertomPos then
            return
        end
    end

    local success, err = pcall(function()
        local lastPos = root.CFrame
        root.CFrame = tradertomPos
        task.wait(0.1)
        ReplicatedStorage.Ml.SellInventory:FireServer()
        task.wait(0.2)
        root.CFrame = lastPos
    end)

    if not success then
        OrionLib:MakeNotification({
            Name = "Auto Sell Failed",
            Content = err,
            Image = "rbxassetid://4483345998",
            Time = 3
        })
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

local AutoDynamiteToggle = MineTab:AddToggle({Name = "Auto Dynamite (REQUIRES ANY DYNAMITE)",  Default = false,  Callback = function(bool)
    AutoDynamite = bool
    if AutoDynamite then
        DynamiteThread = task.spawn(UseDynamite)
        OrionLib:MakeNotification({
            Name = "Auto Dynamite",
            Content = "Auto dynamite is now active.",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    else
        if DynamiteThread then
            task.cancel(DynamiteThread)
            DynamiteThread = nil
            OrionLib:MakeNotification({
                Name = "Auto Dynamite",
                Content = "Auto dynamite has been disabled.",
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

local CollectOresToggle = MineTab:AddToggle({Name = "Collect Ores",  Default = false,  Callback = function(bool)
    ColOres = bool
    if ColOres then
        OresThread = task.spawn(CollectOres)
        OrionLib:MakeNotification({
            Name = "Collecting Ores",
            Content = "Auto Ore Collecting is now active. (Might cause lag bcuz game bad lol)",
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

MineTab:AddDropdown({
    Name = "Collect Speed", 
    Default = "Slow", 
    Options = {"Instant (LAG)", "Fast", "Slow"}, 
    Callback = function(val)
        if val == "Instant (LAG)" then
            CollectSpeed = 0
        elseif val == "Fast" then
            CollectSpeed = 0.125
        elseif val == "Slow" then
            CollectSpeed = 0.5
        end
    end
})

MineTab:AddDropdown({
    Name = "Collect Mode", 
    Default = "Legit", 
    Options = {"Always", "Legit"}, 
    Callback = function(val)
        CollectMode = val
    end
})

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

-- Shop --
ShopTab:AddParagraph("WARNING","If you try to buy something you already own here, you will WASTE MONEY.")

ShopTab:AddDropdown({Name = "Pickaxes", Options = {
"Rusty Pickaxe ($5)",
"Wooden Pickaxe ($250)", 
"Stone Pickaxe ($1,350)", 
"Iron Pickaxe ($5,000)", 
"Emerald Pickaxe ($20,000)", 
"Sapphire Pickaxe ($40,000)", 
"Ruby Pickaxe ($100,000)", 
"Amethyst Pickaxe ($100,000)", 
"Quartz Pickaxe ($500,000)", 
"Citrine Pickaxe ($1,000,000)", 
"Obsidian Pickaxe ($2,500,000)", 
"Celestite Pickaxe ($5,000,000)", 
"Frostbite Pickaxe ($6,000,000)", 
"Sunfrost Pickaxe ($7,500,000)", 
"Rosefrost Pickaxe ($9,000,000)", 
"Shadowfrost Pickaxe ($12,500,000)"
}, Callback = function(Value)
	BuyItem:FireServer(string.gsub(Value, "%s%(%$[%d,]+%)", ""))
end})

ShopTab:AddDropdown({Name = "Radars", Options = {
"Copper Radar ($50)", 
"Iron Radar ($500)", 
"Gold Radar ($1,500)", 
"Diamond Radar ($4,000)", 
"Emerald Radar ($20,000)", 
"Sapphire Radar ($40,000)", 
"Ruby Radar ($70,000)", 
"Amethyst Radar ($100,000)", 
"Quartz Radar ($1,500,000)", 
"Citrine Radar ($3,500,000)", 
"Obsidian Radar ($5,000,000)", 
"Celestite Radar ($7,000,000)", 
"Frostbite Radar ($7,000,000)", 
"Sunfrost Radar ($8,500,000)", 
"Rosefrost Radar ($10,000,000)", 
"Shadowfrost Radar ($13,000,000)"
}, Callback = function(Value)
	BuyItem:FireServer(string.gsub(Value, "%s%(%$[%d,]+%)", ""))
end})

ShopTab:AddDropdown({Name = "Drills", Options = {
"Weak Drill ($25,000)", 
"Light Drill ($50,000)", 
"Heavy Drill ($250,000)"
}, Callback = function(Value)
	BuyItem:FireServer(string.gsub(Value, "%s%(%$[%d,]+%)", ""))
end})

ShopTab:AddDropdown({Name = "Dynamites", Options = {
"Light Dynamite ($600,000)",
"Heavy Dynamite ($1,000,000)"
}, Callback = function(Value)
	BuyItem:FireServer(string.gsub(Value, "%s%(%$[%d,]+%)", ""))
end})

-- Misc --
MiscTab:AddLabel("Made with <3 by tokkendev")

MiscTab:AddToggle({Name = "Instant Proximity Prompt",  Default = false,  Callback = function(bool)
    if bool then
        if fireproximityprompt then
            execCmd("uninstantproximityprompts")
            wait(0.1)
            PromptButtonHoldBegan = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
                fireproximityprompt(prompt)
            end)
        else
            OrionLib:MakeNotification({
                Name = "Incompatible Exploit",
                Content = "Your exploit is incompatible with fireproximityprompt.",
                Image = "rbxassetid://4483345998",
                Time = 6
            })
        end
    else
        if PromptButtonHoldBegan then
            PromptButtonHoldBegan:Disconnect()
            PromptButtonHoldBegan = nil
        end
    end
end})

MiscTab:AddSlider({Name = "Walkspeed", Min = 16, Max = 200, Default = 16, Color = Color3.fromRGB(255,255,255), Increment = 1, ValueName = "ws", Callback = function(Value)
    pcall(function()
        desiredWalkSpeed = Value
    end)
end})

MiscTab:AddButton({Name = "Remove Fog", Callback = function()
	Lighting.FogEnd = 100000
	for i,v in pairs(Lighting:GetDescendants()) do
		if v:IsA("Atmosphere") then
			v:Destroy()
		end
	end
end})

OrionLib:Init()
