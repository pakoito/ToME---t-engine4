require "engine.class"
local Map = require "engine.Map"

--- Handles actors field of view
-- When an actor moves it computes a field of view and stores it in self.fov<br/>
-- When an other actor moves it can update the fov of seen actors
module(..., package.seeall, class.make)

--- Initialises stats with default values if needed
function _M:init(t)
	self.fov = {actors={}, actors_dist={}}
	self.fov_computed = false
	self.fov_last_x = -1
	self.fov_last_y = -1
	self.fov_last_turn = -1
	self.fov_last_change = -1
end

--- Computes actor's FOV
-- @param radius the FOV radius, defaults to 20
-- @param block the property to look for FOV blocking, defaults to "block_sight"
-- @param apply an apply function that will be called on each seen grids, defaults to nil
-- @param force set to true to force a regeneration even if we did not move
-- @param no_store do not store FOV informations
function _M:computeFOV(radius, block, apply, force, no_store, cache)
	-- If we did not move, do not update
	if not force and self.fov_last_x == self.x and self.fov_last_y == self.y and self.fov_computed then return end
	radius = radius or 20
	block = block or "block_sight"

	-- Simple FOV compute no storage
	if no_store and apply then
		local map = game.level.map
		core.fov.calc_circle(self.x, self.y, radius, function(_, x, y)
			if map:checkAllEntities(x, y, block, self) then return true end
		end, function(_, x, y, dx, dy)
			apply(x, y, dx, dy)
		end, cache and game.level.map._fovcache[block])

	-- FOV + storage
	elseif not no_store then
		local fov = {actors={}, actors_dist={}}
		setmetatable(fov.actors, {__mode='k'})
		setmetatable(fov.actors_dist, {__mode='v'})

		local map = game.level.map
		core.fov.calc_circle(self.x, self.y, radius, function(_, x, y)
			if map:checkAllEntities(x, y, block, self) then return true end
		end, function(_, x, y, dx, dy)
			if apply then apply(x, y, dx, dy) end

			-- Note actors
			local a = map(x, y, Map.ACTOR)
			if a and a ~= self and not a.dead then
				local t = {x=x,y=y, dx=dx, dy=dy, sqdist=dx*dx+dy*dy}
				fov.actors[a] = t
				fov.actors_dist[#fov.actors_dist+1] = a
				a:updateFOV(self, t.sqdist)
			end
		end, cache and game.level.map._fovcache[block])

		-- Sort actors by distance (squared but we do not care)
		table.sort(fov.actors_dist, function(a, b) return fov.actors[a].sqdist < fov.actors[b].sqdist end)
		for i = 1, #fov.actors_dist do fov.actors_dist[i].i = i end
--		print("Computed FOV for", self.uid, self.name, ":: seen ", #fov.actors_dist, "actors closeby")

		self.fov = fov
		self.fov_last_x = self.x
		self.fov_last_y = self.y
		self.fov_last_turn = game.turn
		self.fov_last_change = game.turn
		self.fov_computed = true
	end
end

--- Update our fov to include the given actor at the given dist
-- @param a the actor to include
-- @param sqdist the squared distance to that actor
function _M:updateFOV(a, sqdist)
	-- If we are from this turn no need to update
	if self.fov_last_turn == game.turn then return end

	local t = {x=a.x, y=a.y, dx=a.x-self.x, dy=a.y-self.y, sqdist=sqdist}

	local fov = self.fov
	if not fov.actors[a] then
		fov.actors_dist[#fov.actors_dist+1] = a
	end
	fov.actors[a] = t
--	print("Updated FOV for", self.uid, self.name, ":: seen ", #fov.actors_dist, "actors closeby; from", a, sqdist)
	table.sort(fov.actors_dist, function(a, b) if a and b then return fov.actors[a].sqdist < fov.actors[b].sqdist elseif a then return 1 else return nil end end)
	self.fov_last_change = game.turn
end
