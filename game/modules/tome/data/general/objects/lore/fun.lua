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

newEntity{ base = "BASE_LORE",
	name = "trollish poem", lore="troll-poem", unique=true,
	desc = [[A poem written by a... troll?]],
	level_range = {1, 50},
	rarity = 20,
	encumber = 0,
}

newEntity{ base = "BASE_LORE",
	name = "necromancer poem", lore="necromancer-poem", unique=true,
	desc = [[A poem written by a... Necromancer?]],
	level_range = {15, 50},
	rarity = 20,
	encumber = 0,
}
