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

--updated: 7:59 AM 1/30/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_BEAR",
	type = "animal", subtype = "bear",
	display = "q", color=colors.WHITE,
	body = { INVEN = 10 },
	sound_moam = {"creatures/bears/bear_moan_%d", 1, 2},
	sound_die = {"creatures/bears/bear_moan_%d", 3, 4},
	sound_random = {"creatures/bears/bear_growl_%d", 1, 3},

	max_stamina = 100,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=5, },
	global_speed_base = 0.9,
	stats = { str=18, dex=13, mag=5, con=15 },
	infravision = 10,
	rank = 2,
	size_category = 4,

	combat_armor = 1, combat_def = 1,
	combat = { dam=resolvers.levelup(resolvers.rngavg(12, 25), 1, 1), atk=10, apr=3, physspeed=2, dammod={str=0.8} },
	life_rating = 12,
	resolvers.tmasteries{ ["technique/other"]=0.25 },

	resists = { [DamageType.FIRE] = 20, [DamageType.COLD] = 20, [DamageType.NATURE] = 20 },
	ingredient_on_death = "BEAR_PAW",
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_BEAR",
	name = "brown bear", color=colors.UMBER, image = "npc/brown_bear.png",
	desc = [[The weakest of bears, covered in brown shaggy fur.]],
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(80,90),
	combat_armor = 7, combat_def = 3,
	resolvers.talents{ [Talents.T_STUN]=1 },
}

newEntity{ base = "BASE_NPC_BEAR",
	name = "black bear", color={50,50,50}, image = "npc/black_bear.png",
	desc = [[Do you smell like honey? 'Cause this bear wants honey.]],
	level_range = {6, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 8, combat_def = 3,
	resolvers.talents{ [Talents.T_STUN]=1 },
}

newEntity{ base = "BASE_NPC_BEAR",
	name = "cave bear", color=colors.DARK_SLATE_GRAY, image = "npc/cave_bear.png",
	desc = [[It has come down from its cave foraging for food. Unfortunately, it found you.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(100,110),
	combat_armor = 9, combat_def = 4,
	combat = { dam=resolvers.levelup(resolvers.rngavg(13, 17), 1, 1), atk=7, apr=2, physspeed=2 },
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=2, [Talents.T_KNOCKBACK]=1,},
}

newEntity{ base = "BASE_NPC_BEAR",
	name = "war bear", color=colors.DARK_UMBER, image = "npc/war_bear.png",
	desc = [[Bears with tusks, trained to kill.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 9, combat_def = 4,
	combat = { dam=resolvers.levelup(resolvers.rngavg(13, 17), 1, 1), atk=10, apr=3, physspeed=2 },
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=2, [Talents.T_KNOCKBACK]=1, [Talents.T_DISARM]=3,},
}

newEntity{ base = "BASE_NPC_BEAR",
	name = "grizzly bear", color=colors.LIGHT_UMBER, image = "npc/grizzly_bear.png",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/grizzly_bear.png", display_h=2, display_y=-1}}},
	desc = [[A huge, beastly bear, more savage than most of its kind.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(110,120),
	combat_armor = 10, combat_def = 5,
	combat = { dam=resolvers.levelup(resolvers.rngavg(15, 20), 1, 1), atk=10, apr=3, physspeed=2 },
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=3, [Talents.T_KNOCKBACK]=2, [Talents.T_DISARM]=3,},
}

newEntity{ base = "BASE_NPC_BEAR",
	name = "polar bear", color=colors.WHITE, image = "npc/polar_bear.png",
	desc = [[This huge white bear has wandered south in search of food.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(110,120),
	combat_armor = 10, combat_def = 7,
	combat = { dam=resolvers.levelup(resolvers.rngavg(15, 20), 1, 1), atk=12, apr=3, physspeed=2 },
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=3, [Talents.T_KNOCKBACK]=2, [Talents.T_DISARM]=3,},
	resists = { [DamageType.COLD] = 100, },
}
