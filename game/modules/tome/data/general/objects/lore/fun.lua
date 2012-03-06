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

newEntity{ base = "BASE_LORE_RANDOM",
	name = "trollish poem", lore="troll-poem", unique=true,
	desc = [[A poem written by a... troll?]],
	level_range = {1, 50},
	rarity = 40,
	encumber = 0,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "necromancer poem", lore="necromancer-poem", unique=true,
	desc = [[A poem written by a... Necromancer?]],
	level_range = {15, 50},
	rarity = 40,
	encumber = 0,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "rogues do it from behind", lore="rogue-poem", unique=true,
	desc = [[A poem written for a rogue?]],
	level_range = {15, 50},
	rarity = 40,
	encumber = 0,
}

for i = 1, 4 do
newEntity{ base = "BASE_LORE_RANDOM",
	name = "how to become a necromancer, part "..i, lore="necromancer-primer-"..i, unique=true,
	desc = [[How to become a powerful Necromancer!]],
	level_range = {15, 50},
	rarity = 40,
}
end

newEntity{ base = "BASE_LORE_RANDOM",
	name = [["Dust to Dust", an undead hunter's guide, by Aslabor Borys]], lore="dust-to-dust", unique=true,
	desc = [[An undead hunter's guide, by Aslabor Borys]],
	level_range = {15, 50},
	rarity = 60,
}

for i = 1, 5 do
local who
if i == 1 then who = "Rolf" nb = 1
elseif i == 2 then who = "Weisman" nb = 1
elseif i == 3 then who = "Rolf" nb = 2
elseif i == 4 then who = "Weisman" nb = 2
elseif i == 5 then who = "Weisman" nb = 3
end
newEntity{ base = "BASE_LORE_RANDOM",
	name = "letter to "..who.."("..nb..")", lore="adventurer-letter-"..i, unique=true,
	desc = [[A part of the correspondance between two adventurers]],
	level_range = {1, 20},
	rarity = 20,
	bloodstains = (i == 5) and 2 or nil,
}
end

newEntity{ base = "BASE_LORE_RANDOM",
	name = "of halfling feet", lore="halfling-feet", unique=true,
	desc = [[Notes about .. halfling feet ??]],
	level_range = {10, 30},
	rarity = 40,
	encumber = 0,
}
