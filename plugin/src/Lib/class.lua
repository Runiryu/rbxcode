local Class = {}
Class.__index = function(t, k)
	if rawget(t, "className") then 
		return rawget(Class, k)
	end
end
Class.__call = function(t, ...)
	local instance
	if t._parent then
		instance = t._parent.new(...)
	else
		instance = {}
	end
	setmetatable(instance, t)

	return instance
end

function Class.new(className: string): Class
	local self = {}
	
	self.__index = function(t, k)
		if rawget(self, k) then
			return rawget(self, k)
		else
			local getter = rawget(self, "get" .. string.upper(string.sub(k, 1, 1)) .. string.sub(k, 2))

			if getter then
				return getter(t)
			elseif self._parent then
				if typeof(self._parent.__index) == "function" then
					return self._parent.__index(t, k)
				else
					return self._parent[k]
				end
			end
		end
	end
	
	self.__newindex = function(t, k, v)
		local setter = rawget(self, "set" .. string.upper(string.sub(k, 1, 1)) .. string.sub(k, 2))

		if setter then
			setter(t, v)
		else
			rawset(t, k, v)
		end
	end
	
	setmetatable(self, Class)
	
	self.className = className
	
	return self
end

function Class:extends(parent: Class): Class
	self._parent = parent
	
	return self
end

export type Class = typeof(Class.new(""))

return Class.new
