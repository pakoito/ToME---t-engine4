require "engine.class"
local Entity = require "engine.Entity"
local Tiles = require "engine.Tiles"

module(..., package.seeall, class.make)

TERRAIN = 1
OBJECT = 10
ACTOR = 20

displayOrder = { ACTOR, OBJECT, TERRAIN }
rememberDisplayOrder = { TERRAIN }

function _M:init(w, h, tile_w, tile_h)
	self.tiles = Tiles.new(tile_w, tile_h)
	self.w, self.h = math.floor(w / tile_w), math.floor(h / tile_h)
	self.tile_w, self.tile_h = tile_w, tile_h
	self.map = {}
	self.lites = {}
	self.seens = {}
	self.remembers = {}
	for i = 0, w * h - 1 do self.map[i] = {} end
	getmetatable(self).__call = _M.call
	local mapbool = function(t, x, y, v)
		if x < 0 or y < 0 or x >= self.w or y >= self.h then return end
		if v ~= nil then
			t[x + y * self.w] = v
		end
		return t[x + y * self.w]
	end
	setmetatable(self.lites, {__call = mapbool})
	setmetatable(self.seens, {__call = mapbool})
	setmetatable(self.remembers, {__call = mapbool})

	self.surface = core.display.newSurface(w, h)
	self.fov = core.fov.new(_M.opaque, _M.apply, self)
	self.fov_lite = core.fov.new(_M.opaque, _M.applyLite, self)
	self.changed = true
end

function _M:call(x, y, pos, entity)
	if entity then
		table.insert(self.map[x + y * self.w], pos, entity)
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

function _M:remove(x, y, pos)
	if self.map[x + y * self.w] then
		self.map[x + y * self.w][pos] = nil
		self.changed = true
	end
end

function _M:display()
	-- If nothing changed, return the same surface as before
	if not self.changed then return self.surface end
	self.changed = false

	-- Erase and the display the map
	self.surface:erase()
	if not self.multi_display then
		-- Version without multi display
		local e, si
		local z
		local order
		for i = 0, self.w - 1 do for j = 0, self.h - 1 do
			e, si = nil, 1
			z = i + j * self.w
			order = displayOrder
			if self.seens[z] or self.remembers[z] then
				if not self.seens[z] then order = rememberDisplayOrder end
				while not e and si <= #order do e = self(i, j, order[si]) si = si + 1 end
				if e then
					if self.seens[z] then
						self.surface:merge(self.tiles:get(e.display, e.color_r, e.color_g, e.color_b, e.color_br, e.color_bg, e.color_bb, e.image), i * self.tile_w, j * self.tile_h)
					elseif self.remembers[z] then
						self.surface:merge(self.tiles:get(e.display, e.color_r/3, e.color_g/3, e.color_b/3, e.color_br/3, e.color_bg/3, e.color_bb/3, e.image), i * self.tile_w, j * self.tile_h)
					end
				end
			end
			self.seens[z] = nil
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

function _M:close()
	self.tiles:close()
	self.fovLite:close()
	self.fovLite = nil
	self.fov:close()
	self.fov = nil
end

function _M:opaque(x, y)
	if x < 0 or x >= self.w or y < 0 or y >= self.h then return false end
	local e = self(x, y, TERRAIN)
	if e and e:check("block_sight") then return true end
end

function _M:apply(x, y)
	if x < 0 or x >= self.w or y < 0 or y >= self.h then return end
	if self.lites[x + y * self.w] then
		self.seens[x + y * self.w] = true
		self.remembers[x + y * self.w] = true
	end
end

function _M:applyLite(x, y)
	if x < 0 or x >= self.w or y < 0 or y >= self.h then return end
	self.lites[x + y * self.w] = true
	self.seens[x + y * self.w] = true
	self.remembers[x + y * self.w] = true
end

function _M:checkAllEntity(x, y, what, ...)
	if x < 0 or x >= self.w or y < 0 or y >= self.h then return end
	if self.map[x + y * self.w] then
		for _, e in pairs(self.map[x + y * self.w]) do
			local p = e:check(what, x, y, ...)
			if p then return p end
		end
	end
end

function _M:liteAll(x, y, w, h)
	for i = x, x + w - 1 do for j = y, y + h - 1 do
		self.lites(i, j, true)
	end end
end
