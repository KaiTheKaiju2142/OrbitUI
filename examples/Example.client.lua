-- Example LocalScript for Roblox Studio
-- Requires the OrbitUI folder/module structure described in README.md.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OrbitUI = require(ReplicatedStorage.OrbitUI.src.OrbitUI)

local Window = OrbitUI.CreateWindow({
    Name = "OrbitUI",
    Subtitle = "A modular interface starter",
    Width = 620,
    Height = 420,
})

local Main = Window:CreateTab("Main")

Main:CreateButton({
    Name = "Example action",
    ButtonText = "Click",
    Callback = function()
        print("OrbitUI button pressed")
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
    Callback = function(value)
        print("Entered:", value)
    end,
})
