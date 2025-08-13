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

-- Init --
local TestToggle = false
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local Player = game:GetService("Players").LocalPlayer

-- Function --
local function GetGameName(gameid)
    local success, gameInfo = pcall(function()
        return MarketplaceService:GetProductInfo(gameid)
    end)

    if success then
        return gameInfo.Name
    else
        return "Failed to get game's name!"
    end
end

-- Library Components --

-- Loader --
LoaderTab:NewButton("Execute Script", function()
    local success, errormessage = pcall(function()
        library:Remove()
        if TestToggle == false then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/TokkenDev/clock.lua-v2/refs/heads/main/"..tostring(game.PlaceId)))()
        else
            loadstring(game:HttpGet("https://raw.githubusercontent.com/TokkenDev/clock.lua-v2/refs/heads/main/"..tostring(game.PlaceId).."experimental"))()
        end
    end)
    if not success then
        Notifications:Notify("Game not supported or currently broken, if this is an error please report it (console)!", 3, "error")
        error("[clock.lua] "..tostring(game.PlaceId).." Not Supported, error: "..errormessage)
    end
end)

LoaderTab:NewLabel("Made with <3 by tokkendev", "center")

LoaderTab:NewButton("Rejoin Server", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
end)

-- Test Version --
TestTab:NewLabel("Test Versions can be extremely unstable, or not work at all. DO NOT report bugs if you're using the test version.", "center")

TestTab:NewToggle("Toggle Test Version", false, function(bool)
    TestToggle = bool
    if bool then
        Notifications:Notify("Hope you read the warning :)", 3, "information")
    end
end)

-- Games --
GamesTab:NewLabel("You can copy the link to other supported games here!", "center")

local gamestable = {112279762578792, 133781619558477}
local nwgamestable = {103889808775700, 16991287194, 7979341445}

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

Notifications:Notify("Loaded XSX Lib", 3, "success")
