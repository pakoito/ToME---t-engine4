require "engine.class"
local Entity = require "engine.Entity"

module(..., package.seeall, class.make)

TERRAIN = 1
OBJECT = 10
ACTOR = 20

displayOrder = { ACTOR, OBJECT, TERRAIN }

function _M:init(w, h)
	self.w, self.h = w, h
	self.map = {}
	self.seens = {}
	self.remembers = {}
	for i = 0, w * h - 1 do self.map[i] = {} end
	getmetatable(self).__call = _M.call
	setmetatable(self.seens, {__call = function(t, x, y, v) if v ~= nil then t[x + y * w] = v end return t[x + y * w] end})
	setmetatable(self.remembers, {__call = function(t, x, y, v) if v ~= nil then t[x + y * w] = v end return t[x + y * w] end})

	self.surface = core.display.newSurface(400, 400)
	self.fov = core.fov.new(_M.opaque, _M.apply, self)
	self.changed = true
end

function _M:setCurrent()
	core.display.set_current_map(self)
end

function _M:call(x, y, pos, entity)
	if entity then
		table.insert(self.map[x + y * self.w], pos, entity)
		self.changed = true
	else
		if self.map[x + y * self.w] then
			return self.map[x + y * self.w][pos]
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
	self.fov(player.x, player.y, 20)
	self.seens(player.x, player.y, true)
	player:move(self, player.x+1, player.y)

	-- If nothing changed, return the same surface as before
	if not self.changed then return self.surface end
	self.changed = false

	-- Erase and the display the map
	self.surface:erase()
	if not self.multi_display then
		-- Version without multi display
		for i = 0, self.w - 1 do for j = 0, self.h - 1 do
			local e, si = nil, 1
			while not e and si <= #displayOrder do e = self(i, j, displayOrder[si]) si = si + 1 end
			local z = i + j * self.w
			if e then
				if self.seens[z] then
					self.surface:putChar(e.display, i, j, e.color_r, e.color_g, e.color_b)
				elseif self.remembers[z] then
					self.surface:putChar(e.display, i, j, e.color_r/3, e.color_g/3, e.color_b/3)
				end
			end
			self.seens[z] = nil
		end end
	else
		-- Version with multi display
		local e, si = nil, 1
		for i = 0, self.w - 1 do for j = 0, self.h - 1 do
			z, e, si = 0, nil, #displayOrder
			while si >= 1 do
				e = self(i, j, displayOrder[si])
				z = i + j * self.w
				if e then
					if self.seens[z] then
						self.surface:putChar(e.display, i, j, e.color_r, e.color_g, e.color_b)
					elseif self.remembers[z] then
						self.surface:putChar(e.display, i, j, e.color_r/3, e.color_g/3, e.color_b/3)
					end
				end

				si = si - 1
			end
			self.seens[z] = nil
		end end
	end
	return self.surface
end

function _M:close()
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
	self.seens[x + y * self.w] = true
	self.remembers[x + y * self.w] = true
end
