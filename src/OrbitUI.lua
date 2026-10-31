-- OrbitUI public entry point
-- This is a ModuleScript entry point for an authorized Roblox experience.

local Window = require(script.Parent.Window)

local OrbitUI = {}
OrbitUI.Version = "0.2.0"

-- Supports both OrbitUI:CreateWindow({...}) and OrbitUI.CreateWindow({...}).
function OrbitUI.CreateWindow(selfOrOptions, maybeOptions)
    local options = selfOrOptions == OrbitUI and maybeOptions or selfOrOptions
    return Window.new(options or {})
end

return OrbitUI
