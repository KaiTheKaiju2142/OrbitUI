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
        Set = function(_, value) setValue(value, false) end,
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
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        Instance = row,
        Value = value,
        Get = function() return value end,
        Set = function(_, nextValue) setValue(nextValue, false) end,
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

return Controls
