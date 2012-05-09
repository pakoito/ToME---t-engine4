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

-- last updated:  10:00 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_JELLY",
	type = "immovable", subtype = "jelly",
	display = "j", color=colors.WHITE,
	sound_moam = {"creatures/jelly/jelly_%d", 1, 3},
	sound_die = {"creatures/jelly/jelly_die_%d", 1, 2},
	sound_random = {"creatures/jelly/jelly_%d", 1, 3},
	desc = "A strange blob on the dungeon floor.",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	stats = { str=10, dex=15, mag=3, con=10 },
	combat = {sound="creatures/jelly/jelly_hit"},
	combat_armor = 1, combat_def = 1,
	never_move = 1,
	rank = 2,
	blind_immune = 1,
	poison_immune = 1,
	size_category = 3,
	infravision = 10,
	no_breath = 1,
	no_breath = 1,

	drops = resolvers.drops{chance=60, nb=1, {type="money"} },

	resists = { [DamageType.LIGHT] = -50 },
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "green jelly", color=colors.GREEN, image="npc/jelly-green.png",
	blood_color = colors.GREEN,
	desc = "A strange green blob on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.POISON },
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "red jelly", color=colors.RED, image="npc/jelly-red.png",
	blood_color = colors.RED,
	desc = "A strange red blob on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.FIRE },
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "blue jelly", color=colors.BLUE, image="npc/jelly-blue.png",
	blood_color = colors.BLUE,
	desc = "A strange blue blob on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.COLD },
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "white jelly", color=colors.WHITE, image="npc/jelly-white.png",
	blood_color = colors.WHITE,
	desc = "A strange white blob on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5 },
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "yellow jelly", color=colors.YELLOW, image="npc/jelly-yellow.png",
	blood_color = colors.YELLOW,
	desc = "A strange yellow blob on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.LIGHTNING },
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "black jelly", color=colors.DARK_GREY, image="npc/jelly-darkgrey.png",
	blood_color = colors.DARK_GREY,
	desc = "A strange black blob on the dungeon floor.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.ACID },
}

newEntity{ base = "BASE_NPC_JELLY",
	unique = true,
	name = "Malevolent Dimensional Jelly", color=colors.VIOLET, image="npc/jelly-darkgrey.png",
	blood_color = colors.VIOLET,
	desc = "A strange black blob on the dungeon floor; through it you seem to be able to see other times and places. As you stare you see things moving out of it.",
	level_range = {25, nil}, exp_worth = 1,
	rarity = 50,
	max_life = resolvers.rngavg(50,90), life_rating = 5,
	combat = { dam=5, atk=15, apr=5, damtype=DamageType.DARKNESS },
	summon = {
		{number=1, hasexp=false},
	},
	-- Nullify their cooldowns
	talent_cd_reduction={[Talents.T_SUMMON]=4,},
	resolvers.talents{ [Talents.T_SUMMON]=1,},
}
