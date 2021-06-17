local Map = {}
Map.__index = Map

function Map.new(array: Array?): Map
	local self = {}
	setmetatable(self, Map)
	
	self._list = {} 
	self._dictionary = {}
	
	if array then
		for i, pair in ipairs(array) do
			table.insert(self._list, pair)
			self._dictionary[pair[1]] = pair[2]
		end
	end
	
	return self
end

function Map:get(key)
	return self._dictionary[key]
end

function Map:set(key, value)
	if self._dictionary[key] then
		self:delete(key)
	end
	
	table.insert(self._list, {key, value})
	self._dictionary[key] = value
end

function Map:delete(key)
	for i, element in ipairs(self._list) do
		if element[1] == key then
			table.remove(self._list, i)
			break
		end
	end
	
	self._dictionary[key] = nil
end

function Map:keys()
	local keys = {}
	
	for i, element in ipairs(self._list) do
		table.insert(keys, element[1])
	end
	
	return keys
end

function Map:values()
	local values = {}
	
	for i, element in ipairs(self._list) do
		table.insert(values, element[2])
	end
	
	return values
end

function Map:size()
	return #self._list
end

export type Map = typeof(Map.new({}))
type Array = {any}

return Map
