require "engine.class"

--- handles targetting
module(..., package.seeall, class.make)

function _M:init(map, source_actor)
	self.display_x, self.display_y = map.display_x, map.display_y
	self.w, self.h = map.viewport.width, map.viewport.height
	self.tile_w, self.tile_h = map.tile_w, map.tile_h
	self.active = false

	self.cursor = core.display.loadImage(engine.Tiles.prefix.."target_cursor.png")

	self.sr = core.display.newSurface(map.tile_w, map.tile_h)
	self.sr:alpha(125)
	self.sr:erase(255, 0, 0)
	self.sb = core.display.newSurface(map.tile_w, map.tile_h)
	self.sb:alpha(125)
	self.sb:erase(0, 0, 255)

	self.source_actor = source_actor

	-- Setup the tracking target table
	-- Notice its values are set to weak references, this has no effects on the number for x and y
	-- but it means if the entity field is set to an entity, when it disappears this link wont prevent
	-- the garbage collection
	self.target = {x=self.source_actor.x, y=self.source_actor.y, entity=nil}
	setmetatable(self.target, {__mode='v'})
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
	while lx and ly do
		if not game.level.map.seens(lx, ly) then s = self.sr end
		s:toScreen(self.display_x + (lx - game.level.map.mx) * self.tile_w, self.display_y + (ly - game.level.map.my) * self.tile_h)
		lx, ly = l()
	end
	self.cursor:toScreen(self.display_x + (self.target.x - game.level.map.mx) * self.tile_w, self.display_y + (self.target.y - game.level.map.my) * self.tile_h)
end

function _M:setActive(v)
	if v == nil then
		return self.active
	else
		self.active = v
	end
end

function _M:scan(dir, radius)
	radius = radius or 20
	local actors = {}
	local checker = function(self, x, y)
			if game.level.map.seens(x, y) and game.level.map(x, y, engine.Map.ACTOR) then
				table.insert(actors, {
					a = game.level.map(x, y, engine.Map.ACTOR),
					dist = math.abs(self.target.x - x)*math.abs(self.target.x - x) + math.abs(self.target.y - y)*math.abs(self.target.y - y)
				})
			end
			return false
	end

	if dir ~= 5 then
		-- Get a list of actors in the direction given
		core.fov.calc_beam(self.target.x, self.target.y, radius, dir, 55, checker, function()end, self)
	else
		-- Get a list of actors all around
		core.fov.calc_circle(self.target.x, self.target.y, radius, checker, function()end, self)
	end

	table.sort(actors, function(a,b) return a.dist<b.dist end)
	if #actors > 0 then
		self.target.entity = actors[1].a
	end
end
