-- OrbitUI window implementation

local Tab = require(script.Parent.Tab)

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
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)

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
    if self.Gui then
        self.Gui:Destroy()
        self.Gui = nil
    end
end

return Window
