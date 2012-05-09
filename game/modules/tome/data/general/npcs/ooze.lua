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

-- last updated:  9:54 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_OOZE",
	type = "vermin", subtype = "oozes",
	display = "j", color=colors.WHITE,
	desc = "It's colorful and it's oozing.",
	sound_moam = {"creatures/jelly/jelly_%d", 1, 3},
	sound_die = {"creatures/jelly/jelly_die_%d", 1, 2},
	sound_random = {"creatures/jelly/jelly_%d", 1, 3},
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	stats = { str=10, dex=15, mag=3, con=10 },
	global_speed_base = 0.7,
	combat = {sound="creatures/jelly/jelly_hit"},
	combat_armor = 1, combat_def = 1,
	rank = 1,
	size_category = 3,
	infravision = 10,
	blind_immune = 1,

	clone_on_hit = {min_dam_pct=15, chance=30},

	resolvers.drops{chance=90, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },

	resists = { [DamageType.LIGHT] = -50, [DamageType.COLD] = -50 },
	fear_immune = 1,
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "green ooze", color=colors.GREEN,
	blood_color = colors.GREEN,
	desc = "It's green and it's oozing.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.POISON },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "red ooze", color=colors.RED,
	blood_color = colors.RED,
	desc = "It's red and it's oozing.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.FIRE },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "blue ooze", color=colors.BLUE,
	blood_color = colors.BLUE,
	desc = "It's blue and it's oozing.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.COLD },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "white ooze", color=colors.WHITE,
	blood_color = colors.WHITE,
	desc = "It's white and it's oozing.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5 },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "yellow ooze", color=colors.YELLOW,
	blood_color = colors.YELLOW,
	desc = "It's yellow and it's oozing.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.LIGHTNING },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "black ooze", color=colors.BLACK,
	blood_color = colors.BLACK,
	desc = "It's black and it's oozing.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.ACID },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "gelatinous cube", color=colors.BLACK,
	desc = [["It is a strange, vast gelatinous structure that assumes cubic proportions as it lines all four walls of the corridors it patrols.
Through its transparent jelly structure you can see treasures it has engulfed, and a few corpses as well. "]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(50,100),
	combat = { dam=resolvers.mbonus(80, 15), atk=15, apr=6, damtype=DamageType.ACID },
	drops = resolvers.drops{chance=90, nb=3, {} },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "crimson ooze", color=colors.CRIMSON,
	blood_color = colors.CRIMSON,
	desc = "It's reddish and it's oozing.",
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	combat = { dam=resolvers.mbonus(110, 15), atk=15, apr=5, damtype=DamageType.FIREBURN },
	clone_on_hit = {min_dam_pct=15, chance=50},
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "brittle clear ooze", color=colors.WHITE,
	blood_color = colors.WHITE,
	desc = "It's translucent and it's oozing.",
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	max_life = resolvers.rngavg(80,90), life_rating = 8,
	combat = { dam=resolvers.mbonus(40, 15), atk=15, apr=5, },
	clone_on_hit = {min_dam_pct=1, chance=50},
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "slimy ooze", color=colors.GREEN,
	blood_color = colors.GREEN,
	desc = "It's very slimy and it's oozing.",
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	combat = { dam=resolvers.mbonus(110, 15), atk=15, apr=5, damtype=DamageType.SLIME },
	clone_on_hit = {min_dam_pct=15, chance=50},

	resolvers.talents{ [Talents.T_SLIME_SPIT]=5 },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "poison ooze", color=colors.LIGHT_GREEN,
	blood_color = colors.LIGHT_GREEN,
	desc = "It's very slimy and it's oozing.",
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	combat = { dam=resolvers.mbonus(110, 15), atk=15, apr=5, damtype=DamageType.POISON },
	clone_on_hit = {min_dam_pct=15, chance=50},

	resolvers.talents{ [Talents.T_POISONOUS_SPORES]=5 },
}

--[[
newEntity{ base = "BASE_NPC_OOZE",
	name = "morphic ooze", color=colors.GREY,
	desc = "Its shape changes every few seconds.",
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	rank = 3,
	max_life = resolvers.rngavg(140,170), life_rating = 11,
	combat = { dam=resolvers.mbonus(110, 15), atk=15, apr=5, damtype=DamageType.ACID },
	clone_on_hit = {min_dam_pct=40, chance=100},

	resolvers.talents{ [Talents.T_OOZE_MERGE]=5 },
}
]]
