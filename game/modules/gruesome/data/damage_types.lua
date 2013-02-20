-- ToME - Tales of Middle-Earth
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

-- The basic stuff used to damage a grid
setDefaultProjector(function(src, x, y, type, dam)
	return 0
end)

newDamageType{
	name = "darkness", type = "DARKNESS", text_color = "#GREY#",
	projector = function(src, x, y, typ, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not target.player then
			target:attr("blind", 1)
			game.logPlayer(src, "The adventurer screams in fright as %s %s is extinguished.", target.sex, target.angle < 35 and "lantern" or "torch")
		end
	end,
}
