-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, spots)
	engine.Generator.init(self, zone, map, level, spots)
	local data = level.data.generator.actor

	if data.adjust_level then
		self.adjust_level = {base=zone.base_level, lev = self.level.level, min=data.adjust_level[1], max=data.adjust_level[2]}
	else
		self.adjust_level = {base=zone.base_level, lev = self.level.level, min=0, max=0}
	end
	self.abord_no_guardian = data.abord_no_guardian
	self.filters = data.filters
	self.nb_npc = data.nb_npc or {10, 20}
	self.area = data.area or {x1=0, x2=self.map.w-1, y1=0, y2=self.map.h-1}
	self.guardian = data.guardian
	self.guardian_spot = data.guardian_spot
	self.guardian_alert = data.guardian_alert
	self.guardian_no_connectivity = data.guardian_no_connectivity
	self.guardian_level = data.guardian_level
	self.post_generation = data.post_generation
end

function _M:generate()
	self:regenFrom(1)

	local glevel = self.zone.max_level
	if self.guardian_level then glevel = self.guardian_level end

	if self.guardian and self.level.level == glevel then
		self:generateGuardian(self.guardian)
	end
end

function _M:generateGuardian(guardian)
	local m
	if type(guardian) == "string" then m = self.zone:makeEntityByName(self.level, "actor", guardian)
	else m = self.zone:makeEntity(self.level, "actor", guardian, nil, true)
	end
	local ok = false
	if m then
		local x, y = nil, nil

		if self.guardian_spot then
			local spot = self.level:pickSpot(self.guardian_spot)
			if spot then
				x, y = spot.x, spot.y
				print("Selecting guardian spot", x, y)
			end
		end

		if not x or not y then
			x, y = rng.range(self.area.x1, self.area.x2), rng.range(self.area.y1, self.area.y2)
			local tries = 0
			while (not m:canMove(x, y) or self.map.room_map[x][y].special) and tries < 100 do
				x, y = rng.range(self.area.x1, self.area.x2), rng.range(self.area.y1, self.area.y2)
				tries = tries + 1
			end
			if tries >= 100 then x, y = nil, nil end
		end

		if x and y then
			self.spots[#self.spots+1] = {x=x, y=y, guardian=true, check_connectivity=(not self.guardian_no_connectivity) and "entrance" or nil}
			self.zone:addEntity(self.level, m, "actor", x, y)
			print("Guardian allocated: ", self.guardian, m.uid, m.name)
			if self.guardian_alert then m:setTarget(game:getPlayer()) end
			ok = true
		end
	else
		print("WARNING: Guardian not found: ", self.guardian)
	end

	if not ok and self.abord_no_guardian then self.level.force_recreate = true end
end

function _M:generateOne()
	local f = nil
	if self.filters then f = self.filters[rng.range(1, #self.filters)] end
	local m = self.zone:makeEntity(self.level, "actor", f, nil, true)
	if m then
		local x, y = rng.range(self.area.x1, self.area.x2), rng.range(self.area.y1, self.area.y2)
		local tries = 0
		while (not m:canMove(x, y) or (self.map.room_map[x][y] and self.map.room_map[x][y].special)) and tries < 100 do
			x, y = rng.range(self.area.x1, self.area.x2), rng.range(self.area.y1, self.area.y2)
			tries = tries + 1
		end
		if tries < 100 then
			self.zone:addEntity(self.level, m, "actor", x, y)
			if self.post_generation then self.post_generation(m) end
		end
	end
end

function _M:regenFrom(current)
	for i = current, rng.range(self.nb_npc[1], self.nb_npc[2]) do
		self:generateOne()
	end
end
