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
local DamageType = require "engine.DamageType"
require "engine.Generator"

module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, spots)
	engine.Generator.init(self, zone, map, level, spots)
	self.data = level.data.generator.actor
	self.level = level
	self.rate = self.data.rate
	self.max_rate = 5
	self.turn_scale = game.energy_per_tick / game.energy_to_act

	if not _M.limmir then
		for i, e in pairs(level.entities) do
			if e.define_as and e.define_as == "LIMMIR" then _M.limmir = e break end
		end
	end
end

function _M:tick()
	local val = rng.float(0,1)
	for i = 1,self.max_rate - 1 do
		if val < rng.poissonProcess(i, self.turn_scale, self.rate) then
			self:generateOne()
		else
			break
		end
	end

	-- Fire a light AOE, healing allies damaging demons
	if _M.limmir and not _M.limmir.dead and game.turn % 100 == 0 then
		game.logSeen(_M.limmir, "Limmir summons a blast of holy light!")
		local rad = 2
		local dam = 50 + (800 - self.level.turn_counter / 10) / 7
		local grids = _M.limmir:project({type="ball", radius=rad, selffire=false}, _M.limmir.x, _M.limmir.y, DamageType.HOLY_LIGHT, dam)
		game.level.map:particleEmitter(_M.limmir.x, _M.limmir.y, rad, "sunburst", {radius=rad, grids=grids, tx=_M.limmir.x, ty=_M.limmir.y})
	end
end

function _M:generateOne()
	local m
	if not self.level.balroged and self.level.turn_counter < 100 * 10 then
		m = self.zone:makeEntityByName(self.level, "actor", "CORRUPTED_DAELACH")
		self.level.balroged = true
	else
		m = self.zone:makeEntity(self.level, "actor", {type="demon"}, nil, true)
	end

	if m then
		local spot = self.level:pickSpot{type="portal", subtype="demon"}
		local x = spot.x
		local y = spot.y
		local tries = 0
		while (not m:canMove(x, y)) and tries < 10 do
			spot = self.level:pickSpot{type="portal", subtype="demon"}
			x = spot.x y = spot.y
			tries = tries + 1
		end
		if tries < 10 then
			if _M.limmir and not _M.limmir.dead then
				m:setTarget(_M.limmir)
			else
				m:setTarget(game.player)
			end
			self.zone:addEntity(self.level, m, "actor", x, y)
		end
	end
end
