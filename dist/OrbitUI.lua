-- OrbitUI standalone distribution.
-- Single-file Luau build; returns the OrbitUI library table.
-- Designed for a client environment with Roblox UI services available.

local function buildControls()
-- OrbitUI controls: Section, Button, Toggle, Input, Slider, Dropdown

local Controls = {}

local function make(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function createRow(tab, name, height)
    local row = make("Frame", {
        Name = name or "Control",
        Size = UDim2.new(1, 0, 0, height or 46),
        BackgroundColor3 = tab.Window.Theme.Background,
        BorderSizePixel = 0,
    }, tab.Page)
    make("UICorner", { CornerRadius = UDim.new(0, 7) }, row)
    make("UIStroke", { Color = tab.Window.Theme.Border, Thickness = 1 }, row)
    return row
end

local function createLabel(tab, parent, text, width)
    return make("TextLabel", {
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(width or 0.55, -12, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = text or "Control",
        TextColor3 = tab.Window.Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

function Controls.CreateSection(tab, name)
    local section = make("TextLabel", {
        Name = "Section",
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = tostring(name or "Section"),
        TextColor3 = tab.Window.Theme.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, tab.Page)
    return section
end

function Controls.CreateButton(tab, options)
    local row = createRow(tab, "Button")
    createLabel(tab, row, options.Name or "Button")

    local button = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -9, 0.5, 0),
        Size = UDim2.fromOffset(112, 30),
        BackgroundColor3 = tab.Window.Theme.Accent,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamSemibold,
        Text = options.ButtonText or "Run",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 11,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(0, 6) }, button)

    button.Activated:Connect(function()
        if typeof(options.Callback) == "function" then
            options.Callback()
        end
    end)

    return { Instance = row, Button = button }
end

function Controls.CreateToggle(tab, options)
    local row = createRow(tab, "Toggle")
    createLabel(tab, row, options.Name or "Toggle")

    local enabled = options.CurrentValue == true
    local button = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -9, 0.5, 0),
        Size = UDim2.fromOffset(42, 24),
        BackgroundColor3 = enabled and tab.Window.Theme.Accent or tab.Window.Theme.SurfaceLight,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, button)

    local knob = make("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.fromOffset(3, 0),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    }, button)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

    local function setValue(value, fireCallback)
        enabled = value == true
        button.BackgroundColor3 = enabled and tab.Window.Theme.Accent or tab.Window.Theme.SurfaceLight
        knob.Position = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.fromOffset(3, 0)
        if fireCallback and typeof(options.Callback) == "function" then
            options.Callback(enabled)
        end
    end

    button.Activated:Connect(function()
        setValue(not enabled, true)
    end)

    return {
        Instance = row,
        Set = function(_, value) setValue(value, true) end,
        Value = enabled,
        Get = function() return enabled end,
    }
end

function Controls.CreateInput(tab, options)
    local row = createRow(tab, "Input")
    createLabel(tab, row, options.Name or "Input")

    local input = make("TextBox", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -9, 0.5, 0),
        Size = UDim2.new(0.45, -8, 0, 30),
        BackgroundColor3 = tab.Window.Theme.SurfaceLight,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderText = options.PlaceholderText or "Type here...",
        PlaceholderColor3 = tab.Window.Theme.Muted,
        Text = options.Default or "",
        TextColor3 = tab.Window.Theme.Text,
        TextSize = 11,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(0, 6) }, input)

    input.FocusLost:Connect(function(enterPressed)
        if typeof(options.Callback) == "function" then
            options.Callback(input.Text, enterPressed)
        end
    end)

    return {
        Instance = row,
        Input = input,
        Get = function() return input.Text end,
        Set = function(_, value) input.Text = tostring(value or "") end,
    }
end

