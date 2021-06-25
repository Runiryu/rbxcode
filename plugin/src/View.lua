local Component = require(script.Parent.Lib.Component)
local TextBox = require(script.Parent.Components.TextBox)
local TextButton = require(script.Parent.Components.TextButton)
local styles = require(script.Parent.Styles.styles)

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Left, false, false,
	200, 200, 150, 150
)

local controller
local plugin

local View = {
	button = nil,
	widget = nil,
}

function View:init(_controller, _plugin: Plugin, _toolbar: PluginToolbar)
	controller = _controller
	plugin = _plugin

	self:createButton(_toolbar)
	self:createWidget()
end

function View:createButton(toolbar: PluginToolbar)
	self.button = toolbar:CreateButton("Open", "Open RBXCode", "", "Open")
	self.button.ClickableWhenViewportHidden = true

	if self.widget then
		self.button:SetActive(self.widget.Enabled)
	end

	self.button.Click:Connect(function()
		self.widget.Enabled = not self.widget.Enabled
		self.button:SetActive(self.widget.Enabled)
	end)
end

function View:createWidget()
	self.widget = plugin:CreateDockWidgetPluginGui("RBXCode", widgetInfo)
	self.widget.Title = "RBXCode"

	if self.button then
		self.button:SetActive(self.widget.Enabled)
	end

	self.widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		self.button:SetActive(self.widget.Enabled)
	end)

	local frame = Component.new("Frame")
	frame:addStyle(styles.mainFrame, "mainFrame")
	frame.instance.Parent = self.widget

	local portTextBox = TextBox.new("PortTextBox")
	portTextBox:addStyle(styles.input, "input")
	portTextBox.instance.AnchorPoint = Vector2.new(0, 0)
	portTextBox.instance.Size = UDim2.new(1, -110, 0, 30)
	portTextBox.instance.Position = UDim2.new(0, 10, 0, 10)
	portTextBox.text = plugin:GetSetting("Port")
	frame:addChild(portTextBox)
	
	local connectButton = TextButton.new("ConnectButton", {text = "Connect"})
	connectButton:addStyle(styles.button, "button")
	connectButton.instance.AnchorPoint = Vector2.new(1, 0)
	connectButton.instance.Position = UDim2.new(1, -10, 0, 10)
	frame:addChild(connectButton)
	
	connectButton.instance.MouseButton1Click:Connect(function()
		if not controller.connected then
			local port = tonumber(portTextBox.text)
			if port then
				controller:connect(port)
				plugin:SetSetting("Port", port)
			end
		else
			controller:disconnect()
		end
	end)
	
	settings().Studio.ThemeChanged:Connect(function()
		frame:refresh()
	end)
end

function View:update()
	local connectButton = Component.getComponent(self.widget.Frame.ConnectButton)

	if controller.connected then
		connectButton.text = "Connected"
		connectButton:addStyle(styles.connected, "connected")
	else
		connectButton.text = "Connect"
		connectButton:removeStyle("connected")
	end
end


return View

