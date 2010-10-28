-- ToME - Tales of Maj'Eyal
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

name = "Eight legs of wonder"
desc = function(self, who)
	local desc = {}
	if not self:isCompleted() then
		desc[#desc+1] = "Enter the caverns of Ardhungol and clear the source of the spider infestation there."
		desc[#desc+1] = "But be careful, those are not small spiders..."
	else
		desc[#desc+1] = "#LIGHT_GREEN#You have killed Ungolë in Ardhungol, return to High Sun Paladin Aeryn."
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal moria entrance
	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="A way into the carvers of Ardhungol",
		display='>', color=colors.GREEN,
		notice = true,
		change_level=1, change_zone="ardhungol"
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.memory_levels["wilderness-arda-fareast-1"], g, "terrain", 66, 32)
	game.logPlayer(game.player, "High Sun Paladin Aeryn marks the location of Ardhungol on your map.")
end
