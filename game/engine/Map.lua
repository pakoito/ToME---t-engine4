require "engine.class"
local Entity = require "engine.Entity"
local Tiles = require "engine.Tiles"
local Faction = require "engine.Faction"
local DamageType = require "engine.DamageType"

--- Represents a level map, handles display and various low level map work
module(..., package.seeall, class.make)

--- The place of a terrain entity in a map grid
TERRAIN = 1
--- The place of an actor entity in a map grid
ACTOR = 100
--- The place of an object entity in a map grid
OBJECT = 1000

--- The order of display for grid seen
displayOrder = { ACTOR, OBJECT, TERRAIN }
--- The order of display for grids remembered
rememberDisplayOrder = { TERRAIN }

--- Sets the viewport size
-- Static
-- @param x screen coordonate where the map will be displayed (this has no impact on the real display). This is used to compute mouse clicks
-- @param y screen coordonate where the map will be displayed (this has no impact on the real display). This is used to compute mouse clicks
-- @param w width
-- @param h height
-- @param tile_w width of a single tile
-- @param tile_h height of a single tile
-- @param fontname font parameters, can be nil
-- @param fontsize font parameters, can be nil
function _M:setViewPort(x, y, w, h, tile_w, tile_h, fontname, fontsize, multidisplay)
	self.multidisplay = multidisplay
	self.display_x, self.display_y = x, y
	self.viewport = {width=w, height=h, mwidth=math.floor(w/tile_w), mheight=math.floor(h/tile_h)}
	self.tile_w, self.tile_h = tile_w, tile_h
	self.fontname, self.fontsize = fontname, fontsize
	self:resetTiles()
end

--- Create the tile repositories
function _M:resetTiles()
	self.tiles = Tiles.new(self.tile_w, self.tile_h, self.fontname, self.fontsize, true)
	self.tilesSurface = Tiles.new(self.tile_w, self.tile_h, self.fontname, self.fontsize, false)
end

--- Defines the faction of the person seeing the map
-- Usualy this will be the player's faction. If you do not want to use tactical display, dont use it
function _M:setViewerFaction(faction, friend, neutral, enemy)
	self.view_faction = faction
	self.faction_friend = "tactical_friend.png"
	self.faction_neutral = "tactical_neutral.png"
	self.faction_enemy = "tactical_enemy.png"
end

--- Defines the actor that sees the map
-- Usualy this will be the player. This is used to determine invisibility/...
function _M:setViewerActor(player)
	self.actor_player = player
end

--- Creates a map
-- @param w width (in grids)
-- @param h height (in grids)
function _M:init(w, h)
	self.mx = 0
	self.my = 0
	self.w, self.h = w, h
	self.map = {}
	self.lites = {}
	self.seens = {}
	self.remembers = {}
	self.effects = {}
	for i = 0, w * h - 1 do self.map[i] = {} end

	self:loaded()
end

--- Serialization
function _M:save()
	return class.save(self, {
		_fov_lite = true,
		_fov = true,
		_map = true,
		surface = true
	})
end
function _M:loaded()
	self._map = core.map.newMap(self.w, self.h, self.mx, self.my, self.viewport.mwidth, self.viewport.mheight, self.tile_w, self.tile_h, self.multidisplay)

	local mapseen = function(t, x, y, v)
		if x < 0 or y < 0 or x >= self.w or y >= self.h then return end
		if v ~= nil then
			t[x + y * self.w] = v
			self._map:setSeen(x, y, v)
		end
		return t[x + y * self.w]
	end
	local mapremember = function(t, x, y, v)
		if x < 0 or y < 0 or x >= self.w or y >= self.h then return end
		if v ~= nil then
			t[x + y * self.w] = v
			self._map:setRemember(x, y, v)
		end
		return t[x + y * self.w]
	end
	local maplite = function(t, x, y, v)
		if x < 0 or y < 0 or x >= self.w or y >= self.h then return end
		if v ~= nil then
			t[x + y * self.w] = v
			self._map:setLite(x, y, v)
		end
		return t[x + y * self.w]
	end

	getmetatable(self).__call = _M.call
	setmetatable(self.lites, {__call = maplite})
	setmetatable(self.seens, {__call = mapseen})
	setmetatable(self.remembers, {__call = mapremember})

	self.surface = core.display.newSurface(self.viewport.width, self.viewport.height)
	self._fov = core.fov.new(_M.opaque, _M.apply, self)
	self._fov_lite = core.fov.new(_M.opaque, _M.applyLite, self)
	self.changed = true

	self:redisplay()
end

--- Recreate the internal map using new dimensions
function _M:recreate()
	self._map = core.map.newMap(self.w, self.h, self.mx, self.my, self.viewport.mwidth, self.viewport.mheight, self.tile_w, self.tile_h, self.multidisplay)
	self.changed = true
	self:redisplay()
