-- Library

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Singularity5490/rbimgui-2/main/rbimgui-2.lua"))()
local Window = Library.new({
    text = "clock.lua-v2 | Blade Ball",
    size = UDim2.new((workspace.CurrentCamera.ViewportSize.X/3), (workspace.CurrentCamera.ViewportSize.Y/3)),
    color = Color3.fromRGB(75, 0, 150),
    boardcolor = Color3.fromRGB(18, 18, 18),
    rounding = 1,
    shadow = 1,
})
Window.open()

-- Setup

local workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LPlayer = Players.LocalPlayer

-- Game Specific Setup

if not detectdeath then
    detectdeath = coroutine.wrap(function()
        while task.wait() do
            if Humanoid then
                if Humanoid.Health <= 0 then
                    while Humanoid.Health < 1 do task.wait()
                        getgenv().autoclashrunning = false
                        getgenv().clashing = false
                    end
                end
            end
        end
    end)
end

if not getgenv().Visualizer then
    getgenv().Visualizer = Instance.new("Part")
    getgenv().Visualizer.Parent = workspace
    getgenv().Visualizer.Shape = Enum.PartType.Ball
    getgenv().Visualizer.Reflectance = -1
    getgenv().Visualizer.Color = Color3.new(0, 1, 0)
    getgenv().Visualizer.Anchored = true
    getgenv().Visualizer.CollisionGroupId = 0
    getgenv().Visualizer.RightSurface = Enum.SurfaceType.Smooth
    getgenv().Visualizer.Locked = false
    getgenv().Visualizer.Material = Enum.Material.SmoothPlastic
    getgenv().Visualizer.Archivable = true
    getgenv().Visualizer.Size = Vector3.new(0,0,0)
    getgenv().Visualizer.BackSurface = Enum.SurfaceType.Smooth
    getgenv().Visualizer.BottomSurface = Enum.SurfaceType.Smooth
    getgenv().Visualizer.CanCollide = false
    getgenv().Visualizer.LeftSurface = Enum.SurfaceType.Smooth
    getgenv().Visualizer.Transparency = 0.75
    getgenv().Visualizer.CFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    getgenv().Visualizer.FrontSurface = Enum.SurfaceType.Smooth
    getgenv().Visualizer.TopSurface = Enum.SurfaceType.Smooth
    getgenv().Visualizer.Name = "clockluav2visualizer"
    getgenv().Visualizer = workspace:FindFirstChild("clockluav2visualizer")
end

if not getgenv().TimeCheck then getgenv().TimeCheck = 0 end

-- Functions

getgenv().settings = {
    gamename = "BladeBall",
    autoparry = false,
    autoclash = false,
    pingbased = false,
    debugtoggle = false,
    VisualizerToggle = false,
    timetoclash = 0.2,
    aliveordead = workspace.Alive,
    ball = workspace.Balls,
}

function loadSettings()
	local HttpService = game:GetService("HttpService")
	if (readfile and isfile and isfile("clock.lua-v2/"..getgenv().settings.gamename..".lua")) then
		getgenv().settings = HttpService:JSONDecode(readfile("clock.lua-v2/"..getgenv().settings.gamename..".lua"));
		print("Settings loaded.")
    else
        print("Unable to load settings.")
    end
end

function saveSettings()
    local json
    local HttpService = game:GetService("HttpService")
    if writefile and makefolder then
        json = HttpService:JSONEncode(getgenv().settings)
        makefolder("clock.lua-v2")
        writefile("clock.lua-v2/"..getgenv().settings.gamename..".lua", json)
    else
        print("Sorry, your exploit does not support writefile/makefolder.")
    end
end

loadSettings()

function presskey(keybind)
    game:GetService("VirtualInputManager"):SendKeyEvent(true,keybind,false,game)
    game:GetService("VirtualInputManager"):SendKeyEvent(false,keybind,false,game)
end

function getball()
    for i,v in pairs(getgenv().settings.ball:GetChildren()) do
        if v:GetAttribute("realBall") == true then
            realball = v
        else
            fakeball = v
        end
    end
    return fakeball, realball
end

function getballspeed()
    fakeball, realball = getball()
    if realball then
        if realball.AssemblyLinearVelocity.magnitude > 0 then
            local speed = 25 * (realball.AssemblyLinearVelocity.magnitude / 100)
            if speed < 15 then
                finalresult = 15
            else
                finalresult = speed
            end
        else
            finalresult = 5
        end
    else
        finalresult = 0
    end
    if getgenv().settings.pingbased == true then
        return finalresult + (LPlayer:GetNetworkPing() * 100)
    else
        return finalresult
    end
end

function getdistance()
    fakeball, realball = getball()
    if LPlayer.Character:FindFirstChild("HumanoidRootPart") and realball then
        finalresult2 = (LPlayer.Character:FindFirstChild("HumanoidRootPart").Position - realball.Position).magnitude
    else
        finalresult2 = 1000
    end
    if not finalresult2 then return 1000 else return finalresult2 end
