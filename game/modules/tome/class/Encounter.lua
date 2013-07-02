-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	assert(t.on_encounter, "no encounter on_encounter")

	engine.Entity.init(self, t, no_default)

	if self.coords then self:parseCoords() end
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
	if self.special_filter and not self.special_filter(self) then return false end

	if filter.mapx and filter.mapy and self.on_map then
		if not self.on_map[filter.mapx.."x"..filter.mapy] then return false end
	end
	if filter.mapx and filter.mapy and self.on_world_encounter then
		local we = game.level.map.attrs(filter.mapx, filter.mapy, "world-encounter")
		if not we or not we[self.on_world_encounter] then return false end
	end
	if self.min_level and game.player.level < self.min_level then return false end
	return true
end

function _M:findSpotGeneric(who, fct)
	if not who then return end
	local spots = {}
	for _, coord in pairs(util.adjacentCoords(who.x, who.y)) do if game.level.map:isBound(coord[1], coord[2]) then
		if fct(game.level.map, coord[1], coord[2]) then
			spots[#spots+1] = {coord[1], coord[2]}
		end
	end end
	if #spots > 0 then
		local s = rng.table(spots)
		return s[1], s[2]
	end
end

function _M:findSpot(who, what)
	if not who then return end
	what = what or "block_move"
	local spots = {}
	for _, coord in pairs(util.adjacentCoords(who.x, who.y)) do if game.level.map:isBound(coord[1], coord[2]) then
		if not game.level.map:checkAllEntities(coord[1], coord[2], what, who) and game.level.map:checkAllEntities(coord[1], coord[2], "can_encounter", who) and not game.level.map:checkAllEntities(coord[1], coord[2], "change_level") then
			spots[#spots+1] = {coord[1], coord[2]}
		end
	end end
	if #spots > 0 then
		local s = rng.table(spots)
		return s[1], s[2]
	end
end
