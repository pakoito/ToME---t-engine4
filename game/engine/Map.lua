require "engine.class"
local Entity = require "engine.Entity"
local Tiles = require "engine.Tiles"
local Faction = require "engine.Faction"

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
-- @param w width
-- @param h height
-- @param tile_w width of a single tile
-- @param tile_h height of a single tile
-- @param fontname font parameters, can be nil
-- @param fontsize font parameters, can be nil
function _M:setViewPort(x, y, w, h, tile_w, tile_h, fontname, fontsize)
	self.display_x, self.display_y = x, y
	self.viewport = {width=w, height=h, mwidth=math.floor(w/tile_w), mheight=math.floor(h/tile_h)}
	self.tiles = Tiles.new(tile_w, tile_h, fontname, fontsize)
	self.tile_w, self.tile_h = tile_w, tile_h
end

--- Defines the faction of the person seeing the map
-- Usualy this will be the player's faction. If you do not want to use tactical display, dont use it
function _M:setViewerFaction(faction, friend, neutral, enemy)
	self.view_faction = faction
	self.faction_friend = "tactical_friend.png"
	self.faction_neutral = "tactical_neutral.png"
	self.faction_enemy = "tactical_enemy.png"
end

--- Creates a map
-- @param w width (in grids)
-- @param h height (in grids)
-- @param x screen coordonate where the map will be displayed (this has no impact on the real display). This is used to compute mouse clicks
-- @param y screen coordonate where the map will be displayed (this has no impact on the real display). This is used to compute mouse clicks
function _M:init(w, h)
	self.mx = 0
	self.my = 0
	self.w, self.h = w, h
	self.map = {}
	self.lites = {}
	self.seens = {}
	self.remembers = {}
	for i = 0, w * h - 1 do self.map[i] = {} end

	self:loaded()
end

--- Serialization
function _M:save()
	return class.save(self, {
		_fov_lite = true,
		_fov = true,
		surface = true
	})
end
function _M:loaded()
	local mapbool = function(t, x, y, v)
		if x < 0 or y < 0 or x >= self.w or y >= self.h then return end
		if v ~= nil then
			t[x + y * self.w] = v
		end
		return t[x + y * self.w]
	end

	getmetatable(self).__call = _M.call
	setmetatable(self.lites, {__call = mapbool})
	setmetatable(self.seens, {__call = mapbool})
	setmetatable(self.remembers, {__call = mapbool})

	self.surface = core.display.newSurface(self.viewport.width, self.viewport.height)
	self._fov = core.fov.new(_M.opaque, _M.apply, self)
	self._fov_lite = core.fov.new(_M.opaque, _M.applyLite, self)
	self.changed = true
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
		self._fov_lite(x, y, d)
	end
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
		self.changed = true
	end
end

--- Displays the map on a surface
-- @return a surface containing the drawn map
function _M:display()
	-- If nothing changed, return the same surface as before
	if not self.changed then return self.surface end
	self.changed = false
	self.clean_fov = true

	-- Erase and the display the map
	self.surface:erase()
	if not self.multi_display then
		-- Version without multi display
		local e, si
		local z
		local order
		local friend
		for i = self.mx, self.mx + self.viewport.mwidth - 1 do
		for j = self.my, self.my + self.viewport.mheight - 1 do
			e, si = nil, 1
			z = i + j * self.w
			order = displayOrder
			if self.seens[z] or self.remembers[z] then
				if not self.seens[z] then order = rememberDisplayOrder end
				while not e and si <= #order do e = self(i, j, order[si]) si = si + 1 end
				if e then
					if self.seens[z] then
						self.surface:merge(self.tiles:get(e.display, e.color_r, e.color_g, e.color_b, e.color_br, e.color_bg, e.color_bb, e.image), (i - self.mx) * self.tile_w, (j - self.my) * self.tile_h)
					elseif self.remembers[z] then
						self.surface:merge(self.tiles:get(e.display, e.color_r/3, e.color_g/3, e.color_b/3, e.color_br/3, e.color_bg/3, e.color_bb/3, e.image), (i - self.mx) * self.tile_w, (j - self.my) * self.tile_h)
					end
					-- Tactical overlay ?
					if self.view_faction and e.faction then
						friend = Faction:factionReaction(self.view_faction, e.faction)
						if friend > 0 then
							self.surface:merge(self.tiles:get(nil, 0,0,0, 0,0,0, self.faction_friend), (i - self.mx) * self.tile_w, (j - self.my) * self.tile_h)
						elseif friend < 0 then
							self.surface:merge(self.tiles:get(nil, 0,0,0, 0,0,0, self.faction_enemy), (i - self.mx) * self.tile_w, (j - self.my) * self.tile_h)
						else
							self.surface:merge(self.tiles:get(nil, 0,0,0, 0,0,0, self.faction_neutral), (i - self.mx) * self.tile_w, (j - self.my) * self.tile_h)
						end
					end
				end
			end
		end end
	else
		-- Version with multi display
--[[
		local z, e, si = nil, nil, 1
		for i = 0, self.w - 1 do for j = 0, self.h - 1 do
			z = i + j * self.w
			z, e, si = 0, nil, #displayOrder
			while si >= 1 do
				e = self(i, j, displayOrder[si])
				if e then
					if self.seens[z] then
					self.surface:merge(self.tiles:get(e.display, e.color_r, e.color_g, e.color_b, e.color_br, e.color_bg, e.color_bb), i * 16, j * 16)
				elseif self.remembers[z] then
					self.surface:merge(self.tiles:get(e.display, e.color_r/3, e.color_g/3, e.color_b/3, e.color_br/3, e.color_bg/3, e.color_bb/3), i * 16, j * 16)
					end
				end

				si = si - 1
			end
			self.seens[z] = nil
		end end
]]
	end
	return self.surface
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
		self.remembers[x + y * self.w] = true
	end
end

--- Sets a grid as seen, lited and remembered
-- Used by FOV code
function _M:applyLite(x, y)
	if x < 0 or x >= self.w or y < 0 or y >= self.h then return end
	self.lites[x + y * self.w] = true
	self.seens[x + y * self.w] = true
	self.remembers[x + y * self.w] = true
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
