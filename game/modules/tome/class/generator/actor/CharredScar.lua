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

module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, spots)
	engine.Generator.init(self, zone, map, level, spots)
	self.data = level.data.generator.actor
	self.level = level
	self.rate = self.data.rate
	self.max_rate = 5
	self.turn_scale = game.energy_per_tick / game.energy_to_act
end

function _M:tick()
	if self.level.nb_attackers >= self.data.max_attackers then return end

	local val = rng.float(0,1)
	for i = 1,self.max_rate - 1 do
		if val < rng.poissonProcess(i, self.turn_scale, self.rate) then
			self:generateOne()
		else
			break
		end
	end
end

function _M:generateOne()
	local m = self.zone:makeEntityByName(self.level, "actor", "ORC_ATTACK")
	if m then
		local x = rng.range(3, 8)
		local y = 0
		local tries = 0
		while (not m:canMove(x, y)) and tries < 10 do
			x = rng.range(3, 8)
			tries = tries + 1
		end
		if tries < 10 then
			self.zone:addEntity(self.level, m, "actor", x, y)
		end
	end
end
