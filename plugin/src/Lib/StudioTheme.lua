local syncConnections = {}

local StudioTheme = {}

function StudioTheme.getColor(styleGuideItem: Enum.StudioStyleGuideColor, modifier: Enum.StudioStyleGuideModifier?)
	return settings().Studio.Theme:GetColor(styleGuideItem, modifier)
end

function StudioTheme.setColor(guiObject: GuiObject, styleGuideItem: Enum.StudioStyleGuideColor?,
		modifier: Enum.StudioStyleGuideModifier?)
	if guiObject:IsA("Frame") or guiObject:IsA("ScrollingFrame") then
		guiObject.BackgroundColor3 = StudioTheme.getColor(
			styleGuideItem or Enum.StudioStyleGuideColor.MainBackground, 
			modifier
		)
	elseif guiObject:IsA("ImageButton") then
		guiObject.BackgroundColor3 = StudioTheme.getColor(
			styleGuideItem or Enum.StudioStyleGuideColor.Button, 
			modifier
		)
		guiObject.ImageColor3 = StudioTheme.getColor(
			styleGuideItem or Enum.StudioStyleGuideColor.Button, 
			modifier
		)
	elseif guiObject:IsA("TextLabel") then
		guiObject.TextColor3 = StudioTheme.getColor(
			styleGuideItem or Enum.StudioStyleGuideColor.MainText, 
			modifier
		)
	end
end

function StudioTheme.syncColor(guiObject: GuiObject, styleGuideItem: Enum.StudioStyleGuideColor?,
		modifier: Enum.StudioStyleGuideModifier?)
	StudioTheme.setColor(guiObject, styleGuideItem, modifier)

	if syncConnections[guiObject] then
		syncConnections[guiObject]:Disconnect()
	end

	syncConnections[guiObject] = settings().Studio.ThemeChanged:Connect(function()
		StudioTheme.setColor(guiObject, styleGuideItem, modifier)
	end)
end

function StudioTheme.syncDescendantsColor(guiObject: GuiObject)
	StudioTheme.syncColor(guiObject)

	for _, descendant in ipairs(guiObject:GetDescendants()) do
		StudioTheme.syncColor(descendant)
	end
end

return StudioTheme
