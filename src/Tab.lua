-- OrbitUI tab implementation

local Controls = require(script.Parent.Controls)

local Tab = {}
Tab.__index = Tab

local function make(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

function Tab.new(window, name)
    local self = setmetatable({}, Tab)
    self.Window = window
    self.Name = name or "Tab"

    local button = make("TextButton", {
        Name = self.Name .. "Tab",
        Size = UDim2.new(1, -4, 0, 34),
        BackgroundColor3 = window.Theme.SurfaceLight,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        Text = self.Name,
        TextColor3 = window.Theme.Muted,
        TextSize = 12,
    }, window.Sidebar)
    make("UICorner", { CornerRadius = UDim.new(0, 6) }, button)
    self.Button = button

    local page = make("ScrollingFrame", {
        Name = self.Name .. "Page",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, window.Content)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, page)
    make("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)
    self.Page = page

    button.Activated:Connect(function()
        self:Show()
    end)

    return self
end

function Tab:Show()
    for _, other in ipairs(self.Window.Tabs) do
        other.Page.Visible = false
        other.Button.BackgroundTransparency = 1
        other.Button.TextColor3 = self.Window.Theme.Muted
    end
    self.Page.Visible = true
    self.Button.BackgroundTransparency = 0
    self.Button.BackgroundColor3 = self.Window.Theme.SurfaceLight
    self.Button.TextColor3 = self.Window.Theme.Text
end

function Tab:MakeTab(config)
    return self.Window:CreateTab(config and config.Name or "Tab")
end

function Tab:CreateSection(name)
    return Controls.CreateSection(self, name)
end

function Tab:CreateButton(options)
    return Controls.CreateButton(self, options or {})
end

function Tab:CreateToggle(options)
    return Controls.CreateToggle(self, options or {})
end

function Tab:CreateInput(options)
    return Controls.CreateInput(self, options or {})
end

function Tab:CreateSlider(options)
    return Controls.CreateSlider(self, options or {})
end

function Tab:CreateDropdown(options)
    return Controls.CreateDropdown(self, options or {})
end

local function registerFlag(tab, handle, options, kind)
    options = options or {}
    handle.Type = kind
    handle.Save = options.Save == true
    if options.Flag then
        tab.Window.Flags[options.Flag] = handle
    end
    return handle
end

function Tab:AddSection(config)
    return self:CreateSection(type(config) == "table" and config.Name or config)
end

function Tab:AddButton(options)
    return self:CreateButton(options)
end

function Tab:AddToggle(options)
    options = options or {}
    local handle
    handle = self:CreateToggle({
        Name = options.Name,
        CurrentValue = options.Default,
        Callback = function(value)
            if handle then handle.Value = value end
            if typeof(options.Callback) == "function" then options.Callback(value) end
        end,
    })
    handle.Value = handle:Get()
    local originalSet = handle.Set
    handle.Set = function(_, value)
        originalSet(handle, value)
        handle.Value = handle:Get()
    end
    return registerFlag(self, handle, options, "Toggle")
end

function Tab:AddSlider(options)
    options = options or {}
    local handle
    handle = self:CreateSlider({
        Name = options.Name,
        Range = {options.Min or 0, options.Max or 100},
        CurrentValue = options.Default,
        Increment = options.Increment,
        ValueName = options.ValueName,
        DecimalPlaces = options.DecimalPlaces,
        Callback = function(value)
            if handle then handle.Value = value end
            if typeof(options.Callback) == "function" then options.Callback(value) end
        end,
    })
    handle.Value = handle:Get()
    local originalSet = handle.Set
    handle.Set = function(_, value)
        originalSet(handle, value)
        handle.Value = handle:Get()
    end
    return registerFlag(self, handle, options, "Slider")
end

function Tab:AddDropdown(options)
    options = options or {}
    local handle
    handle = self:CreateDropdown({
        Name = options.Name,
        Options = options.Options,
        CurrentOption = options.Default,
        Callback = function(value)
            if handle then handle.Value = value end
            if typeof(options.Callback) == "function" then options.Callback(value) end
        end,
    })
    handle.Value = handle:Get()
    local originalSet = handle.Set
    handle.Set = function(_, value)
        originalSet(handle, value)
        handle.Value = handle:Get()
    end
    local originalRefresh = handle.Refresh
    handle.Refresh = function(_, values, deleteCurrent)
        originalRefresh(handle, values, deleteCurrent)
        handle.Value = handle:Get()
    end
    return registerFlag(self, handle, options, "Dropdown")
end

function Tab:AddTextbox(options)
    options = options or {}
    return self:CreateInput({
        Name = options.Name,
        Default = options.Default,
        PlaceholderText = options.PlaceholderText,
        Callback = options.Callback,
    })
end

function Tab:AddLabel(text)
    return Controls.CreateLabel(self, text)
end

function Tab:AddParagraph(title, content)
    return Controls.CreateParagraph(self, title, content)
end

function Tab:AddColorpicker(options)
    options = options or {}
    local handle = Controls.CreateColorpicker(self, options)
    return registerFlag(self, handle, options, "Colorpicker")
end

function Tab:AddBind(options)
    options = options or {}
    local handle = Controls.CreateKeybind(self, options)
    return registerFlag(self, handle, options, "Bind")
end

-- Short aliases for the compact OrbitUI API.
function Tab:CSN(config) return self:AddSection(config) end
function Tab:CB(options) return self:AddButton(options) end
function Tab:CT(options) return self:AddToggle(options) end
function Tab:CS(options) return self:AddSlider(options) end
function Tab:CD(options) return self:AddDropdown(options) end
function Tab:CTX(options) return self:AddTextbox(options) end
function Tab:CK(options) return self:AddBind(options) end
function Tab:CL(text) return self:AddLabel(text) end
function Tab:CP(title, content) return self:AddParagraph(title, content) end
function Tab:CC(options) return self:AddColorpicker(options) end
return Tab
