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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_ADVENTURER",
	type = "humanoid", subtype = "adventurer",
	display = "@", color=colors.WHITE,
	desc = [[Tasty adventurer! Yummy!]],
	name = "adventurer",

	rarity = 1,
	ai = "adventurer",
	sex = "him",
}

newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {1, nil},
	color=colors.DARK_BLUE,
	lite = 2, angle = 25,
}
newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {1, nil},
	color=colors.DARK_GREEN,
	lite = 2, angle = 40,
}
newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {1, nil},
	color=colors.TEAL,
	lite = 2, angle = 60,
}

newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {1, nil},
	color=colors.RED,
	lite = 3, angle = 25,
}
newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {1, nil},
	color=colors.SALMON,
	lite = 3, angle = 75,
	sex = "her",
}
newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {1, nil},
	color=colors.DARK_UMBER,
	lite = 3, angle = 50,
}

newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {1, nil},
	color=colors.LIGHT_GREY,
	lite = 4, angle = 25,
}
newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {1, nil},
	color=colors.DARk_GREY,
	lite = 4, angle = 40,
}
newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {1, nil},
	color=colors.LIGHT_BLUE,
	lite = 4, angle = 55,
}
newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {1, nil},
	color=colors.LIGHT_GREEN,
	lite = 4, angle = 70,
}

newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {13, nil},
	color=colors.AQUAMARINE,
	lite = 5, angle = 25,
}
newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {13, nil},
	color=colors.LIGHT_RED,
	lite = 5, angle = 35,
	sex = "her",
}
newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {13, nil},
	color=colors.YELLOW,
	lite = 5, angle = 50,
	sex = "her",
}
newEntity{ base = "BASE_NPC_ADVENTURER",
	level_range = {13, nil},
	color=colors.WHITE,
	lite = 5, angle = 65,
}
