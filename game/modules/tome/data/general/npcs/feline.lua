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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_CAT",
	display = "c",
	stats = { str=10, dex=20, mag=3, cun=18, con=6 },
	autolevel = "rogue",
	size_category = 2,
	rank = 2,
	infravision = 10,
	global_speed_base = 1.25,
	type = "animal", subtype="feline",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },

	combat_physspeed = 2, -- Double attack per turn

	resolvers.sustains_at_birth(),
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_CAT",
	name = "snow cat", color=colors.GRAY,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/animal_feline_snow_cat.png", display_h=2, display_y=-1}}},
	desc = [[A large cat with a grey fur matted with black.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(40,80),
	resists = { [DamageType.COLD] = 50 },
	combat_armor = 0, combat_def = 8,
	combat = { dam=resolvers.levelup(5, 1, 0.7), atk=12, apr=15, dammod={str=0.5, dex=0.5}},
	resolvers.talents{
		[Talents.T_STEALTH]={base=1, every=6, max=5},
		[Talents.T_RUSH]={base=1, every=8, max=3},
		[Talents.T_LETHALITY]={base=1, every=8, max=5},
	},
}

newEntity{ base = "BASE_NPC_CAT",
	name = "panther", color=colors.BLACK,
	desc = [[A large black cat, slender and muscular.]],
	level_range = {8, nil}, exp_worth = 1,
	rarity = 4,
	size_category=3,
	max_life = resolvers.rngavg(60,100),
	combat_armor = 3, combat_def = 8,
	combat = { dam=resolvers.levelup(18, 1, 1), atk=12, apr=20, dammod={str=0.5, dex=0.5}},
	resolvers.talents{
		[Talents.T_STEALTH]={base=1, every=6, max=5},
		[Talents.T_RUSH]={base=1, every=8, max=3},
		[Talents.T_LETHALITY]={base=1, every=8, max=5},
	},
}

newEntity{ base = "BASE_NPC_CAT",
	name = "tiger", color=colors.YELLOW,
	desc = [[A truly magnificent beast, with fur striped black and yellow.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 4,
	size_category=4,
	max_life = resolvers.rngavg(70,110),
	combat_armor = 3, combat_def = 8,
	combat = { dam=resolvers.levelup(25, 1, 1), atk=12, apr=25, dammod={str=0.5, dex=0.5}},
	resolvers.talents{
		[Talents.T_STEALTH]={base=2, every=6, max=5},
		[Talents.T_RUSH]={base=2, every=8, max=5},
		[Talents.T_LETHALITY]={base=2, every=8, max=5},
		[Talents.T_HIDE_IN_PLAIN_SIGHT]={base=10, every=8, max=5},
	},
}

newEntity{ base = "BASE_NPC_CAT",
	name = "sabertooth tiger", color=colors.YELLOW,
	desc = [[This cat is simply enormous, and has fangs with the size and sharpness of short swords.]],
	level_range = {16, nil}, exp_worth = 1,
	rarity = 4,
	size_category=4,
	max_life = resolvers.rngavg(80,120),
	combat_armor = 3, combat_def = 8,
	combat = { dam=resolvers.levelup(28, 1, 1), atk=12, apr=35, dammod={str=0.5, dex=0.5}},
	resolvers.talents{
		[Talents.T_STEALTH]={base=3, every=6, max=5},
		[Talents.T_RUSH]={base=3, every=8, max=5},
		[Talents.T_LETHALITY]={base=3, every=8, max=5},
		[Talents.T_CRIPPLE]={base=3, every=8, max=5},
		[Talents.T_DEADLY_STRIKES]={base=3, every=8, max=5},
	},
}