end

function gettargetplayer()
    for i,v in pairs(getgenv().settings.aliveordead:GetChildren()) do
        if v:FindFirstChild("Highlight") then
            return v
        end
    end
    return "nil"
end

function isballheadedtoplayer()
    fakeball, realball = getball()
    if realball then
        if (realball.BrickColor == BrickColor.new("Persimmon") or tostring(gettargetplayer()) == tostring(LPlayer)) then
            return true
        else
            return false
        end
    else
        return false
    end
end

function opencrate(CrateName)
    game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RemoteFunction"):InvokeServer("PromptPurchaseCrate",workspace.Spawn.Crates[CrateName])
    game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RemoteEvent"):FireServer("OpeningCase",true)
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.1.0"):WaitForChild("net"):WaitForChild("RE/SpinFinished"):FireServer()
    game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RemoteEvent"):FireServer("OpeningCase",false)
end

function spinwheel()
    game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RemoteFunction"):InvokeServer("SpinWheel")
end

function claimplaytime()
    for i = 1,6 do
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.1.0"):WaitForChild("net"):WaitForChild("RF/ClaimPlaytimeReward"):InvokeServer(i)
    end
end

hitcount = 0
if not AutoClashConnection then
    AutoClashConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if getgenv().settings.autoclash == true then
            if getgenv().autoclashrunning ~= true then
                getgenv().autoclashrunning = true
                task.wait()
                local target = gettargetplayer()
                if tostring(target) ~= "nil" then
                    while hitcount <= 2 and (tostring(gettargetplayer()) == tostring(target) or isballheadedtoplayer()) do task.wait()
                        if tostring(gettargetplayer()) == tostring(target) then
                            repeat task.wait() until tostring(gettargetplayer()) ~= tostring(target)
                            if not isballheadedtoplayer() then 
                                break
                            else
                                hitcount = hitcount + 1
                            end
                        elseif isballheadedtoplayer() then
                            repeat task.wait() until not isballheadedtoplayer()
                            if tostring(gettargetplayer()) ~= tostring(target) then 
                                break
                            else
                                hitcount = hitcount + 1
                            end
                        else
                            break
                        end
                    end
                    if getgenv().LastTimeCheck < getgenv().settings.timetoclash and (target:FindFirstChild("HumanoidRootPart").Position - LPlayer.Character:FindFirstChild("HumanoidRootPart").Position).magnitude < 25 and hitcount >= 2 then
                        hitcount = 0
                        getgenv().clashing = true
                        getgenv().ClashStatusLabel.setText("Auto Clash Status: True")
                        getgenv().ClashStatusLabel.setColor(Color3.new(0, 1, 0))
                        getgenv().timeextenderclash = 0
                        while (getgenv().TimeCheck < (getgenv().settings.timetoclash)) and ((target:FindFirstChild("HumanoidRootPart").Position - LPlayer.Character:FindFirstChild("HumanoidRootPart").Position).magnitude < 30 + getgenv().timeextenderclash) and (tostring(gettargetplayer()) == tostring(target) or isballheadedtoplayer()) do
                            presskey(Enum.KeyCode.F)
                            coroutine.wrap(function()
                                getgenv().timeextenderclash = getgenv().timeextenderclash + 0.1
                                if getgenv().timeextenderclash > 20 then getgenv().timeextenderclash = 20 end
                            end)
                            task.wait()
                        end
                        getgenv().ClashStatusLabel.setText("Auto Clash Status: False")
                        getgenv().ClashStatusLabel.setColor(Color3.new(1, 0, 0))
                        getgenv().clashing = false
                    end
                end
                getgenv().autoclashrunning = false
            end
        end
    end)
end

if not AutoBlockConnection then
    AutoBlockConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if getgenv().settings.autoparry == true then
            if isballheadedtoplayer() and getdistance() <= getballspeed() then
                presskey(Enum.KeyCode.F)
            end
        end
    end)
end

if not VisualizerConnection then
    VisualizerConnection = game:GetService("RunService").Heartbeat:Connect(function()
        getgenv().Visualizer = workspace:FindFirstChild("clockluav2visualizer")
        if getgenv().settings.VisualizerToggle == true then
            local sizespeed = getballspeed()
            local distance = getdistance()
            if LPlayer.Character:FindFirstChild("HumanoidRootPart") then
                getgenv().Visualizer.CFrame = LPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame
            end
            if getgenv().clashing == true then
                local sizeclash = 30 + getgenv().timeextenderclash
                getgenv().Visualizer.Size = Vector3.new(sizeclash, sizeclash, sizeclash)
                getgenv().Visualizer.Color = Color3.new(0, 0, 1)
            else
                getgenv().Visualizer.Size = Vector3.new(sizespeed,sizespeed,sizespeed)
                if distance <= sizespeed and isballheadedtoplayer() then
                    getgenv().Visualizer.Color = Color3.new(1, 0, 0)
                else
                    getgenv().Visualizer.Color = Color3.new(1, 1, 0)
                end
            end
        else
            getgenv().Visualizer.Size = Vector3.new(0,0,0)
            getgenv().Visualizer.CFrame = CFrame.new(9e9,9e9,9e9)
        end
    end)
