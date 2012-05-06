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
require "engine.Generator"
local Random = require "mod.class.generator.actor.Random"

--- Very specialized generator that puts sandworms in interesting spots to dig tunnels
module(..., package.seeall, class.inherit(Random))

function _M:init(zone, map, level, spots)
	Random.init(self, zone, map, level, spots)
end

function _M:generate()
	-- Add a guard on the stairs, except on the last level
	local data = self.level.data.generator.actor
	local glevel = self.zone.max_level
	if self.level.level < glevel and self.level.default_down and data.guard and (not data.guard_test or data.guard_test(self.level)) then
		local m = self.zone:makeEntity(self.level, "actor", rng.table(data.guard), nil, true)
		if m then
			local x, y = util.findFreeGrid(self.level.default_down.x, self.level.default_down.y, 5, true, {[Map.ACTOR]=true})
			if x and y then
				m.no_decay = true
				self.zone:addEntity(self.level, m, "actor", x, y)
				print("[RANDOM STAIR GUARD] placed guard", m.name)
			end
		end
	end

	-- Make the random generator place normal actors
	Random.generate(self)
end
