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

-- last updated:  10:46 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_ANT",
	type = "insect", subtype = "ant",
	display = "a", color=colors.WHITE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	stats = { str=12, dex=10, mag=3, con=13 },
	energy = { mod=1 },
	combat_armor = 1, combat_def = 1,
	combat = { dam=5, atk=15, apr=7 },
	max_life = resolvers.rngavg(10,20),
	size_category = 1,
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant white ant", color=colors.WHITE,
	desc = "It's a large white ant.",
	level_range = {1, 15}, exp_worth = 1,
	rarity = 4,
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant brown ant", color=colors.UMBER,
	desc = "It's a large brown ant.",
	level_range = {1, 15}, exp_worth = 1,
	rarity = 4,
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant carpenter ant", color=colors.BLACK,
	desc = "It's a large black ant with huge mandibles.",
	level_range = {2, 25}, exp_worth = 1,
	rarity = 4,
	combat = { dam=6 },
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant green ant", color=colors.GREEN,
	desc = "It's a large green ant.",
	level_range = {5, 50}, exp_worth = 1,
	rarity = 4,
	combat = { DamageType.POISON },
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant red ant", color=colors.RED,
	desc = "It's a large red ant.",
	level_range = {5, 50}, exp_worth = 1,
	rarity = 4,
	combat = { damtype=DamageType.FIRE },
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant blue ant", color=colors.BLUE,
	desc = "It's a large blue ant.",
	level_range = {5, 50}, exp_worth = 1,
	rarity = 4,
	combat = { damtype=DamageType.COLD },
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant yellow ant", color=colors.YELLOW,
	desc = "It's a large yellow ant.",
	level_range = {5, 50}, exp_worth = 1,
	rarity = 4,
	combat = { damtype=DamageType.LIGHTNING },
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant black ant", color=colors.BLACK,
	desc = "It's a large black ant.",
	level_range = {5, 50}, exp_worth = 1,
	rarity = 4,
	combat = { damtype=DamageType.ACID },
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant fire ant", color=colors.RED,
	desc = "It's a large red ant, wreathed in flames.",
	level_range = {15, 50}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(20,40),
	combat = { damtype=DamageType.FIRE },
	combat_armor = 5, combat_def = 5,
	on_melee_hit = {[DamageType.FIRE]=5},
	}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant ice ant", color=colors.WHITE,
	desc = "It's a large white ant. The air is frigid around this ant.",
	level_range = {15, 50}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(20,40),
	combat = { damtype=DamageType.ICE },
	combat_armor = 5, combat_def = 5,
	on_melee_hit = {[DamageType.ICE]=5},
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant lightning ant", color=colors.YELLOW,
	desc = "It's a large yellow ant with sparks arching across its body.",
	level_range = {15, 50}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(20,40),
	combat = { damtype=DamageType.LIGHTNING },
	combat_armor = 5, combat_def = 5,
	on_melee_hit = {[DamageType.LIGHTNING]=5},
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant acid ant", color=colors.BLACK,
	desc = "It's a large black ant.  Its porous skin oozes acid.",
	level_range = {15, 50}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(20,40),
	combat = { damtype=DamageType.ACID },
	combat_armor = 5, combat_def = 5,
	on_melee_hit = {[DamageType.ACID]=5},
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant army ant", color=colors.ORANGE,
	desc = "It's a large ant with a heavy exoskeleton, geared for war.",
	level_range = {18, 50}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(50,60),
	combat_armor = 15, combat_def = 7,
}