end

--- Redisplays the map, storing seen information
function _M:redisplay()
	for i = 0, self.w - 1 do for j = 0, self.h - 1 do
		self._map:setSeen(i, j, self.seens(i, j))
		self._map:setRemember(i, j, self.remembers(i, j))
		self._map:setLite(i, j, self.lites(i, j))
		self:updateMap(i, j)
	end end
end

--- Closes things in the object to allow it to be garbage collected
-- Map objects are NOT automatically garbage collected because they contain FOV C structure, which themselves have a reference
-- to the map. Cyclic references! BAD BAD BAD !<br/>
-- The closing should be handled automatically by the Zone class so no bother for authors
function _M:close()
	self._fov = false
	self._fov_lite = false
end

--- Runs the FOV algorithm on the map
-- @param x source point of the ligth
-- @param y source point of the ligth
-- @param d radius of the light
function _M:fov(x, y, d)
	-- Reset seen grids
	if self.clean_fov then
		self.clean_fov = false
		for i = 0, self.w * self.h - 1 do self.seens[i] = nil end
		self._map:cleanSeen();
	end
	self._fov(x, y, d)
end

--- Runs the FOV algorithm on the map, ligthing grids to allow rememberance
-- @param x source point of the ligth
-- @param y source point of the ligth
-- @param d radius of the light
function _M:fovLite(x, y, d)
	-- Reset seen grids
	if self.clean_fov then
		self.clean_fov = false
		for i = 0, self.w * self.h - 1 do self.seens[i] = nil end
		self._map:cleanSeen();
	end
	self._fov_lite(x, y, d)
end

function _M:updateMap(x, y)
	local g = self(x, y, TERRAIN)
	local o = self(x, y, OBJECT)
	local a = self(x, y, ACTOR)

	if g then g = self.tiles:get(g.display, g.color_r, g.color_g, g.color_b, g.color_br, g.color_bg, g.color_bb, g.image) end
	if o then o = self.tiles:get(o.display, o.color_r, o.color_g, o.color_b, o.color_br, o.color_bg, o.color_bb, o.image) end
	if a then
		-- Handles invisibility and telepathy and otehr such things
		if not self.actor_player or self.actor_player:canSee(a) then
			a = self.tiles:get(a.display, a.color_r, a.color_g, a.color_b, a.color_br, a.color_bg, a.color_bb, a.image)
		else
			a = nil
		end
	end

	self._map:setGrid(x, y, g, o, a)
end

--- Sets/gets a value from the map
-- It is defined as the function metamethod, so one can simply do: mymap(x, y, Map.TERRAIN)
-- @param x position
-- @param y position
-- @param pos what kind of entity to set(Map.TERRAIN, Map.OBJECT, Map.ACTOR)
-- @param entity the entity to set, if null it will return the current one
function _M:call(x, y, pos, entity)
	if x < 0 or y < 0 or x >= self.w or y >= self.h then return end
	if entity then
		self.map[x + y * self.w][pos] = entity
		self.changed = true

		self:updateMap(x, y)
	else
		if self.map[x + y * self.w] then
			if not pos then
				return self.map[x + y * self.w]
			else
				return self.map[x + y * self.w][pos]
			end
		end
	end
end

--- Removes an entity
-- @param x position
-- @param y position
-- @param pos what kind of entity to set(Map.TERRAIN, Map.OBJECT, Map.ACTOR)
function _M:remove(x, y, pos)
	if self.map[x + y * self.w] then
		self.map[x + y * self.w][pos] = nil
		self:updateMap(x, y)
		self.changed = true
	end
end

--- Displays the map on a surface
-- @return a surface containing the drawn map
function _M:display()
	self._map:toScreen(self.display_x, self.display_y)

	-- Tactical display
	if self.view_faction then
		local e
		local z
		local friend
		for i = self.mx, self.mx + self.viewport.mwidth - 1 do
		for j = self.my, self.my + self.viewport.mheight - 1 do
			local z = i + j * self.w
			if self.seens[z] then
				e = self(i, j, ACTOR)
				if e then
					-- Tactical overlay ?
					if e.faction then
						friend = Faction:factionReaction(self.view_faction, e.faction)
						if friend > 0 then
							self.tiles:get(nil, 0,0,0, 0,0,0, self.faction_friend):toScreen(self.display_x + (i - self.mx) * self.tile_w, (j - self.my) * self.tile_h, self.tile_w, self.tile_h)
						elseif friend < 0 then
							self.tiles:get(nil, 0,0,0, 0,0,0, self.faction_enemy):toScreen(self.display_x + (i - self.mx) * self.tile_w, (j - self.my) * self.tile_h, self.tile_w, self.tile_h)
						else
							self.tiles:get(nil, 0,0,0, 0,0,0, self.faction_neutral):toScreen(self.display_x + (i - self.mx) * self.tile_w, (j - self.my) * self.tile_h, self.tile_w, self.tile_h)
						end
					end
				end
			end
		end end
	end

	self:displayEffects()

	-- If nothing changed, return the same surface as before
	if not self.changed then return end
	self.changed = false
	self.clean_fov = true
