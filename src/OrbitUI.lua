-- OrbitUI public entry point
-- Place this ModuleScript beside Window.lua, Tab.lua, and Controls.lua.

local Window = require(script.Parent.Window)

local OrbitUI = {}

OrbitUI.Version = "0.1.0"

function OrbitUI.CreateWindow(options)
    return Window.new(options or {})
end

return OrbitUI
