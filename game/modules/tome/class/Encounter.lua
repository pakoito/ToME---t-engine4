-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
require "engine.Entity"

module(..., package.seeall, class.inherit(engine.Entity))

function _M:init(t, no_default)
	assert(t.coords, "no encounter coords")
	assert(t.level_range, "no encounter level_range")
	assert(t.on_encounter, "no encounter on_encounter")

	engine.Entity.init(self, t, no_default)

	self:parseCoords()
end

function _M:parseCoords()
	self.on_map = {}
	for i, coord in ipairs(self.coords) do
		if coord.likelymap then
			for y, line in ipairs(coord.likelymap) do
				local i = 1
				for c in line:gmatch(".") do
					if c ~= ' ' then
						self.on_map[(coord.x+i-1).."x"..(coord.y+y-1)] = tonumber(c)
						print("coords", (coord.x+i-1).."x"..(coord.y+y-1), tonumber(c))
					end
					i = i + 1
				end
			end
		elseif coord.w and coord.h then
			for y = 1, coord.h do
				for i = 1, coord.w do
					self.on_map[(coord.x+i-1).."x"..(coord.y+y-1)] = 1
				end
			end
		end
	end
end

function _M:checkFilter(filter)
	if filter.special_filter and not filter.special_filter(self) then return false end

	if filter.mapx and filter.mapy then
		if not self.on_map[filter.mapx.."x"..filter.mapy] then return false end
	end
	return true
end

function _M:findSpot(who, what)
	what = what or "block_move"
	local spots = {}
	for i = -1, 1 do for j = -1, 1 do if i ~= 0 or j ~= 0 then
		if not game.level.map:checkAllEntities(who.x + i, who.y + j, what, who) then
			spots[#spots+1] = {who.x + i, who.y + j}
		end
	end end end
	if #spots > 0 then
		local s = rng.table(spots)
		return s[1], s[2]
	end
end
