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

load("/data/general/grids/basic.lua")
load("/data/general/grids/lava.lua", function(e) if e.define_as == "LAVA_FLOOR" then
	e.on_stand = function(self, x, y, who)
		if not game.level.allow_demon_plane_damage then return end
		local DT = engine.DamageType
		local dam = DT:get(DT.DEMONFIRE).projector(game.level.plane_owner, x, y, DT.DEMONFIRE, game.level.demonfire_dam or 1)
		if dam then
			if dam > 0 then game.logPlayer(who, "The lava burns you!")
			elseif dam < 0 then game.logPlayer(who, "The lava heals you!") end
		end
	end
end end)
