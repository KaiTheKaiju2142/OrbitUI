-- OrbitUI public entry point
-- UI-only library for authorized Roblox experiences.

local Window = require(script.Parent.Window)

local OrbitUI = {
    Version = "0.3.0",
    Flags = {},
}

function OrbitUI.MakeWindow(selfOrOptions, maybeOptions)
    local options = selfOrOptions == OrbitUI and maybeOptions or selfOrOptions
    local window = Window.new(options or {})
    OrbitUI.Flags = window.Flags
    window.Library = OrbitUI
    return window
end

OrbitUI.CreateWindow = OrbitUI.MakeWindow

function OrbitUI.MakeNotification(selfOrConfig, maybeConfig)
    local config = selfOrConfig == OrbitUI and maybeConfig or selfOrConfig
    if OrbitUI._lastWindow then
        return OrbitUI._lastWindow:Notify(config)
    end
    warn("OrbitUI: create a window before sending notifications.")
end

function OrbitUI.Init()
    if OrbitUI._lastWindow then
        return OrbitUI._lastWindow:Init()
    end
end

function OrbitUI.Destroy()
    if OrbitUI._lastWindow then
        OrbitUI._lastWindow:Destroy()
        OrbitUI._lastWindow = nil
    end
end

local originalMakeWindow = OrbitUI.MakeWindow
OrbitUI.MakeWindow = function(selfOrOptions, maybeOptions)
    local window = originalMakeWindow(selfOrOptions, maybeOptions)
    OrbitUI._lastWindow = window
    return window
end
OrbitUI.CreateWindow = OrbitUI.MakeWindow

return OrbitUI
