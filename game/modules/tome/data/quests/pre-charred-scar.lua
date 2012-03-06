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

name = "Important news"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Orcs were spotted with the staff you seek in an arid waste in the southern desert."
	desc[#desc+1] = "You should go investigate what is happening there."
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	local aeryn = {name="High Sun Paladin Aeryn"}
	local chat = engine.Chat.new("pre-charred-scar", aeryn, who)
	chat:invoke()

	-- Reveal entrance
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "ERUAN")
		local spot = level:pickSpot{type="zone-pop", subtype="eruan"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
	end)
	game.logPlayer(game.player, "Aeryn explained where the orcs were spotted.")
end
