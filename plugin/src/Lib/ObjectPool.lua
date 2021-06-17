local MAX_COPIES_PER_POOL = 10000

local pools = {}

local ObjectPool = {}

function ObjectPool.getObject(template)
	local pool = pools[template]
	
	if not pool then
		pools[template] = {}
		pool = pools[template]
	end
	
	if #pool > 0 then
		return table.remove(pool, #pool), true
	else
		return template:Clone(), false
	end
end

function ObjectPool.returnObject(instance, template)
	local pool = pools[template]

	if not pool then
		pools[template] = {}
		pool = pools[template]
	end
	
	for i, descendant in ipairs(instance:GetDescendants()) do
		if descendant:IsA("ModuleScript") then
			descendant:Clone().Parent = instance
			descendant:Destroy()
		elseif descendant:IsA("Animator") then
			for i, animTrack in ipairs(descendant:GetPlayingAnimationTracks()) do
				animTrack:Stop()
			end
		end
	end
	
	if #pool < MAX_COPIES_PER_POOL then
		table.insert(pool, instance)
		instance.Parent = nil
	else
		instance:Destroy()
	end
end

function ObjectPool.clearPool(template)
	local pool = pools[template]
	
	if pool then
		for i, object in ipairs(pool) do
			object:Destroy()
		end
		
		pools[template] = nil
	end
end

return ObjectPool
