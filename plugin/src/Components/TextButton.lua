local Component = require(script.Parent.Parent.Lib.Component)
local class = require(script.Parent.Parent.Lib.class)

local TextButton = class("TextButton"):extends(Component)

function TextButton.new(name: string, options: {[string]: any?})
	options = options or {}
	
	local self = TextButton(script.GuiObject, name)
	self.text = options.text or "Label"
	
	return self
end

function TextButton:getText(): string
	return self.instance.Text
end

function TextButton:setText(text: string)
	self.instance.Text = text
end

export type TextButton = typeof(TextButton.new(""))

return TextButton
