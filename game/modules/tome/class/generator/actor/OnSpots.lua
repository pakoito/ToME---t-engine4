-- ToME - Tales of Maj'Eyal
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
local OnSpots = require "engine.generator.actor.OnSpots"
module(..., package.seeall, class.inherit(OnSpots))

function _M:init(zone, map, level, spots)
	OnSpots.init(self, zone, map, level, spots)
	local data = level.data.generator.actor
	self.randelite = data.randelite or 25
end

function _M:generateOne()
	local f = nil
	if self.filters then f = self.filters[rng.range(1, #self.filters)] end
	if self.randelite > 0 and rng.chance(self.randelite) and self.zone:level_adjust_level(self.level, "actor") > 3 and game.difficulty ~= game.DIFFICULTY_EASY then
		print("Random elite generating")
		if not f then f = {} else f = table.clone(f, true) end
		f.random_elite = f.random_elite or true
	end
	local m = self.zone:makeEntity(self.level, "actor", f, nil, true)
	if m then
		local x, y = self:getSpawnSpot(m)
		if x and y then
			self.zone:addEntity(self.level, m, "actor", x, y)
			if self.post_generation then self.post_generation(m) end
		end
	end
end
