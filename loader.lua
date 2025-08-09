-- loadstring(game:HttpGet("https://raw.githubusercontent.com/TokkenDev/clock.lua-v2/refs/heads/main/loader.lua"))() 

local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
local Window = OrionLib:MakeWindow({Name = "clock.lua - Loader", HidePremium = false, SaveConfig = true, ConfigFolder = "clock.lua.loader"})
local LoaderTab = Window:MakeTab({
    Name = "Loader",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
local TestTab = Window:MakeTab({
    Name = "Test Version",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
local GamesTab = Window:MakeTab({
    Name = "Supported Games",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

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

-- Tab Elements --

-- Loader --
LoaderTab:AddButton({Name = "Execute Script", Callback = function()
    OrionLib:Destroy()
    if TestToggle == false then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/TokkenDev/clock.lua-v2/refs/heads/main/"..tostring(game.PlaceId)))()
    else
        loadstring(game:HttpGet("https://raw.githubusercontent.com/TokkenDev/clock.lua-v2/refs/heads/main/"..tostring(game.PlaceId).."experimental"))()
    end
end})

LoaderTab:AddLabel("Made with <3 by tokkendev")

LoaderTab:AddButton({Name = "Rejoin Server", Callback = function()
    OrionLib:Destroy()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
end})

-- Test Version --
TestTab:AddParagraph("WARNING", "Test Versions can be extremely unstable, or not work at all. DO NOT report bugs if you're using the test version.")

TestTab:AddToggle({Name = "Toggle Test Version",  Default = false,  Callback = function(bool)
    TestToggle = bool
    OrionLib:MakeNotification({
        Name = "Toggled Test Version",
        Content = "Hope you read the warning :)",
        Image = "rbxassetid://4483345998",
        Time = 6
    })
end})

-- Games --
GamesTab:AddLabel("You can switch to other supported games here!")

GamesTab:AddButton({Name = GetGameName(112279762578792), Callback = function()
    OrionLib:Destroy()
    TeleportService:Teleport(112279762578792, Player)
end})

GamesTab:AddButton({Name = GetGameName(133781619558477).." (Experimental)", Callback = function()
    OrionLib:MakeNotification({
        Name = "hey",
        Content = "coming soon schnawg ✌️",
        Image = "rbxassetid://4483345998",
        Time = 6
    })
    --OrionLib:Destroy()
    --TeleportService:Teleport(133781619558477, Player)
end})

GamesTab:AddButton({Name = GetGameName(103889808775700).." (Soon)", Callback = function()
    OrionLib:MakeNotification({
        Name = "hey",
        Content = "coming soon schnawg ✌️",
        Image = "rbxassetid://4483345998",
        Time = 6
    })
    --OrionLib:Destroy()
    --TeleportService:Teleport(103889808775700, Player)
end})

OrionLib:Init()
