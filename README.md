# OrbitUI

OrbitUI is a modular Luau interface library for Roblox experiences you own or are authorized to develop. Its public API follows the familiar Orion-style pattern documented in the supplied reference, with OrbitUI's own implementation and visuals.

## Standalone distribution

A bundled, single-file build is available at `dist/OrbitUI.lua`. It includes the controls, tabs, window, and public API in one file and returns the OrbitUI library table. It has no `require(script.Parent...)` dependencies.

In a client-side Luau environment that explicitly provides a permitted `loadstring` implementation, pass the source text of `dist/OrbitUI.lua` to that environment's loader and use the returned table. The bundle itself does not fetch remote code or perform injection. Standard Roblox client LocalScripts do not provide `loadstring`; use the ModuleScript installation below in ordinary Roblox Studio experiences.

## Installation (Roblox Studio)

1. Create a Folder named `OrbitUI` under `ReplicatedStorage`.
2. Inside it, create a Folder named `src`.
3. Add ModuleScripts named `OrbitUI`, `Window`, `Tab`, and `Controls`, and paste the matching files from this repository.
4. Run the example from a LocalScript in `StarterPlayerScripts`.

OrbitUI creates its ScreenGui under the local player's `PlayerGui`; it does not depend on executor-only UI containers or privileged APIs.

## Quick start

Place the OrbitUI ModuleScripts in `ReplicatedStorage/OrbitUI/src` as described above, then run this from a client LocalScript in `StarterPlayerScripts`:

```lua
local OrbitLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/KaiTheKaiju2142/OrbitUI/main/dist/OrbitUI.lua"))()

local Window = OrbitLib:MakeWindow({Name = "OrbitUI"})
local Main = Window:MakeTab({Name = "Main"})

Main:CB({
    Name = "Say hello",
    Callback = function()
        print("Hello")
    end,
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
