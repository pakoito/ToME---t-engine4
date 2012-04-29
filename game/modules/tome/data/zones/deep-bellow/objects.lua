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

load("/data/general/objects/objects-maj-eyal.lua")

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "Deep Bellow excavation report "..i, lore="deep-bellow-"..i,
	desc = [[A paper scrap.]],
	rarity = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_LORE",
	define_as = "ADV_LTR_6",
	name = "letter to Rolf (3)", lore="adventurer-letter-6",
	desc = [[A paper scrap.]],
	rarity = false,
}
newEntity{ base = "BASE_LORE",
	define_as = "ADV_LTR_7",
	name = "letter to Weisman (4)", lore="adventurer-letter-7",
	desc = [[A paper scrap.]],
	rarity = false,
}
newEntity{ base = "BASE_LORE",
	define_as = "ADV_LTR_8",
	name = "Last Will of Rolf", lore="adventurer-letter-8",
	desc = [[A paper scrap.]],
	rarity = false,
}