end

--- Sets checks if a grid lets sigth pass through
-- Used by FOV code
function _M:opaque(x, y)
	if x < 0 or x >= self.w or y < 0 or y >= self.h then return false end
	local e = self(x, y, TERRAIN)
	if e and e:check("block_sight") then return true end
end

--- Sets a grid as seen and remembered
-- Used by FOV code
function _M:apply(x, y)
	if x < 0 or x >= self.w or y < 0 or y >= self.h then return end
	if self.lites[x + y * self.w] then
		self.seens[x + y * self.w] = true
		self._map:setSeen(x, y, true)
		self.remembers[x + y * self.w] = true
		self._map:setRemember(x, y, true)
	end
end

--- Sets a grid as seen, lited and remembered
-- Used by FOV code
function _M:applyLite(x, y)
	if x < 0 or x >= self.w or y < 0 or y >= self.h then return end
	if self.lites[x + y * self.w] or self:checkAllEntities(x, y, "always_remember") then
		self.remembers[x + y * self.w] = true
		self._map:setRemember(x, y, true)
	end
	self.seens[x + y * self.w] = true
	self._map:setSeen(x, y, true)
end

--- Check all entities of the grid for a property
-- @param x position
-- @param y position
-- @param what property to check
function _M:checkAllEntities(x, y, what, ...)
	if x < 0 or x >= self.w or y < 0 or y >= self.h then return end
	if self.map[x + y * self.w] then
		for _, e in pairs(self.map[x + y * self.w]) do
			local p = e:check(what, x, y, ...)
			if p then return p end
		end
	end
end

--- Check specified entity position of the grid for a property
-- @param x position
-- @param y position
-- @param pos entity position in the grid
-- @param what property to check
function _M:checkEntity(x, y, pos, what, ...)
	if x < 0 or x >= self.w or y < 0 or y >= self.h then return end
	if self.map[x + y * self.w] then
		if self.map[x + y * self.w][pos] then
			local p = self.map[x + y * self.w][pos]:check(what, x, y, ...)
			if p then return p end
		end
	end
end

--- Lite all grids
function _M:liteAll(x, y, w, h)
	for i = x, x + w - 1 do for j = y, y + h - 1 do
		self.lites(i, j, true)
	end end
end

--- Remember all grids
function _M:rememberAll(x, y, w, h)
	for i = x, x + w - 1 do for j = y, y + h - 1 do
		self.remembers(i, j, true)
	end end
end

--- Sets the current view area with the given coords at the center
function _M:centerViewAround(x, y)
	self.mx = x - math.floor(self.viewport.mwidth / 2)
	self.my = y - math.floor(self.viewport.mheight / 2)
	self.changed = true
	self:checkMapViewBounded()
end

--- Sets the current view area if x and y are out of bounds
function _M:moveViewSurround(x, y, marginx, marginy)
	if self.mx + marginx >= x or self.mx + self.viewport.mwidth - marginx <= x then
		self.mx = x - math.floor(self.viewport.mwidth / 2)
		self.changed = true
	end
	if self.my + marginy >= y or self.my + self.viewport.mheight - marginy <= y then
		self.my = y - math.floor(self.viewport.mheight / 2)
		self.changed = true
	end
	self:checkMapViewBounded()
end

--- Checks the map is bound to the screen (no "empty space" if the map is big enough)
function _M:checkMapViewBounded()
	if self.mx < 0 then self.mx = 0 self.changed = true end
	if self.my < 0 then self.my = 0 self.changed = true end
	if self.mx > self.w - self.viewport.mwidth then self.mx = self.w - self.viewport.mwidth self.changed = true end
	if self.my > self.h - self.viewport.mheight then self.my = self.h - self.viewport.mheight self.changed = true end

	-- Center if smaller than map viewport
	if self.w < self.viewport.mwidth then self.mx = math.floor((self.w - self.viewport.mwidth) / 2) end
	if self.h < self.viewport.mheight then self.my = math.floor((self.h - self.viewport.mheight) / 2) end

	self._map:setScroll(self.mx, self.my)
end

--- Gets the tile under the mouse
function _M:getMouseTile(mx, my)
--	if mx < self.display_x or my < self.display_y or mx >= self.display_x + self.viewport.width or my >= self.display_y + self.viewport.height then return end
	local tmx = math.floor((mx - self.display_x) / self.tile_w) + self.mx
	local tmy = math.floor((my - self.display_y) / self.tile_h) + self.my
	return tmx, tmy
