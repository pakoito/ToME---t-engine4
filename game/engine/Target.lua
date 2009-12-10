require "engine.class"
local Map = require "engine.Map"

--- handles targetting
module(..., package.seeall, class.make)

function _M:init(map, source_actor)
	self.display_x, self.display_y = map.display_x, map.display_y
	self.w, self.h = map.viewport.width, map.viewport.height
	self.tile_w, self.tile_h = map.tile_w, map.tile_h
	self.active = false
	self.target_type = {}

	self.cursor = core.display.loadImage(engine.Tiles.prefix.."target_cursor.png")

	self.sr = core.display.newSurface(map.tile_w, map.tile_h)
	self.sr:erase(255, 0, 0, 90)
	self.sb = core.display.newSurface(map.tile_w, map.tile_h)
	self.sb:erase(0, 0, 255, 90)
	self.sg = core.display.newSurface(map.tile_w, map.tile_h)
	self.sg:erase(0, 255, 0, 90)

	self.source_actor = source_actor

	-- Setup the tracking target table
	-- Notice its values are set to weak references, this has no effects on the number for x and y
	-- but it means if the entity field is set to an entity, when it disappears this link wont prevent
	-- the garbage collection
	self.target = {x=self.source_actor.x, y=self.source_actor.y, entity=nil}
--	setmetatable(self.target, {__mode='v'})
end

function _M:display()
	-- Entity tracking, if possible and if visible
	if self.target.entity and self.target.entity.x and self.target.entity.y and game.level.map.seens(self.target.entity.x, self.target.entity.y) then
		self.target.x, self.target.y = self.target.entity.x, self.target.entity.y
	end

	-- Do not display if not requested
	if not self.active then return end

	local s = self.sb
	local l = line.new(self.source_actor.x, self.source_actor.y, self.target.x, self.target.y)
	local lx, ly = l()
	local stopx, stopy = self.source_actor.x, self.source_actor.y
	while lx and ly do
		if not self.target_type.no_restrict then
			if not game.level.map.seens(lx, ly) then s = self.sr end
			if self.target_type.stop_block and game.level.map:checkAllEntities(lx, ly, "block_move") then s = self.sr
			elseif game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move") then s = self.sr end
		end
		if self.target_type.range and math.sqrt((self.source_actor.x-lx)^2 + (self.source_actor.y-ly)^2) > self.target_type.range then s = self.sr end
		if s == self.sb then stopx, stopy = lx, ly end
		s:toScreen(self.display_x + (lx - game.level.map.mx) * self.tile_w, self.display_y + (ly - game.level.map.my) * self.tile_h)
		lx, ly = l()
	end
	self.cursor:toScreen(self.display_x + (self.target.x - game.level.map.mx) * self.tile_w, self.display_y + (self.target.y - game.level.map.my) * self.tile_h)

	if s == self.b then stopx, stopy = self.target.x, self.target.y end

	if self.target_type.ball then
		core.fov.calc_circle(stopx, stopy, self.target_type.ball, function(self, lx, ly)
			self.sg:toScreen(self.display_x + (lx - game.level.map.mx) * self.tile_w, self.display_y + (ly - game.level.map.my) * self.tile_h)
			if not self.target_type.no_restrict and game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move") then return true end
		end, function()end, self)
	end
end

--- Returns data for the given target type
-- Hit: simple project in LOS<br/>
-- Beam: hits everything in LOS<br/>
-- Bolt: hits first thing in path<br/>
-- Ball: hits everything in a ball aounrd the target<br/>
-- Cone: hits everything in a cone in the direction<br/>
function _M:getType(t)
	if not t or not t.type then return {} end
	t.range = t.range or 20
	if t.friendlyfire == nil then t.friendlyfire = true end
	if t.type == "hit" then
		return {range=t.range, friendlyfire=t.friendlyfire, no_restrict=t.no_restrict}
	elseif t.type == "beam" then
		return {range=t.range, friendlyfire=t.friendlyfire, no_restrict=t.no_restrict, line=true}
	elseif t.type == "bolt" then
		return {range=t.range, friendlyfire=t.friendlyfire, no_restrict=t.no_restrict, stop_block=true}
	elseif t.type == "ball" then
		return {range=t.range, friendlyfire=t.friendlyfire, no_restrict=t.no_restrict, ball=t.radius}
	elseif t.type == "cone" then
		return {range=t.range, friendlyfire=t.friendlyfire, no_restrict=t.no_restrict, cone=t.radius}
	else
		return {}
	end
end

function _M:setActive(v, type)
	if v == nil then
		return self.active
	else
		self.active = v
		if v and type then
			self.target_type = self:getType(type)
		else
			self.target_type = {}
		end
	end
end

function _M:scan(dir, radius, sx, sy)
	sx = sx or self.target.x
	sy = sy or self.target.y
	radius = radius or 20
	local actors = {}
	local checker = function(self, x, y)
		if sx == x and sy == y then return false end
		if game.level.map.seens(x, y) and game.level.map(x, y, engine.Map.ACTOR) then
			local a = game.level.map(x, y, engine.Map.ACTOR)

			table.insert(actors, {
				a = a,
				dist = math.abs(sx - x)*math.abs(sx - x) + math.abs(sy - y)*math.abs(sy - y)
			})
			actors[a] = true
		end
		return false
	end

	if dir ~= 5 then
		-- Get a list of actors in the direction given
		core.fov.calc_beam(sx, sy, radius, dir, 55, checker, function()end, self)
	else
		-- Get a list of actors all around
		core.fov.calc_circle(sx, sy, radius, checker, function()end, self)
	end

	table.sort(actors, function(a,b) return a.dist<b.dist end)
	if #actors > 0 then
		self.target.entity = actors[1].a
		self.target.x = self.target.entity.x
		self.target.y = self.target.entity.y
	end
end

--- Returns the point at distance from the source on a line to the destination
function _M:pointAtRange(srcx, srcy, destx, desty, dist)
	local l = line.new(srcx, srcy, destx, desty)
	local lx, ly = l()
	while lx and ly do
		if core.fov.distance(srcx, srcy, lx, ly) >= dist then break end
		lx, ly = l()
	end
	if not lx then
		return destx, desty
	else
		return lx, ly
	end
end
