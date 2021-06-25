local Component = require(script.Parent.Parent.Lib.Component)
local styles = require(script.Parent.Parent.Styles.styles)
local class = require(script.Parent.Parent.Lib.class)

local TextBox = class("TextBox"):extends(Component)

function TextBox.new(name: string, options: {[string]: any?})
	options = options or {}

	local self = TextBox(script.GuiObject, name)

	self.connections["Focused"] = self.instance.Focused:Connect(function()
		self:addStyle(styles.input.selected, "selected")
	end)

	self.connections["FocusLost"] = self.instance.FocusLost:Connect(function()
		self:removeStyle("selected")
	end)

	return self
end

function TextBox:getText()
	return self.instance.Text
end

function TextBox:setText(value: string)
	self.instance.Text = value
end

return TextBox
