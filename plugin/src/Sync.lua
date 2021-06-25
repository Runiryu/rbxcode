local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")

local View = require(script.Parent.View)
local ChangeWatcher = require(script.Parent.ChangeWatcher)
local Path = require(script.Parent.Path)

local services = {
	Workspace = game:GetService("Workspace"),
	ReplicatedFirst = game:GetService("ReplicatedFirst"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	ServerStorage = game:GetService("ServerStorage"),
	ServerScriptService = game:GetService("ServerScriptService"),
	StarterGui = game:GetService("StarterGui"),
	StarterPack = game:GetService("StarterPack"),
	StarterPlayer = game:GetService("StarterPlayer")
}
local SYNC_INTERVAL = 2

local plugin

local Sync = {
	connected = false,
	instanceId = HttpService:GenerateGUID(false)
}

function Sync:init(_plugin: Plugin, _toolbar: PluginToolbar)
	plugin = _plugin
	
	View:init(self, _plugin, _toolbar)
	
	for name, service in pairs(services) do
		for _, descendant in ipairs(service:GetDescendants()) do
			if not descendant:IsA("BasePart") then
				ChangeWatcher:watch(descendant)
			end
		end

		service.DescendantAdded:Connect(function(descendant)
			if descendant:IsA("LuaSourceContainer") then
				table.insert(ChangeWatcher.changes, {
					change = "Added",
					path = Path.getPath(descendant),
					className = descendant.ClassName,
					content = descendant.Source
				})
			end
			
			if not descendant:IsA("BasePart") and not ChangeWatcher.connections[descendant] then
				ChangeWatcher:watch(descendant)
			end
		end)

		service.DescendantRemoving:Connect(function(descendant)
			table.insert(ChangeWatcher.changes, {
				change = "Removed",
				path = Path.getPath(descendant),
				className = descendant.ClassName,
				content = nil
			})
			
			--ChangeWatcher:unwatch(descendant)
		end)
	end

	Sync:_startPolling()
	
	StudioService:GetPropertyChangedSignal("ActiveScript"):Connect(function()
		if self.connected and StudioService.ActiveScript then
			self:requestAsync({
				Url = "http://localhost:3000/open",
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json"
				},
				Body = HttpService:JSONEncode({
					path = Path.getPath(StudioService.ActiveScript),
					className = StudioService.ActiveScript.ClassName
				})
			})
		end
	end)
end

function Sync:requestAsync(options: {[string]: any}): string | {[string]: any} | nil
	options.Headers["Instance-ID"] = self.instanceId
	
	local success, response = pcall(function()
		return HttpService:RequestAsync(options)
	end)

	return success and response or nil
end

function Sync:connect()
	local scripts = {}
	for name, service in pairs(services) do
		for _, descendant in ipairs(service:GetDescendants()) do
			if descendant:IsA("LuaSourceContainer") then
				table.insert(scripts, {
					path = Path.getPath(descendant), 
					className = descendant.ClassName, 
					content = descendant.Source
				})	
			end
		end
	end

	local response = self:requestAsync({
		Url = "http://localhost:3000/init",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode(scripts)
	})

	if response then
		ChangeWatcher.changes = {}
		self.connected = true
		View:update()
	end
end

function Sync:disconnect()
	self.connected = false
	View:update()
end

function Sync:_startPolling()
	coroutine.wrap(function()
		while true do
			wait(SYNC_INTERVAL)
			
			if not self.connected then
				continue
			end

			local response = self:requestAsync({
				Url = "http://localhost:3000/update",
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json"
				},
				Body = HttpService:JSONEncode(ChangeWatcher.changes)
			})

			if response then
				if response.Body == "" then
					self:disconnect()
					continue
				end
				
				local incomingChanges = HttpService:JSONDecode(response.Body)
				
				for _, change in ipairs(incomingChanges) do
					if change.change == "Edited" then
						local sourceContainer = Path.getInstanceFromPath(change.path)
						
						if sourceContainer and sourceContainer:IsA("LuaSourceContainer") then
							if ChangeWatcher.ignored[sourceContainer] then
								ChangeWatcher.ignored[sourceContainer] += 1
							else
								ChangeWatcher.ignored[sourceContainer] = 1
							end
							
							sourceContainer.Source = change.content
						end
					end
				end

				ChangeWatcher.changes = {}
			else
				self:disconnect()
			end
		end
	end)()
end

return Sync