function Controls.CreateSlider(tab, options)
    local minimum = tonumber(options.Range and options.Range[1]) or tonumber(options.Min) or 0
    local maximum = tonumber(options.Range and options.Range[2]) or tonumber(options.Max) or 100
    if maximum <= minimum then
        maximum = minimum + 1
    end
    local increment = math.max(tonumber(options.Increment) or 1, 0.000001)
    local value = math.clamp(tonumber(options.CurrentValue) or minimum, minimum, maximum)
    value = math.clamp(minimum + math.floor(((value - minimum) / increment) + 0.5) * increment, minimum, maximum)
    local row = createRow(tab, "Slider", 58)
    createLabel(tab, row, options.Name or "Slider", 0.58)

    local valueLabel = make("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 5),
        Size = UDim2.fromOffset(90, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = tostring(value) .. (options.ValueName and (" " .. tostring(options.ValueName)) or ""),
        TextColor3 = tab.Window.Theme.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)

    local bar = make("TextButton", {
        Position = UDim2.new(0, 12, 0, 35),
        Size = UDim2.new(1, -24, 0, 8),
        BackgroundColor3 = tab.Window.Theme.SurfaceLight,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)
    local fill = make("Frame", {
        Size = UDim2.new((value - minimum) / (maximum - minimum), 0, 1, 0),
        BackgroundColor3 = tab.Window.Theme.Accent,
        BorderSizePixel = 0,
    }, bar)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)

    local function setValue(nextValue, fireCallback)
        value = math.clamp(tonumber(nextValue) or minimum, minimum, maximum)
        value = math.clamp(minimum + math.floor(((value - minimum) / increment) + 0.5) * increment, minimum, maximum)
        local precision = tonumber(options.DecimalPlaces)
        if precision then
            local factor = 10 ^ math.clamp(precision, 0, 5)
            value = math.floor(value * factor + 0.5) / factor
        end
        fill.Size = UDim2.new((value - minimum) / (maximum - minimum), 0, 1, 0)
        valueLabel.Text = tostring(value) .. (options.ValueName and (" " .. tostring(options.ValueName)) or "")
        if fireCallback and typeof(options.Callback) == "function" then
            options.Callback(value)
        end
    end

    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local function updateFromInput(input)
        local alpha = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        setValue(minimum + (maximum - minimum) * alpha, true)
    end
    bar.Activated:Connect(function()
        local mouse = UserInputService:GetMouseLocation()
        updateFromInput({ Position = mouse })
    end)
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)
    local changedConnection = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)
    local endedConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    table.insert(tab.Window.Connections, changedConnection)
    table.insert(tab.Window.Connections, endedConnection)

    return {
        Instance = row,
        Value = value,
        Get = function() return value end,
        Set = function(_, nextValue) setValue(nextValue, true) end,
    }
end

