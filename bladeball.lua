-- Library

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Singularity5490/rbimgui-2/main/rbimgui-2.lua"))()
local Window = Library.new({
    text = "clock.lua v2 | Blade Ball",
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
                        getgenv().autoparryrunning = false
                    end
                end
            end
        end
    end)
end

-- Functions

getgenv().autoparry = false
getgenv().autoclash = false
getgenv().pingbased = false
getgenv().aliveordead = workspace.Alive
getgenv().ball = workspace.Balls
getgenv().autoclashrunning = false
fpressed = 0

function presskey(keybind)
    game:GetService("VirtualInputManager"):SendKeyEvent(true,keybind,false,game)
    task.wait(0.01)
    game:GetService("VirtualInputManager"):SendKeyEvent(false,keybind,false,game)
end

function getballspeed()
    ball = getgenv().ball:FindFirstChildWhichIsA("Part")
    if ball and ball.Anchored == false then
        if ball.Velocity.magnitude > 0 then
            local speed = 30 * (ball.Velocity.magnitude / 110)
            if speed >= 200 then
                finalresult = 200
            elseif speed <= 25 then
                finalresult = 25
            else
                finalresult = speed
            end
        else
            finalresult = 0
        end
    else
        finalresult = 0
    end
    if getgenv().pingbased == true then
        return finalresult + (LPlayer:GetNetworkPing() * 100)
    else
        return finalresult
    end
end

function getdistance()
    for i,v in pairs(getgenv().ball:GetChildren()) do
        if LPlayer.Character:FindFirstChild("HumanoidRootPart") and v then
            finalresult2 = (LPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v.Position).magnitude
        else
            finalresult2 = 1000
        end
    end
    if not finalresult2 then return 1000 else return finalresult2 end
end

function gettargetplayer()
    for i,v in pairs(getgenv().aliveordead:GetChildren()) do
        if v:FindFirstChild("Highlight") then
            return v
        end
    end
    return "nil"
end

function autoclash()
    if getgenv().autoclashrunning ~= true then task.wait()
        local target = gettargetplayer()
        getgenv().autoclashrunning = true
        if tostring(target) ~= "nil" and tostring(target) ~= LPlayer.Name then
            while tostring(gettargetplayer()) ~= LPlayer.Name do task.wait()
                if tostring(gettargetplayer()) == LPlayer.Name then
                    break
                else
                    getgenv().autoclashrunning = false
                    return
                end
            end
            getgenv().ClashStatusLabel.setText("Auto Clash Status: True")
            getgenv().ClashStatusLabel.setColor(Color3.new(0, 1, 0))
            while (tostring(gettargetplayer()) == tostring(target) or tostring(gettargetplayer()) == LPlayer.Name) and (target.Humanoid.Health > 0) and ((target.HumanoidRootPart.Position - LPlayer.Character.HumanoidRootPart.Position).Magnitude <= 30 + (getballspeed()/5)) and (getballspeed() > 0) do
                for i = 1,10 do
                    presskey(Enum.KeyCode.F)
                end
                task.wait()
            end
            getgenv().ClashStatusLabel.setText("Auto Clash Status: False")
            getgenv().ClashStatusLabel.setColor(Color3.new(1, 0, 0))
        end
        getgenv().autoclashrunning = false
    end
end

function autoparry()
    if tostring(gettargetplayer()) == LPlayer.Name and getdistance() <= getballspeed() then
        presskey(Enum.KeyCode.F)
    end
end

if not AutoSpamConnection then
    AutoSpamConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if getgenv().autoclash == true then
            autoclash()
        end
    end)
end

if not AutoBlockConnection then
    AutoBlockConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if getgenv().autoparry == true then
            autoparry()
        end
    end)
end

-- Menu

local MainTab = Window.new({text = "Main ",})
local MiscTab = Window.new({text = "Misc ",})
local DebugTab = Window.new({text = "Debug ",})

-- MainTab

local ToggleAutoBlock = MainTab.new("switch", {text = "Toggle Auto Parry";})
ToggleAutoBlock.set(getgenv().autoparry or false)
ToggleAutoBlock.event:Connect(function(Value)
    getgenv().autoparry = Value
end)

local ToggleAutoSpam = MainTab.new("switch", {text = "Toggle Auto Clash - Experimental";})
ToggleAutoSpam.set(getgenv().autoclash or false)
ToggleAutoSpam.event:Connect(function(Value)
    getgenv().autoclash = Value
end)

local TogglePingBased = MainTab.new("switch", {text = "Ping Based";})
TogglePingBased.set(getgenv().pingbased or false)
TogglePingBased.event:Connect(function(Value)
    getgenv().pingbased = Value
end)

local ToggleTraining = MainTab.new("switch", {text = "Toggle Training Ball";})
ToggleTraining.set(getgenv().pingbased or false)
ToggleTraining.event:Connect(function(Value)
    if Value == true then
        getgenv().aliveordead = workspace.Dead
        getgenv().ball = workspace.TrainingBalls
    else
        getgenv().aliveordead = workspace.Alive
        getgenv().ball = workspace.Balls
    end
end)

getgenv().ClashStatusLabel = MainTab.new("label", {text = "Auto Clash Status: False", color = Color3.new(1, 0, 0),})

-- Misc Tab

-- oh well nothing here yet

-- DebugTab

local ToggleDebug = DebugTab.new("switch", {text = "Toggle Debug";})
ToggleDebug.set(getgenv().pingbased or false)
ToggleDebug.event:Connect(function(Value)
    getgenv().debugtoggle = Value
    if getgenv().debugtoggle == true then
        while getgenv().debugtoggle == true do task.wait()
            getgenv().debughighlight.setText("Highlighted Player: "..tostring(gettargetplayer()))
            getgenv().debugdistance.setText("Ball Distance: "..getdistance())
            getgenv().debugballspeed.setText("Ball Speed: "..getballspeed())
            getgenv().debugautoclashrunning.setText("AutoClashRunning: "..tostring(getgenv().autoclashrunning))
            getgenv().debugpressedamount.setText("Key Pressed Amount: "..tostring(fpressed))
        end
    else
        task.wait(1)
        getgenv().debughighlight.setText("Highlighted Player: ")
        getgenv().debugdistance.setText("Ball Distance: ")
        getgenv().debugballspeed.setText("Ball Speed: ")
        getgenv().debugautoclashrunning.setText("AutoClashRunning: ")
        getgenv().debugpressedamount.setText("Key Pressed Amount: ")
    end
end)

getgenv().debughighlight = DebugTab.new("label", {text = "Highlighted Player: ", color = Color3.new(1, 1, 1),})
getgenv().debugdistance = DebugTab.new("label", {text = "Ball Distance: ", color = Color3.new(1, 1, 1),})
getgenv().debugballspeed = DebugTab.new("label", {text = "Ball Speed: ", color = Color3.new(1, 1, 1),})
getgenv().debugautoclashrunning = DebugTab.new("label", {text = "AutoClashRunning: ", color = Color3.new(1, 1, 1),})
getgenv().debugpressedamount = DebugTab.new("label", {text = "Key Pressed Amount: ", color = Color3.new(1, 1, 1),})