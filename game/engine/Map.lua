require "engine.class"
local Entity = require "engine.Entity"

module(..., package.seeall, class.make)

TERRAIN = 1
OBJECT = 10
ACTOR = 20

function _M:init(w, h)
	self.w, self.h = w, h
	self.map = {}
	self.seens = {}
	self.remembers = {}
	for i = 0, w * h - 1 do self.map[i] = {} end
	getmetatable(self).__call = _M.call
	setmetatable(self.seens, {__call = function(t, x, y, v) if v ~= nil then t[x + y * w] = v end return t[x + y * w] end})
	setmetatable(self.remembers, {__call = function(t, x, y, v) if v ~= nil then t[x + y * w] = v end return t[x + y * w] end})

	self.fov = engine.fov.new(_M.opaque, _M.apply, self)
end

function _M:setCurrent()
	engine.display.set_current_map(self)
end

function _M:call(x, y, pos, entity)
	if entity then
		table.insert(self.map[x + y * self.w], pos, entity)
	else
		if self.map[x + y * self.w] then
			return self.map[x + y * self.w][pos]
		end
	end
end

function _M:remove(x, y, pos)
	if self.map[x + y * self.w] then
		self.map[x + y * self.w][pos] = nil
	end
end

function _M:display()
	self.fov(player.x, player.y, 20)
	self.seens(player.x, player.y, true)
	player:move(self, player.x+1, player.y)

	for i = 0, self.w - 1 do for j = 0, self.h - 1 do
		local e = self(i, j, TERRAIN)
		local z = i + j * self.w
		if e then
--		print("grid", i, j, z, self.seens[z])
			if self.seens[z] then
				engine.display.char(e.display, i, j, e.color_r, e.color_g, e.color_b)
			elseif self.remembers[z] then
				engine.display.char(e.display, i, j, e.color_r/3, e.color_g/3, e.color_b/3)
			end
		end
		self.seens[z] = nil
	end end
end

function _M:close()
	self.fov:close()
	self.fov = nil
end

function _M:opaque(x, y)
	if x < 0 or x >= self.w or y < 0 or y >= self.h then return false end
	local e = self(x, y, TERRAIN)
	if e and e.block_sight then return true end
end

function _M:apply(x, y)
	if x < 0 or x >= self.w or y < 0 or y >= self.h then return end
	self.seens[x + y * self.w] = true
	self.remembers[x + y * self.w] = true
end
