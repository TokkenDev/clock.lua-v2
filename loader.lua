local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/TokkenDev/clock.lua-v2/refs/heads/main/XSX%20Library%20Fixed"))()
library:Watermark("clock.lua | loader | v2.0.0 | " .. library:GetUsername())
local Notifications = library:InitNotifications()
Notifications:Notify("Loading XSX Lib Fixed, please be patient.", 3, "information")
library.title = "clock.lua"
library:Introduction()
local Init = library:Init()
local LoaderTab = Init:NewTab("Loader")
local TestTab = Init:NewTab("Test Version")
local GamesTab = Init:NewTab("Games")
local UITab = Init:NewTab("UI")
local SkidTab = Init:NewTab("SKID LIST")

-- Init --
local TestVersionToggle = false
local TestKey = nil
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local unsupexecTable = {
    ["Solara"] = 1,
    ["Xeno"] = 1,
    ["SirHurt"] = 2
}

-- Functions --
local function GetGameName(gameid)
    local success, gameInfo = pcall(function()
        return MarketplaceService:GetProductInfo(gameid)
    end)

    if success then
        return gameInfo.Name
    else
        return "Failed to get the game's name, sorry!"
    end
end

local function isAndroid()
    return UserInputService:GetPlatform() == Enum.Platform.Android
    -- gonna use this for a mobile ui toggle when i add it fr
end

-- Library Components --

-- Loader --
LoaderTab:NewButton("Execute Script", function()
    local executor = identifyexecutor()
    local device = isAndroid()
    for name, arg in pairs(unsupexecTable) do
        if string.match(name, executor) then
            if arg == 2 then
                Notifications:Notify("Your executor "..executor.." can have problems with some functions of clock.lua, please keep that in mind.", 10, "information")
                Notifications:Notify("The script will execute in 10 seconds, please read this :)", 10, "information")
                task.wait(10)
            elseif arg == 1 then
                game:GetService("Players").LocalPlayer:Kick("Your executor '"..executor.."' is too low-level for clock.lua to function properly, please use "..(device and "Delta" or "Zenith or Swift").." (or visit voxlis.net to search for a better executor)")
                error()
            end
        end
    end
    local success, errormessage = pcall(function()
        library:Remove()
        if TestVersionToggle == false then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/TokkenDev/clock.lua-v2/refs/heads/main/"..tostring(game.PlaceId)))()
        else
            loadstring(game:HttpGet("https://raw.githubusercontent.com/TokkenDev/clock.lua-v2/refs/heads/main/"..tostring(game.PlaceId).."experimental"))()
        end
    end)
    if not success then
        Notifications:Notify("Game not supported or currently broken, if this is an error please report it (console)!", 3, "error")
        error("[clock.lua] "..tostring(game.PlaceId).." Not Supported/Broken, error: "..errormessage)
    end
end)

LoaderTab:NewLabel("Made with <3 by tokkendev", "center")

LoaderTab:NewButton("Rejoin Server", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
end)

-- Test Version --
TestTab:NewLabel("Test versions might have unfinished features, bugs, or sometimes no changes at all.", "center")

TestTab:NewLabel("You don't need a key for the stable version. Sure, you could bypass it, but if you want to support me, please use the official method. :)", "center")

TestTab:NewLabel("Keys last for 24 hours.", "center")

TestTab:NewButton("Copy key link", function()
    if setclipboard then
        setclipboard("https://work.ink/235G/clockluatestversion")
        Notifications:Notify("Copied key link to clipboard!", 3, "success")
    else
        Notifications:Notify("Your executor does not support setclipboard, the link is below.", 3, "error")
        Notifications:Notify("https://work.ink/235G/clockluatestversion", 60, "information")
    end
end)

TestTab:NewTextbox("Enter key for the test version", "", "...", "all", "medium", true, false, function(Value)
    TestKey = Value
end)

local TestToggle
TestToggle = TestTab:NewToggle("Toggle test version", false, function(bool)
    if inprogress then return end
    if TestKey then
        local url = "https://work.ink/_api/v2/token/isValid/"..TestKey
        local http_request = http_request or request
        local response = http_request({Url = url, Method = "GET"})
        local HttpService = game:GetService("HttpService")
        local data = HttpService:JSONDecode(response.Body)
        if bool and data.valid then
            Notifications:Notify("Enabled test version, enjoy.", 3, "success")
            TestVersionToggle = true
        elseif not bool and data.valid then
            Notifications:Notify("Disabled test version.", 3, "success")
            TestVersionToggle = false
        elseif bool and not data.valid then
            Notifications:Notify("Invalid test key!", 3, "error")
            inprogress = true
            TestToggle:Set(false)
            inprogress = false
        end
    else
        Notifications:Notify("Please input a key first.", 3, "error")
        inprogress = true
        TestToggle:Set(false)
        inprogress = false
    end
end)

-- Games --
GamesTab:NewLabel("You can copy the link to other supported games here!", "center")

local gamestable = {112279762578792, 133781619558477, 7979341445}
local nwgamestable = {103889808775700, 537413528, 13033713206}

GamesTab:NewLabel("Working Games", "center")
for _, gameid in gamestable do
    local gamename = GetGameName(gameid)
    GamesTab:NewButton(gamename, function()
        if setclipboard then
            setclipboard("https://www.roblox.com/games/"..gameid.."/")
            Notifications:Notify('Copied the game "'..gamename..'" to clipboard!', 3, "success")
        else
            Notifications:Notify("Pack it up and search the game urself, ur executor poo poo :)", 10, "error")
        end
    end)
end

GamesTab:NewLabel("Broken/Planned Games", "center")
for _, gameid in nwgamestable do
    local gamename = GetGameName(gameid)
    GamesTab:NewButton(gamename, function()
        Notifications:Notify('"'..gamename..'"'.." is either broken or only planned, try again later!", 3, "error")
    end)
end

-- UITab --
UITab:NewButton("Destroy UI", function()
    library:Remove()
end)

UITab:NewLabel("working on modifying the library for more ui functions", "center")

-- SkidTab --
SkidTab:NewLabel("Don't skid, you will appear here :)", "center")
-- zoro_ontop 885541246083407873
SkidTab:NewSection("Skid #1")
SkidTab:NewLabel("Subject: zoro_ontop, \nDiscord ID: 885541246083407873, \nRScripts: https://rscripts.net/@Dead, \nScriptBlox: https://scriptblox.com/u/DEADFR", "left")
SkidTab:NewLabel("Game: Mines", "left")
SkidTab:NewLabel("Reason: Pasted entire script and changed credits </3", "left")

SkidTab:NewSection("Skid #2")
SkidTab:NewLabel("Subject: OpenShared, \nRScripts: https://rscripts.net/@OpenShared", "left")
SkidTab:NewLabel("Game: Mines", "left")
SkidTab:NewLabel("Reason: How the actual fuck do you break a script that you copy-pasted???????? no credits also.", "left")

-- End of skid list
SkidTab:NewSection("END OF LIST")

Notifications:Notify("Loaded XSX Lib Fixed", 3, "success")
