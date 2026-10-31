# OrbitUI

A modular Roblox UI library for **Roblox Studio experiences**. OrbitUI is designed to provide a clean, Rayfield-inspired developer interface with windows, tabs, and reusable controls.

## Project status

**Starter foundation** — the first working window, tab, button, toggle, and text input APIs are being built. More controls, themes, documentation, and examples can be added incrementally.

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

## Studio setup

1. In Roblox Studio, create a Folder named `OrbitUI` under `ReplicatedStorage`.
2. Recreate the `src` files as **ModuleScripts** inside that folder (the source files in this repository are the contents for those ModuleScripts).
3. Place `OrbitUI.lua`, `Window.lua`, `Tab.lua`, and `Controls.lua` together under the same `src` folder.
4. Require the `OrbitUI` ModuleScript from a LocalScript in `StarterPlayerScripts`.

Example:

```lua
local OrbitUI = require(game.ReplicatedStorage.OrbitUI.src.OrbitUI)

local Window = OrbitUI.CreateWindow({
    Name = "My Orbit UI",
    Subtitle = "Developer tools",
})

local MainTab = Window:CreateTab("Main")

MainTab:CreateButton({
    Name = "Example button",
    Callback = function()
        print("Button clicked")
    end,
})

MainTab:CreateToggle({
    Name = "Example toggle",
    CurrentValue = false,
    Callback = function(enabled)
        print("Toggle:", enabled)
    end,
})

MainTab:CreateInput({
    Name = "Player name",
    PlaceholderText = "Enter a name",
    Callback = function(value)
        print("Input:", value)
    end,
})
```

## Design principles

- Built for normal Roblox Studio experiences and client-side interface code.
- Modular source with readable Luau.
- No hidden remote calls, executor dependencies, or automatic game manipulation.
- Callbacks are supplied by the experience developer.

## License

MIT. See the repository license settings or add a LICENSE file before distributing.
