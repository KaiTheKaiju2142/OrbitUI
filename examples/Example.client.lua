-- OrbitUI example LocalScript for a Roblox experience you own.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OrbitLib = require(ReplicatedStorage.OrbitUI.src.OrbitUI)

local Window = OrbitLib:MakeWindow({
    Name = "OrbitUI",
    HidePremium = true,
    IntroEnabled = false,
})

local Main = Window:MakeTab({Name = "Main"})
Main:AddSection({Name = "Controls"})

Main:AddButton({
    Name = "Notify",
    Callback = function()
        OrbitLib:MakeNotification({
            Name = "Hello",
            Content = "Your callback is running.",
            Time = 3,
        })
    end,
})

Main:AddToggle({
    Name = "Demo toggle",
    Default = false,
    Flag = "demo_toggle",
    Callback = function(value)
        print("Demo toggle:", value)
    end,
})

Main:AddSlider({
    Name = "Volume",
    Min = 0,
    Max = 100,
    Default = 35,
    Increment = 5,
    ValueName = "%",
    Callback = function(value)
        print("Volume:", value)
    end,
})

Main:AddDropdown({
    Name = "Quality",
    Options = {"Low", "Medium", "High"},
    Default = "Medium",
    Callback = function(value)
        print("Quality:", value)
    end,
})

Main:AddTextbox({
    Name = "Username",
    Default = "",
    Callback = function(value)
        print("Username:", value)
    end,
})

Main:AddLabel("OrbitUI label")
Main:AddParagraph("About", "An Orion-style API with OrbitUI implementation.")

OrbitLib:Init()
