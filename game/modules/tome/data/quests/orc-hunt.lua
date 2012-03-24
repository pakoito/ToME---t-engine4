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

-- Orc Hunting
name = "Let's hunt some Orc"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "The elder in Last Hope sent you to the old Dwarven kingdom of Reknor, deep under the Iron Throne, to investigate the orc presence."
	desc[#desc+1] = "Find out if they are in any way linked to the lost staff."
	desc[#desc+1] = "But be careful -- even the Dwarves have not ventured in these old halls for many years."
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal reknor entrance
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "REKNOR")
		local spot = level:pickSpot{type="zone-pop", subtype="reknor"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)
	end)
	game.logPlayer(game.player, "The elder points to Reknor on your map, to the north on the western side of the Iron Throne.")
end
