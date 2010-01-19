require "engine.class"
local Map = require "engine.Map"

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
	self.e_toprocess = {}
	self.e_distances = {}

	self.distancer_co = self:createDistancer()

	self.entities_list = {}
end

--- Adds an entity to the level
-- Only entities that need to act need to be added. Terrain features do not need this usualy
function _M:addEntity(e)
	if self.entities[e.uid] then error("Entity "..e.uid.." already present on the level") end
	self.entities[e.uid] = e
	table.insert(self.e_array, e)
	game:addEntity(e)
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
	game:removeEntity(e)
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

	self.e_distances = {}
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
			local e = table.remove(self.e_toprocess)
			if e then
				self:computeDistances(e)
			end
			coroutine.yield()
		end
	end)
	return co
end

local dist_sort = function(a, b) return a.dist < b.dist end

--- Compute distances to all other actors
function _M:computeDistances(e)
	self.e_distances[e.uid] = {}
	core.fov.calc_circle(e.x, e.y, e.sight, function(self, lx, ly)
		if self.map:checkEntity(lx, ly, Map.TERRAIN, "block_sight") then return true end

		local dst = self.map(lx, ly, Map.ACTOR)
		if dst then
			table.insert(self.e_distances[e.uid], {uid=dst.uid, dist=core.fov.distance(e.x, e.y, dst.x, dst.y)})
		end
	end, function()end, self)

	table.sort(self.e_distances[e.uid], dist_sort)
end

--- Get distances to all other actors
-- This eithers computes directly if not available or use data from the distancer coroutine
function _M:getDistances(e, force)
	if force and not self.e_distances[e.uid] then self:computeDistances(e) end
	return self.e_distances[e.uid]
end

--- Insert an actor to process
function _M:idleProcessActor(act)
	table.insert(self.e_toprocess, 1, act)
end

--- Setup an entity list for the level, this allwos the Zone to pick objects/actors/...
function _M:setEntitiesList(type, list)
	self.entities_list[type] = list
	print("Stored entities list", type, list)
end

--- Gets an entity list for the level, this allows the Zone to pick objects/actors/...
function _M:getEntitiesList(type)
	return self.entities_list[type]
end

--- Removed, so we remove all entities
function _M:removed()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		local z = i + j * self.map.w
		if self.map.map[z] then
			for _, e in pairs(self.map.map[z]) do
				e:removed()
			end
		end
	end end
end
