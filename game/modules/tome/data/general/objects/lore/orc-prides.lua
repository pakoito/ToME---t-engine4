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

-- Randomly found only in the prides

for i = 1, 5 do
newEntity{ base = "BASE_LORE",
	define_as = "ORC_HISTORY"..i,
	name = "Records of Lorekeeper Hadak", lore="orc-history-"..i, unique="Records of Lorekeeper Hadak "..i,
	desc = [[Part of the long history of the Orc race.]],
	level_range = {1, 50},
	rarity = 40,
	is_magic_device = false,
	encumber = 0,
}
end
