-- Example LocalScript for an experience you own.
-- Install the OrbitUI ModuleScripts as described in README.md.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Orbit = require(ReplicatedStorage.OrbitUI.src.OrbitUI)

local Window = Orbit:CreateWindow({
    Name = "OrbitUI",
    LoadingTitle = "OrbitUI",
    Subtitle = "Developer interface demo",
    Width = 620,
    Height = 440,
})

Window:Notify({
    Title = "OrbitUI loaded",
    Content = "The interface is ready.",
    Duration = 4,
})

local Main = Window:CreateTab("Main")

Main:CreateSection("Basic controls")

Main:CreateButton({
    Name = "Example action",
    ButtonText = "Click",
    Callback = function()
        Window:Notify({
            Title = "Button clicked",
            Content = "Your callback ran successfully.",
        })
    end,
})

Main:CreateToggle({
    Name = "Example setting",
    CurrentValue = false,
    Callback = function(enabled)
        print("Example setting:", enabled)
    end,
})

Main:CreateInput({
    Name = "Username",
    PlaceholderText = "Enter a username",
    Callback = function(value, enterPressed)
        print("Entered:", value, "Submitted:", enterPressed)
    end,
})

Main:CreateSlider({
    Name = "Volume",
    Range = {0, 100},
    CurrentValue = 35,
    DecimalPlaces = 0,
    Callback = function(value)
        print("Volume:", value)
    end,
})

Main:CreateDropdown({
    Name = "Quality",
    Options = {"Low", "Medium", "High"},
    CurrentOption = "Medium",
    Callback = function(option)
        print("Quality:", option)
    end,
})