function Controls.CreateDropdown(tab, options)
    local choices = options.Options or {}
    local selected = options.CurrentOption
    if type(selected) == "table" then selected = selected[1] end
    if selected == nil then selected = choices[1] end

    local row = createRow(tab, "Dropdown", 46)
    createLabel(tab, row, options.Name or "Dropdown", 0.48)
    local button = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -9, 0, 8),
        Size = UDim2.new(0.5, -8, 0, 30),
        BackgroundColor3 = tab.Window.Theme.SurfaceLight,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = tostring(selected or "Select...") .. "  ▾",
        TextColor3 = tab.Window.Theme.Text,
        TextSize = 11,
        AutoButtonColor = true,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(0, 6) }, button)

    local menu = make("Frame", {
        Name = "Options",
        Position = UDim2.new(0, 0, 1, 5),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = tab.Window.Theme.Surface,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 5,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(0, 6) }, menu)
    make("UIStroke", { Color = tab.Window.Theme.Border, Thickness = 1 }, menu)
    local layout = make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, menu)
    local open = false

    local function choose(option)
        selected = option
        button.Text = tostring(option) .. "  ▾"
        menu.Visible = false
        row.Size = UDim2.new(1, 0, 0, 46)
        open = false
        if typeof(options.Callback) == "function" then
            options.Callback(option)
        end
    end

    local function rebuildOptions()
        for _, child in ipairs(menu:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for index, option in ipairs(choices) do
        local optionButton = make("TextButton", {
            LayoutOrder = index,
            Size = UDim2.new(1, -8, 0, 28),
            Position = UDim2.fromOffset(4, 0),
            BackgroundColor3 = tab.Window.Theme.SurfaceLight,
            BorderSizePixel = 0,
            Font = Enum.Font.Gotham,
            Text = tostring(option),
            TextColor3 = tab.Window.Theme.Text,
            TextSize = 11,
            ZIndex = 6,
        }, menu)
        optionButton.Activated:Connect(function()
            choose(option)
        end)
        end
        layout.Parent = menu
    end
    rebuildOptions()

    button.Activated:Connect(function()
        open = not open
        menu.Visible = open
        local menuHeight = math.min(#choices, 5) * 30 + 4
        menu.Size = UDim2.new(1, 0, 0, open and menuHeight or 0)
        row.Size = UDim2.new(1, 0, 0, open and (50 + menuHeight) or 46)
    end)

    return {
        Instance = row,
        Value = selected,
        Get = function() return selected end,
        Set = function(_, option)
            if table.find(choices, option) then
                selected = option
                button.Text = tostring(option) .. "  ▾"
                if typeof(options.Callback) == "function" then options.Callback(option) end
            end
        end,
        Refresh = function(_, nextOptions, deleteCurrent)
            choices = nextOptions or {}
            if deleteCurrent and not table.find(choices, selected) then
                selected = choices[1]
            end
            button.Text = tostring(selected or "Select...") .. "  ▾"
            rebuildOptions()
        end,
    }
end


function Controls.CreateLabel(tab, text)
    local label = make("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = tostring(text or "Label"),
        TextColor3 = tab.Window.Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, tab.Page)
    return {
        Instance = label,
        Set = function(_, value) label.Text = tostring(value or "") end,
        Get = function() return label.Text end,
    }
end

function Controls.CreateParagraph(tab, title, content)
    local row = createRow(tab, "Paragraph", 68)
    local heading = make("TextLabel", {
        Position = UDim2.fromOffset(12, 7),
        Size = UDim2.new(1, -24, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = tostring(title or "Paragraph"),
        TextColor3 = tab.Window.Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local body = make("TextLabel", {
        Position = UDim2.fromOffset(12, 27),
        Size = UDim2.new(1, -24, 0, 34),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = tostring(content or ""),
        TextColor3 = tab.Window.Theme.Muted,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, row)
    return {
        Instance = row,
        Set = function(_, newTitle, newContent)
            if newContent == nil then
                body.Text = tostring(newTitle or "")
            else
                heading.Text = tostring(newTitle or "")
                body.Text = tostring(newContent or "")
            end
        end,
    }
end

function Controls.CreateColorpicker(tab, options)
    local color = typeof(options.Default) == "Color3" and options.Default or Color3.fromRGB(120, 90, 255)
    local row = createRow(tab, "Colorpicker")
    createLabel(tab, row, options.Name or "Color")
    local preview = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -9, 0.5, 0),
        Size = UDim2.fromOffset(86, 28),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, row)
    make("UICorner", {CornerRadius = UDim.new(0, 6)}, preview)
    local editor = make("TextBox", {
        Position = UDim2.new(1, -190, 0.5, -14),
        Size = UDim2.fromOffset(94, 28),
        BackgroundColor3 = tab.Window.Theme.SurfaceLight,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderText = "#RRGGBB",
        Text = "",
        TextColor3 = tab.Window.Theme.Text,
        TextSize = 11,
    }, row)
    make("UICorner", {CornerRadius = UDim.new(0, 6)}, editor)
    local handle = {Instance = row, Value = color}
    function handle:Set(nextColor)
        if typeof(nextColor) == "Color3" then
            color = nextColor
            handle.Value = color
            preview.BackgroundColor3 = color
            if typeof(options.Callback) == "function" then options.Callback(color) end
        end
    end
    function handle:Get()
        return color
    end
    editor.FocusLost:Connect(function()
        local hex = editor.Text:gsub("#", "")
        if #hex == 6 and hex:match("^%x+$") then
            local r = tonumber(hex:sub(1, 2), 16)
            local g = tonumber(hex:sub(3, 4), 16)
            local b = tonumber(hex:sub(5, 6), 16)
            handle:Set(Color3.fromRGB(r, g, b))
        end
    end)
    preview.Activated:Connect(function()
        editor:CaptureFocus()
    end)
    return handle
end

function Controls.CreateKeybind(tab, options)
    local key = options.Default or Enum.KeyCode.E
    local row = createRow(tab, "Keybind")
    createLabel(tab, row, options.Name or "Keybind")
    local button = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -9, 0.5, 0),
        Size = UDim2.fromOffset(112, 28),
        BackgroundColor3 = tab.Window.Theme.SurfaceLight,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = key.Name,
        TextColor3 = tab.Window.Theme.Text,
        TextSize = 11,
    }, row)
    make("UICorner", {CornerRadius = UDim.new(0, 6)}, button)
    local listening = false
    button.Activated:Connect(function()
        listening = true
        button.Text = "Press a key..."
    end)
    local userInput = game:GetService("UserInputService")
    local isHeld = false
    local beganConnection = userInput.InputBegan:Connect(function(input, processed)
        if listening then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                key = input.KeyCode
                button.Text = key.Name
                listening = false
            end
        elseif not processed and input.KeyCode == key then
            if options.Hold == true then
                isHeld = true
                if typeof(options.Callback) == "function" then options.Callback(true) end
            elseif typeof(options.Callback) == "function" then
                options.Callback()
            end
        end
    end)
    local endedConnection = userInput.InputEnded:Connect(function(input)
        if options.Hold == true and input.KeyCode == key and isHeld then
            isHeld = false
            if typeof(options.Callback) == "function" then options.Callback(false) end
        end
    end)
    table.insert(tab.Window.Connections, beganConnection)
    table.insert(tab.Window.Connections, endedConnection)
    local handle = {Instance = row, Type = "Bind", Value = key}
    function handle:Set(nextKey)
        if typeof(nextKey) == "EnumItem" and nextKey.EnumType == Enum.KeyCode then
            key = nextKey
            handle.Value = key
            button.Text = key.Name
        end
    end
    function handle:Get()
        return key
    end
    function handle:Destroy()
        beganConnection:Disconnect()
        endedConnection:Disconnect()
        row:Destroy()
    end
    return handle
end


    return Controls
end
local Controls = buildControls()

local function buildTab(Controls)
-- OrbitUI tab implementation


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
end
local Tab = buildTab(Controls)

local function buildWindow(Tab)
-- OrbitUI window implementation


local Window = {}
Window.__index = Window

local DEFAULT_THEME = {
    Background = Color3.fromRGB(15, 15, 18),
    Surface = Color3.fromRGB(23, 23, 28),
    SurfaceLight = Color3.fromRGB(32, 32, 39),
    Text = Color3.fromRGB(242, 242, 247),
    Muted = Color3.fromRGB(155, 155, 168),
    Accent = Color3.fromRGB(120, 90, 255),
    Border = Color3.fromRGB(48, 48, 58),
}

local function make(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function resolveTheme(custom)
    local theme = {}
    for key, value in pairs(DEFAULT_THEME) do
        theme[key] = value
    end
    for key, value in pairs(custom or {}) do
        if theme[key] ~= nil then
            theme[key] = value
        end
    end
    return theme
end

function Window.new(options)
    local self = setmetatable({}, Window)
    self.Tabs = {}
    self.Connections = {}
    self.Flags = {}
    self.Config = options
    self.Initialized = false
    self.Theme = resolveTheme(options.Theme)

    local player = game:GetService("Players").LocalPlayer
    assert(player, "OrbitUI windows must be created from a client LocalScript")

    local gui = make("ScreenGui", {
        Name = options.GuiName or "OrbitUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, player:WaitForChild("PlayerGui"))
    self.Gui = gui

    local root = make("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(options.Width or 620, options.Height or 420),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false,
    }, gui)
    self.Root = root
    make("UICorner", { CornerRadius = UDim.new(0, 10) }, root)
    make("UIStroke", { Color = self.Theme.Border, Thickness = 1 }, root)

    local top = make("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
    }, root)
    make("UICorner", { CornerRadius = UDim.new(0, 10) }, top)

    make("TextLabel", {
        Name = "Title",
        Position = UDim2.fromOffset(18, 7),
        Size = UDim2.new(1, -76, 0, 23),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = options.Name or "OrbitUI",
        TextColor3 = self.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, top)

    make("TextLabel", {
        Name = "Subtitle",
        Position = UDim2.fromOffset(18, 29),
        Size = UDim2.new(1, -76, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = options.Subtitle or options.LoadingTitle or "Interface library",
        TextColor3 = self.Theme.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, top)

    local close = make("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 10),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = self.Theme.SurfaceLight,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = self.Theme.Text,
        TextSize = 20,
        AutoButtonColor = true,
    }, top)
    make("UICorner", { CornerRadius = UDim.new(0, 6) }, close)
    close.Activated:Connect(function()
        if typeof(options.CloseCallback) == "function" then
            options.CloseCallback()
        end
        self:Destroy()
    end)

    local sidebar = make("ScrollingFrame", {
        Name = "Tabs",
        Position = UDim2.fromOffset(12, 66),
        Size = UDim2.new(0, 145, 1, -78),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, root)
    make("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, sidebar)
    self.Sidebar = sidebar

    local content = make("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(169, 66),
        Size = UDim2.new(1, -181, 1, -78),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
    }, root)
    make("UICorner", { CornerRadius = UDim.new(0, 8) }, content)
    self.Content = content

    -- Drag the window from its title bar.
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPosition
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    local dragConnection = UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)
    table.insert(self.Connections, dragConnection)

    return self
end

function Window:CreateTab(name)
    local tab = Tab.new(self, name)
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        tab:Show()
    end
    return tab
end

function Window:MakeTab(config)
    config = config or {}
    return self:CreateTab(config.Name or "Tab")
end

function Window:Notify(options)
    options = options or {}
    local toast = make("Frame", {
        Name = "Notification",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -18, 1, -18),
        Size = UDim2.fromOffset(280, 76),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 20,
    }, self.Gui)
    make("UICorner", { CornerRadius = UDim.new(0, 8) }, toast)
    make("UIStroke", { Color = self.Theme.Border, Thickness = 1 }, toast)
    make("TextLabel", {
        Position = UDim2.fromOffset(12, 8),
        Size = UDim2.new(1, -24, 0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = tostring(options.Title or "OrbitUI"),
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 21,
    }, toast)
    make("TextLabel", {
        Position = UDim2.fromOffset(12, 32),
        Size = UDim2.new(1, -24, 0, 34),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = tostring(options.Content or options.Description or ""),
        TextColor3 = self.Theme.Muted,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 21,
    }, toast)
    task.delay(tonumber(options.Duration or options.Time) or 4, function()
        if toast.Parent then
            toast:Destroy()
        end
    end)
    return toast
end

function Window:MakeNotification(options)
    return self:Notify(options)
end

function Window:Init()
    self.Initialized = true
    return self
end

function Window:Destroy()
    for _, connection in ipairs(self.Connections or {}) do
        if connection.Connected then connection:Disconnect() end
    end
    self.Connections = {}
    if self.Gui then
        self.Gui:Destroy()
        self.Gui = nil
    end
end


    return Window
end
local Window = buildWindow(Tab)

local function buildOrbitUI(Window)
-- OrbitUI public entry point
-- UI-only library for authorized Roblox experiences.


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
end
return buildOrbitUI(Window)