end

if not TimeCheckConnection then
    TimeCheckConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local target = gettargetplayer()
        getgenv().TimeCheck = getgenv().TimeCheck + task.wait()
        if target ~= gettargetplayer() then
            getgenv().LastTimeCheck = getgenv().TimeCheck
            getgenv().TimeCheck = 0
        end
    end)
end

-- Menu

local MainTab = Window.new({text = "Main ",})
local MiscTab = Window.new({text = "Misc ",})
local DebugTab = Window.new({text = "Debug ",})

-- MainTab

local ToggleAutoBlock = MainTab.new("switch", {text = "Toggle Auto Parry";})
ToggleAutoBlock.set(getgenv().settings.autoparry or false)
ToggleAutoBlock.event:Connect(function(Value)
    getgenv().settings.autoparry = Value
    saveSettings()
end)

local ToggleAutoSpam = MainTab.new("switch", {text = "Toggle Auto Clash";})
ToggleAutoSpam.set(getgenv().settings.autoclash or false)
ToggleAutoSpam.event:Connect(function(Value)
    getgenv().settings.autoclash = Value
    saveSettings()
end)

local TogglePingBased = MainTab.new("switch", {text = "Ping Based";})
TogglePingBased.set(getgenv().settings.pingbased or false)
TogglePingBased.event:Connect(function(Value)
    getgenv().settings.pingbased = Value
    saveSettings()
end)

local ToggleTraining = MainTab.new("switch", {text = "Toggle Training Ball";})
ToggleTraining.set(getgenv().settings.trainingball or false)
ToggleTraining.event:Connect(function(Value)
    if Value == true then
        getgenv().settings.trainingball = Value
        getgenv().settings.aliveordead = workspace.Dead
        getgenv().settings.ball = workspace.TrainingBalls
    else
        getgenv().settings.trainingball = Value
        getgenv().settings.aliveordead = workspace.Alive
        getgenv().settings.ball = workspace.Balls
    end
    saveSettings()
end)

getgenv().ClashStatusLabel = MainTab.new("label", {text = "Auto Clash Status: False", color = Color3.new(1, 0, 0),})

-- Misc Tab

local ToggleVisualizer = MiscTab.new("switch", {text = "Toggle Visualizer";})
ToggleVisualizer.set(getgenv().settings.VisualizerToggle or false)
ToggleVisualizer.event:Connect(function(Value)
    getgenv().settings.VisualizerToggle = Value
    saveSettings()
end)

-- DebugTab

local ToggleDebug = DebugTab.new("switch", {text = "Toggle Debug";})
ToggleDebug.set(getgenv().settings.debugtoggle or false)
ToggleDebug.event:Connect(function(Value)
    getgenv().settings.debugtoggle = Value
    saveSettings()
    if getgenv().settings.debugtoggle == true then
        while getgenv().settings.debugtoggle == true do task.wait()
            getgenv().debughighlight.setText("Highlighted Player: "..tostring(gettargetplayer()))
            getgenv().debugdistance.setText("Ball Distance: "..getdistance())
            getgenv().debugballspeed.setText("Ball Speed: "..getballspeed())
            getgenv().debugautoclashrunning.setText("AutoClashRunning: "..tostring(getgenv().autoclashrunning))
            getgenv().debugtimecheck.setText("Time Before Last Parry: "..tostring(getgenv().LastTimeCheck))
        end
    else
        task.wait(1)
        getgenv().debughighlight.setText("Highlighted Player: ")
        getgenv().debugdistance.setText("Ball Distance: ")
        getgenv().debugballspeed.setText("Ball Speed: ")
        getgenv().debugautoclashrunning.setText("AutoClashRunning: ")
        getgenv().debugtimecheck.setText("Time Before Last Parry: ")
    end
end)

getgenv().debughighlight = DebugTab.new("label", {text = "Highlighted Player: ", color = Color3.new(1, 1, 1),})
getgenv().debugdistance = DebugTab.new("label", {text = "Ball Distance: ", color = Color3.new(1, 1, 1),})
getgenv().debugballspeed = DebugTab.new("label", {text = "Ball Speed: ", color = Color3.new(1, 1, 1),})
getgenv().debugautoclashrunning = DebugTab.new("label", {text = "AutoClashRunning: ", color = Color3.new(1, 1, 1),})
getgenv().debugtimecheck = DebugTab.new("label", {text = "Time Before Last Parry: ", color = Color3.new(1, 1, 1),})
