local StudioTheme = require(script.Parent.Parent.Lib.StudioTheme)

local function themeColor(styleGuideItem: Enum.StudioStyleGuideColor, modifier: Enum.StudioStyleGuideModifier?)
	return function()
		return StudioTheme.getColor(styleGuideItem, modifier)
	end
end

local styles = {
	default = {
		BackgroundTransparency = 0
	},

	mainFrame = {
		BackgroundColor3 = themeColor(Enum.StudioStyleGuideColor.MainBackground),
		BorderColor3 = themeColor(Enum.StudioStyleGuideColor.Border),
		BorderSizePixel = 1,

		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 1, -2)
	},

	label = {
		BackgroundColor3 = themeColor(Enum.StudioStyleGuideColor.Tab),
		BackgroundTransparency = 1,

		Font = Enum.Font.SourceSans,
		TextColor3 = themeColor(Enum.StudioStyleGuideColor.MainText),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd
	},

	input = {
		BackgroundColor3 = themeColor(Enum.StudioStyleGuideColor.InputFieldBackground),
		TextColor3 = themeColor(Enum.StudioStyleGuideColor.MainText),
		PlaceholderColor3 = themeColor(Enum.StudioStyleGuideColor.MainText, Enum.StudioStyleGuideModifier.Disabled),

		hover = {
			UIStroke = {
				Color = themeColor(Enum.StudioStyleGuideColor.InputFieldBorder, Enum.StudioStyleGuideModifier.Hover)
			}
		},

		selected = {
			UIStroke = {
				Color = themeColor(Enum.StudioStyleGuideColor.InputFieldBorder, Enum.StudioStyleGuideModifier.Selected)
			}
		},

		UIStroke = {
			Color = themeColor(Enum.StudioStyleGuideColor.InputFieldBorder)
		}
	},
	
	button = {
		BackgroundColor3 = themeColor(Enum.StudioStyleGuideColor.Button),
		TextColor3 = themeColor(Enum.StudioStyleGuideColor.MainText),
		
		hover = {
			BackgroundColor3 = themeColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Hover),
		},
		
		pressed = {
			BackgroundColor3 = themeColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Pressed),
		},
		
		UIStroke = {
			Color = themeColor(Enum.StudioStyleGuideColor.ButtonBorder)
		}
	},
	
	connected = {
		BackgroundColor3 = Color3.fromRGB(50, 200, 50),
		TextColor3 = Color3.fromRGB(27, 27, 27)
	}
}

return styles
