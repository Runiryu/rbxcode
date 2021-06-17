local Path = {}

function Path.getPath(instance: Instance): string
	return string.gsub(instance:GetFullName(), "%.", "/")
end

function Path.getInstanceFromPath(path: string): Instance
	local endPos = (string.find(path, "%.") or #path + 1) - 1
	path = string.sub(path, 1, endPos)
	local items = string.split(path, "\\")
	table.remove(items, 1)
	local serviceName = table.remove(items, 1)
	local current = game:GetService(serviceName)

	for _, item in ipairs(items) do
		if current and current:FindFirstChild(item) then
			current = current[item]
		end
	end
	
	if current and current.Name ~= items[#items] and items[#items] ~= "init" then
		current = nil
	end

	return current
end

return Path
