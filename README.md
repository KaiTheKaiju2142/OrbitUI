# OrbitUI

OrbitUI is a modular, code-driven Roblox interface library for experiences you develop. It creates its GUI at runtime from Luau calls, with a dark default theme and a Rayfield-inspired developer experience.

## Current status

**Early foundation (0.2.0).** Includes windows, draggable title bars, tabs, sections, buttons, toggles, text inputs, sliders, dropdowns, and notifications. The API and visuals are still evolving.

## Source layout

```
OrbitUI/
├── src/
│   ├── OrbitUI.lua
│   ├── Window.lua
│   ├── Tab.lua
│   └── Controls.lua
├── examples/
│   └── Example.client.lua
└── README.md
```

## Roblox Studio installation

1. In your experience, create a Folder named `OrbitUI` under `ReplicatedStorage`.
2. Inside it, create a Folder named `src`.
3. Create four ModuleScripts inside `src`: `OrbitUI`, `Window`, `Tab`, and `Controls`. Copy the matching source file contents into each ModuleScript.
4. Put the example LocalScript in `StarterPlayerScripts`.

The library creates the ScreenGui and all controls at runtime; you do not need to manually build the interface in Studio.

## Quick start

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Orbit = require(ReplicatedStorage.OrbitUI.src.OrbitUI)

local Window = Orbit:CreateWindow({
    Name = "My Hub",
    Subtitle = "Made with OrbitUI",
    Width = 620,
    Height = 440,
})

local Main = Window:CreateTab("Main")

Main:CreateSection("Controls")

Main:CreateButton({
    Name = "Run action",
    Callback = function()
        print("Button clicked")
    end,
})

Main:CreateToggle({
    Name = "Enabled",
    CurrentValue = false,
    Callback = function(value)
        print("Enabled:", value)
    end,
})

Main:CreateSlider({
    Name = "Amount",
    Range = {0, 100},
    CurrentValue = 25,
    Callback = function(value)
        print("Amount:", value)
    end,
})

Main:CreateDropdown({
    Name = "Mode",
    Options = {"Easy", "Normal", "Hard"},
    CurrentOption = "Normal",
    Callback = function(value)
        print("Mode:", value)
    end,
})

Window:Notify({
    Title = "Ready",
    Content = "Your interface has loaded.",
})
```

## API overview

- `Orbit:CreateWindow(options)`
- `Window:CreateTab(name)`
- `Window:Notify(options)`
- `Window:Destroy()`
- `Tab:Show()`
- `Tab:CreateSection(name)`
- `Tab:CreateButton(options)`
- `Tab:CreateToggle(options)`
- `Tab:CreateInput(options)`
- `Tab:CreateSlider(options)`
- `Tab:CreateDropdown(options)`

Controls return small handles with methods such as `Get()` and `Set(value)` where applicable.

## Scope and compatibility

This repository focuses on the interface layer and callbacks for authorized projects. It does not include game-specific remote actions, exploit features, protection bypasses, or executor integration. The included example targets a normal Roblox Studio LocalScript environment.

The source has not yet been runtime-tested in Roblox Studio; validate it in a test place before using it in a published experience.
