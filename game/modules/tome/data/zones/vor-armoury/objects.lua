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

load("/data/general/objects/objects-far-east.lua")

newEntity{ define_as = "ATHAME",
	quest=true, unique=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="misc",
	unided_name = "athame",
	name = "Blood-Runed Athame", image = "object/artifact/blood_runed_athame.png",
	level_range = {50, 50},
	display = "|", color=colors.VIOLET,
	encumber = 1,
	desc = [[An athame, covered in blood runes. It radiates power.]],

	on_pickup = function(self, who)
		if who == game.player then
			who:setQuestStatus("west-portal", engine.Quest.COMPLETED, "athame")
			return true
		end
	end,
}
