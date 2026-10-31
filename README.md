# OrbitUI

OrbitUI is a modular Luau interface library for Roblox experiences you own or are authorized to develop. Its public API follows the familiar Orion-style pattern documented in the supplied reference, with OrbitUI's own implementation and visuals.

## Installation (Roblox Studio)

1. Create a Folder named `OrbitUI` under `ReplicatedStorage`.
2. Inside it, create a Folder named `src`.
3. Add ModuleScripts named `OrbitUI`, `Window`, `Tab`, and `Controls`, and paste the matching files from this repository.
4. Run the example from a LocalScript in `StarterPlayerScripts`.

OrbitUI creates its ScreenGui under the local player's `PlayerGui`; it does not depend on executor-only UI containers or privileged APIs.

## Quick start

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OrbitLib = require(ReplicatedStorage.OrbitUI.src.OrbitUI)

local Window = OrbitLib:MakeWindow({
    Name = "Orbit Hub",
    HidePremium = true,
    SaveConfig = false,
    IntroEnabled = false,
    CloseCallback = function()
        print("Window closed")
    end,
})

local Main = Window:MakeTab({
    Name = "Main",
    Icon = "",
    PremiumOnly = false,
})

local Section = Main:CSN({Name = "General"})

Main:CB({
    Name = "Example button",
    Callback = function()
        print("Clicked")
    end,
})

local Toggle = Main:CT({
    Name = "Example toggle",
    Default = false,
    Flag = "example_toggle",
    Save = false,
    Callback = function(value)
        print("Toggle:", value)
    end,
})

local Slider = Main:CS({
    Name = "Amount",
    Min = 0,
    Max = 100,
    Default = 25,
    Increment = 1,
    ValueName = "units",
    Callback = function(value)
        print("Slider:", value)
    end,
})

local Dropdown = Main:CD({
    Name = "Mode",
    Default = "Normal",
    Options = {"Easy", "Normal", "Hard"},
    Callback = function(value)
        print("Mode:", value)
    end,
})

Main:CTX({
    Name = "Search",
    Default = "",
    Callback = function(value)
        print("Input:", value)
    end,
})

Main:CL("A simple label")
Main:CP("About", "This is a paragraph description.")

local Color = Main:CC({
    Name = "Accent color",
    Default = Color3.fromRGB(120, 90, 255),
    Callback = function(value)
        print("Color:", value)
    end,
})

local Bind = Main:CK({
    Name = "Action key",
    Default = Enum.KeyCode.E,
    Hold = false,
    Callback = function()
        print("Key pressed")
    end,
})

Toggle:Set(true)
Slider:Set(50)
Dropdown:Set("Hard")
Color:Set(Color3.fromRGB(255, 80, 80))
Bind:Set(Enum.KeyCode.Q)

OrbitLib:MakeNotification({
    Name = "OrbitUI",
    Content = "Interface initialized",
    Time = 4,
})

OrbitLib:Init()
```

## API

```lua
Tab:CB()   -- Button
Tab:CT()   -- Toggle
Tab:CS()   -- Slider
Tab:CD()   -- Dropdown
Tab:CTX()  -- Textbox
Tab:CK()   -- Keybind
Tab:CL()   -- Label
Tab:CP()   -- Paragraph
Tab:CSN()  -- Section
Tab:CC()   -- Colorpicker
```


- `OrbitLib:MakeWindow(options)` (also `CreateWindow`)
- `Window:MakeTab({Name, Icon, PremiumOnly})` (also `CreateTab(name)`)
- `Tab:CSN({Name})` — section
- `Tab:CB({Name, Callback})` — button
- `Tab:CT({Name, Default, Callback, Flag, Save})` — toggle
- `Tab:CS({Name, Min, Max, Default, Increment, ValueName, Callback, Flag, Save})` — slider
- `Tab:CD({Name, Default, Options, Callback, Flag, Save})` — dropdown
- `Tab:CTX({Name, Default, PlaceholderText, Callback})` — textbox
- `Tab:CK({Name, Default, Hold, Callback, Flag, Save})` — keybind
- `Tab:CL(text)` — label
- `Tab:CP(title, content)` — paragraph
- `Tab:CC({Name, Default, Callback, Flag, Save})` — colorpicker
- `OrbitLib:MakeNotification({Name, Content, Time})`
- `OrbitLib:Init()`
- `OrbitLib:Destroy()`

The original `Add...` methods remain available as compatibility aliases (for example, `AddTextbox` and `AddSection`).

Toggle, slider, dropdown, bind, and color picker handles expose `:Set(value)`, `:Get()`, and a `Value` field. Dropdown handles also expose `:Refresh(options, deleteCurrent)`. Flagged controls are available through `OrbitLib.Flags["flag_name"]`.

## Compatibility notes

The reference documents disk-backed config folders and executor-specific bootstrapping. This OrbitUI build does not copy those executor-only capabilities. `Save` and `Flag` currently register in-memory values only; disk config persistence is not implemented. The library is intended to be required from a LocalScript in a Roblox experience you control. It does not provide executor injection, privileged CoreGui placement, or game-manipulation features.

The UI source has not been runtime-tested in Roblox Studio. Test it in a private development place before publishing.
