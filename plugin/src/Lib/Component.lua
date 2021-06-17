local ObjectPool = require(script.Parent.ObjectPool)
local Map = require(script.Parent.Map)
local class = require(script.Parent.class)
local styles = require(script.Parent.Parent.Styles.styles)

local components = {}
local cache = {}

local inheritedProperties = {
	BackgroundColor3 = true,
	RichText = true,
	TextColor3 = true,
	Font = true,
	TextTransparency = true,
	TextSize = true,
	TextScaled = true,
	TextWrapped = true,
	TextXAlignment = true,
	TextYAlignment = true,
	TextTruncate = true
}

local function applyStyle(guiObject: GuiObject, style: Style, inherited: boolean?)
	for key, value in pairs(style) do
		local success, err = pcall(function()
			if not inherited or inheritedProperties[key] then
				if typeof(value) == "function" then
					guiObject[key] = value()
				else
					guiObject[key] = value
				end
			end
		end)
	end
end

local Component = class("Component")

function Component.new(class: string | Instance, name: string?): Component
	local self = Component()

	if typeof(class) == "string" then
		if not cache[class] then
			cache[class] = Instance.new(class)
		end

		self.instance = ObjectPool.getObject(cache[class])
		self.template = cache[class]
	else
		self.instance = ObjectPool.getObject(class)
		self.template = class
	end

	self.instance.Name = name or self.instance.Name
	self.children = {}
	self.styles = Map.new()
	self.connections = {}

	applyStyle(self.instance, styles.default)

	components[self.instance] = self

	return self
end

function Component.getComponent(instance: Instance): Component
	return components[instance]
end

function Component:addChild(component: Component)
	if component.parent then
		component.parent:removeChild(component)
	end

	table.insert(self.children, component)
	component.parent = self
	component.instance.Parent = self.instance

	component:refresh()
end

function Component:removeChild(component: Component)
	for i, child in ipairs(self.children) do
		if child == component then
			table.remove(self.children, i)
			component.parent = nil
			break
		end
	end
end

function Component:destroy()
	components[self.instance] = nil
	ObjectPool.returnObject(self.instance, self.template)

	if self.parent then
		self.parent:removeChild(self)
	end

	for k, connection in pairs(self.connections) do
		connection:Disconnect()
		self.connections[k] = nil
	end

	while #self.children > 0 do
		self.children[1]:destroy()
	end

	for i, child in ipairs(self.instance:GetChildren()) do
		if not Component.getComponent(child) then
			child:Destroy()
		end
	end

	self.instance = nil
	self.template = nil
	self.parent = nil
	self.children = nil
	self.styles = nil
end

function Component:addStyle(style: Style, name: string?)
	name = name or tostring(style)
	
	self.styles:set(name, style)
	self:refresh()
	
	if style.hover or style.pressed 
		and not self.connections["InputBegan"] 
		and not self.connections["InputEnded"] 
	then
		self:_connectInputEvents()
	end
end

function Component:removeStyle(name: string)
	self.styles:delete(name)
end

function Component:refresh()
	local inheritedStyles = {}
	local current = self.parent
	
	while current do
		for i, style in ipairs(current.styles:values()) do
			table.insert(inheritedStyles, i, style)
		end
		current = current.parent
	end

	self:_refresh(inheritedStyles)
end

function Component:_refresh(inheritedStyles: {Style})
	local function applyToComponent(style, inherited)
		applyStyle(self.instance, style, inherited)

		if self.state == "Hover" and style.hover then
			applyStyle(self.instance, style.hover)
		elseif self.state == "Pressed" and style.pressed then
			applyStyle(self.instance, style.pressed)
		end
		
		for _, child in ipairs(self.instance:GetChildren()) do
			if style[child.ClassName] then
				applyStyle(child, style[child.ClassName])
			end
			
			if style[child.Name] then
				applyStyle(child, style[child.Name])
			end
		end
	end
	
	local function applyToComponentPart(part, inheritedStyles)
		for _, style in ipairs(inheritedStyles) do
			applyStyle(part, style, true)
		end
		
		for _, child in ipairs(part:GetChildren()) do
			if child:IsA("GuiObject") then
				applyToComponentPart(child, inheritedStyles)
			end
		end
	end
	
	for _, style in ipairs(inheritedStyles) do
		applyToComponent(style, true)
	end

	for _, style in ipairs(self.styles:values()) do
		applyToComponent(style)
		table.insert(inheritedStyles, style)
	end
	
	for _, child in ipairs(self.instance:GetChildren()) do
		local component = Component.getComponent(child)
		
		if component then
			component:_refresh(inheritedStyles)
		elseif child:IsA("GuiObject") then
			applyToComponentPart(child, inheritedStyles)
		end
	end
end

function Component:_connectInputEvents()
	self.connections["InputBegan"] = self.instance.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self.state = "Hover"
			self:refresh()
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.state = "Pressed"
			self:refresh()
		end
	end)

	self.connections["InputEnded"] = self.instance.InputEnded:Connect(function(input)
		self.state = "Default"
		self:refresh()
	end)
end

export type Component = typeof(Component.new(""))
export type Style = {[string]: any}

return Component
