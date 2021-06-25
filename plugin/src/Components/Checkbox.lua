local Component = require(script.Parent.Parent.Lib.Component)
local styles = require(script.Parent.Parent.Styles.styles)
local class = require(script.Parent.Parent.Lib.class)

local Checkbox = class("Checkbox"):extends(Component)

function Checkbox.new(name: string, options: {[string]: any?})
	options = options or {}

	local self = Checkbox(script.GuiObject, name)
	self:setValue(false)

	return self
end

function Checkbox:getValue()
	return self._value
end

function Checkbox:setValue(value: boolean)
	self._value = value
	self.instance.Text = value and "✓" or ""
end

function Checkbox:toggle()
	self.value = not self.value
end

return Checkbox
