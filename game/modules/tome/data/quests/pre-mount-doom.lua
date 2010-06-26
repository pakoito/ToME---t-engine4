-- ToME - Tales of Middle-Earth
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

name = "Important news"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = ""
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	local aeryn = {name="High Sun Paladin Aeryn"}
	local chat = engine.Chat.new("pre-mount-doom", aeryn, who)
	chat:invoke()

	-- Reveal  entrance
	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="The arid wastes of Erúan",
		display='>', color=colors.UMBER,
		notice = true,
		change_level=1, change_zone="eruan"
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.memory_levels["wilderness-arda-fareast-1"], g, "terrain", 56, 51)
	game.logPlayer(game.player, "Aeryn explained where the cave is located.")
end
