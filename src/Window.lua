-- OrbitUI window implementation

local Tab = require(script.Parent.Tab)

local Window = {}
Window.__index = Window

local COLORS = {
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

function Window.new(options)
    local self = setmetatable({}, Window)
    self.Tabs = {}
    self.Theme = options.Theme or COLORS

    local player = game:GetService("Players").LocalPlayer
    assert(player, "OrbitUI windows must be created from a LocalScript")

    local gui = make("ScreenGui", {
        Name = "OrbitUI",
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
        Size = UDim2.new(1, -36, 0, 23),
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
        Size = UDim2.new(1, -36, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = options.Subtitle or "Interface library",
        TextColor3 = self.Theme.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, top)

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

function Window:Destroy()
    if self.Gui then
        self.Gui:Destroy()
        self.Gui = nil
    end
end

return Window
