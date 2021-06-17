local RunService = game:GetService("RunService")

local function main()
	local Sync = require(script.Parent.Sync)

	local toolbar = plugin:CreateToolbar("RBXCode")
	Sync:init(plugin, toolbar)
end

if RunService:IsEdit() then
	main()
end