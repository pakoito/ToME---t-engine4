require "engine.class"

--- Define a level
module(..., package.seeall, class.make)

--- Initializes the level with a "level" and a map
function _M:init(level, map)
	self.level = level
	self.map = map
	self.e_array = {}
	self.entities = {}
	-- This stores the distance for each actors to each other actors
	-- this is computed by either the "distancer" coroutine or manualy when needed if not available
	self.e_distances = {}

	self.distancer_co = self:createDistancer()
end

--- Adds an entity to the level
-- Only entities that need to act need to be added. Terrain features do not need this usualy
function _M:addEntity(e)
	if self.entities[e.uid] then error("Entity "..e.uid.." already present on the level") end
	self.entities[e.uid] = e
	table.insert(self.e_array, e)
end

--- Removes an entity from the level
function _M:removeEntity(e)
	if not self.entities[e.uid] then error("Entity "..e.uid.." not present on the level") end
	self.entities[e.uid] = nil
	for i = 1, #self.e_array do
		if self.e_array[i] == e then
			table.remove(self.e_array, i)
			break
		end
	end
	-- Tells it to delete itself if needed
	if e.deleteFromMap then e:deleteFromMap(self.map) end
end

--- Is the entity on the level?
function _M:hasEntity(e)
	return self.entities[e.uid]
end

--- Serialization
function _M:save()
	return class.save(self, {
		-- cant save a thread
		distancer_co = true,
		-- dont save the distances table either it will be recomputed on the fly
		e_distances = true,
	})
end
function _M:loaded()
	-- Loading the game has defined new uids for entities, yet we hard referenced the old ones
	-- So we fix it
	local nes = {}
	for uid, e in pairs(self.entities) do
		nes[e.uid] = e
	end
	self.entities = nes

	self.distancer_co = self:createDistancer()
end

--- Creates the distancer coroutine
-- The "distancer" is a coroutine that can be called everytime the game has nothing to do
-- it will compute distance and LOS between all actors and sort them by distance.<br/>
-- This will speed up AI code as it uses unused CPU cycles. The distancer
-- will be called by Game tick() method when there is not much to do (like when waiting
-- for player input)
function _M:createDistancer()
	local co = coroutine.create(function()
		-- Infinite coroutine
		while true do
			local arr = self.e_array
			for i = 1, #arr do
				local e = arr[i]
				if e then
					self:computeDistances(e)
--					print("distancer ran for", i, e.uid)
					coroutine.yield()
				end
			end
		end
	end)
	return co
end

local dist_sort = function(a, b) return a.dist < b.dist end

--- Compute distances to all other actors
function _M:computeDistances(e)
	local arr = self.e_array
	self.e_distances[e.uid] = {}
	for j = 1, #arr do
		local dst = arr[j]
		if dst ~= e then
			table.insert(self.e_distances[e.uid], {uid=dst.uid, dist=core.fov.distance(e.x, e.y, dst.x, dst.y)})
		end
	end
	table.sort(self.e_distances[e.uid], dist_sort)
end

--- Get distances to all other actors
-- This eithers computes directly if not available or use data from the distancer coroutine
function _M:getDistances(e)
--	if not self.e_distances[e.uid] then self:computeDistances(e) end
	return self.e_distances[e.uid]
end
