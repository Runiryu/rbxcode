local Path = require(script.Parent.Path)

local ChangeWatcher = {
	changes = {},
	ignored = {},
	connections = {}
}

function ChangeWatcher:watch(instance: Instance)
	local currentPath = Path.getPath(instance)
	self.connections[instance] = {}

	self.connections[instance]["Renamed"] = instance:GetPropertyChangedSignal("Name"):Connect(function()
		local newPath = Path.getPath(instance)

		if instance:IsA("LuaSourceContainer") or instance:FindFirstChildWhichIsA("LuaSourceContainer", true) then
			local change = {
				change = "Renamed",
				path = currentPath,
				newPath = newPath,
				className = instance.ClassName
			}

			if instance:IsA("LuaSourceContainer") then
				change.content = instance.Source
			end

			table.insert(self.changes, change)
		end

		currentPath = newPath
	end)

	self.connections[instance]["Moved"] = instance.AncestryChanged:Connect(function(child, parent)
		local newPath = Path.getPath(instance)

		if (instance:IsA("LuaSourceContainer") 
			or instance:FindFirstChildWhichIsA("LuaSourceContainer", true))
			and instance == child
			and string.split(currentPath, "/")[1] == string.split(newPath, "/")[1]
			and newPath ~= currentPath
		then
			local change = {
				change = "Moved",
				path = currentPath,
				newPath = newPath,
				className = instance.ClassName
			}

			if instance:IsA("LuaSourceContainer") then
				change.content = instance.Source
			end

			table.insert(self.changes, change)
		end

		currentPath = newPath
	end)

	if instance:IsA("LuaSourceContainer") then
		local lastChangeTime = 0
		
		self.connections[instance]["Edited"] = instance:GetPropertyChangedSignal("Source"):Connect(function()
			if os.clock() - lastChangeTime < 0.05 then 
				return 
			end
			
			local changeTime = os.clock()
			lastChangeTime = changeTime

			if self.ignored[instance] and self.ignored[instance] > 0 then
				self.ignored[instance] -= 1
				return
			end

			delay(0.5, function()
				if changeTime == lastChangeTime then
					table.insert(self.changes, {
						change = "Edited",
						path = Path.getPath(instance),
						className = instance.ClassName,
						content = instance.Source
					})
					
				end
			end)
		end)
	end
end

function ChangeWatcher:unwatch(instance: Instance)
	if not self.connections[instance] then return end

	for _, connection in pairs(self.connections[instance]) do
		connection:Disconnect()
	end

	self.connections[instance] = nil
end

return ChangeWatcher
