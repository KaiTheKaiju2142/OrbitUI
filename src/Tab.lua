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

function Tab:CreateButton(options)
    return Controls.CreateButton(self, options or {})
end

function Tab:CreateToggle(options)
    return Controls.CreateToggle(self, options or {})
end

function Tab:CreateInput(options)
    return Controls.CreateInput(self, options or {})
end

return Tab