end

--- Get the screen position corresponding to a tile
function _M:getTileToScreen(tx, ty)
	local x = (tx - self.mx) * self.tile_w + self.display_x
	local y = (ty - self.my) * self.tile_h + self.display_y
	return x, y
end

--- Checks the given coords to see if they are in bound
function _M:isBound(x, y)
	if x < 0 or x >= self.w or y < 0 or y >= self.h then return false end
	return true
end

--- Adds a zone (temporary) effect
-- @param src the source actor
-- @param x the epicenter coords
-- @param y the epicenter coords
-- @param duration the number of turns to persist
-- @param damtype the DamageType to apply
-- @param radius the radius of the effect
-- @param dir the numpad direction of the effect, 5 for a ball effect
-- @param overlay a simple display entity to draw upon the map
-- @param update_fct optional function that will be called each time the effect is updated with the effect itself as parameter. Use it to change radius, move around ....
function _M:addEffect(src, x, y, duration, damtype, dam, radius, dir, angle, overlay, update_fct, friendlyfire)
	if friendlyfire == nil then friendlyfire = true end
	print(friendlyfire)
	table.insert(self.effects, {
		src=src, x=x, y=y, duration=duration, damtype=damtype, dam=dam, radius=radius, dir=dir, angle=angle, overlay=overlay,
		update_fct=update_fct, friendlyfire=friendlyfire
	})
	self.changed = true
end

--- Display the overlay effects, called by self:display()
function _M:displayEffects()
	for i, e in ipairs(self.effects) do
		-- Dont bother with obviously out of screen stuff
		if e.x + e.radius >= self.mx and e.x - e.radius < self.mx + self.viewport.mwidth and e.y + e.radius >= self.my and e.y - e.radius < self.my + self.viewport.mheight then
			local grids
			local s = self.tilesSurface:get(e.overlay.display, e.overlay.color_r, e.overlay.color_g, e.overlay.color_b, e.overlay.color_br, e.overlay.color_bg, e.overlay.color_bb, e.overlay.image, 120)

			-- Handle balls
			if e.dir == 5 then
				grids = core.fov.circle_grids(e.x, e.y, e.radius, true)
			-- Handle beams
			else
				grids = core.fov.beam_grids(e.x, e.y, e.radius, e.dir, e.angle, true)
			end

			-- Now display each grids
			for lx, ys in pairs(grids) do
				for ly, _ in pairs(ys) do
					if self.seens(lx, ly) then
						s:toScreen(self.display_x + (lx - self.mx) * self.tile_w, self.display_y + (ly - self.my) * self.tile_h)
					end
				end
			end
		end
	end
end

--- Process the overlay effects, call it from your tick function
function _M:processEffects()
	local todel = {}
	for i, e in ipairs(self.effects) do
		local grids

		-- Handle balls
		if e.dir == 5 then
			grids = core.fov.circle_grids(e.x, e.y, e.radius, true)
		-- Handle beams
		else
			grids = core.fov.beam_grids(e.x, e.y, e.radius, e.dir, e.angle, true)
		end

		-- Now display each grids
		for lx, ys in pairs(grids) do
			for ly, _ in pairs(ys) do
				if e.friendlyfire or not (lx == e.src.x and ly == e.src.y) then
					DamageType:get(e.damtype).projector(e.src, lx, ly, e.damtype, e.dam)
				end
			end
		end

		e.duration = e.duration - 1
		if e.duration <= 0 then
			table.insert(todel, i)
		elseif e.update_fct then
			e:update_fct()
		end
	end

	for i = #todel, 1, -1 do table.remove(self.effects, todel[i]) end
end


-------------------------------------------------------------
-------------------------------------------------------------
-- Object functions
-------------------------------------------------------------
-------------------------------------------------------------
function _M:addObject(x, y, o)
	local i = self.OBJECT
	-- Find the first "hole"
	while self(x, y, i) do i = i + 1 end
	-- Fill it
	self(x, y, i, o)
	return true
end

function _M:getObject(x, y, i)
	-- Compute the map stack position
	i = i - 1 + self.OBJECT
	return self(x, y, i)
end

function _M:removeObject(x, y, i)
	-- Compute the map stack position
	i = i - 1 + self.OBJECT
	if not self(x, y, i) then return false end
	-- Remove it
	self:remove(x, y, i)
	-- Move the last one to its position, to never get a "hole"
	local j = i + 1
	while self(x, y, j) do j = j + 1 end
	j = j - 1
	-- If the removed one was not the last
	if j > i then
		local o = self(x, y, j)
		self:remove(x, y, j)
		self(x, y, i, o)
	end

	return true
end
