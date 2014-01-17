-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	blood_color = colors.GREY,
	display = "a", color=colors.WHITE,
	body = { INVEN = 10 },
	sound_moam = {"creatures/ants/ant_%d", 1, 2},
	sound_die = {"creatures/ants/ant_die_%d", 1, 4},
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=12, dex=10, mag=3, con=13 },
	energy = { mod=1 },
	combat_armor = 1, combat_def = 1,
	combat = { dam=resolvers.levelup(resolvers.rngavg(5,5), 1, 1), atk=15, apr=7, dammod={str=0.6}, sound="creatures/ants/ant_hit" },
	infravision = 10,
	max_life = resolvers.rngavg(10,20),
	rank = 1,
	size_category = 1,
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant white ant", color=colors.WHITE, image="npc/white_ant.png",
	desc = "It's a large white ant.",
	level_range = {1, 15}, exp_worth = 1,
	rarity = 1,
	global_speed_base = 1.1,
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant brown ant", color=colors.UMBER, image="npc/brown_ant.png",
	desc = "It's a large brown ant.",
	level_range = {1, 15}, exp_worth = 1,
	rarity = 1,
	global_speed_base = 0.9,
	max_life = resolvers.rngavg(15,30),
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant carpenter ant", color=colors.BLACK, image="npc/carpenter_ant.png",
	desc = "It's a large black ant with huge mandibles.",
	level_range = {2, 25}, exp_worth = 1,
	rarity = 1,
	combat = { dam=6 },
	movement_speed = 1.3,
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant green ant", color=colors.GREEN, image="npc/green_ant.png",
	desc = "It's a large green ant.",
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	combat = { DamageType.POISON },
	talent_cd_reduction = {[Talents.T_BITE_POISON]=-10},
	resolvers.talents{
		[Talents.T_BITE_POISON]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant red ant", color=colors.RED, image="npc/red_ant.png",
	desc = "It's a large red ant.",
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	combat = { damtype=DamageType.FIRE },
	talent_cd_reduction = {[Talents.T_FLAME_FURY]=-10},
	resolvers.talents{
		[Talents.T_FLAME_FURY]={base=0, every=10},
	},
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant blue ant", color=colors.BLUE, image="npc/blue_ant.png",
	desc = "It's a large blue ant.",
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	combat = { damtype=DamageType.COLD },
	talent_cd_reduction = {[Talents.T_WATER_BOLT]=-12},
	resolvers.talents{
		[Talents.T_WATER_BOLT]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant yellow ant", color=colors.YELLOW, image="npc/yellow_ant.png",
	desc = "It's a large yellow ant.",
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	combat = { damtype=DamageType.LIGHTNING },
	talent_cd_reduction = {[Talents.T_LIGHTNING_SPEED] = -14},
	resolvers.talents{
		[Talents.T_LIGHTNING_SPEED]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant black ant", color=colors.BLACK, image="npc/black_ant.png",
	desc = "It's a large black ant.",
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	combat = { damtype=DamageType.ACID },
	talent_cd_reduction = {[Talents.T_CRAWL_ACID]=-13},
	resolvers.talents{
		[Talents.T_CRAWL_ACID]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant fire ant", color=colors.RED, image="npc/fire_ant.png",
	desc = "It's a large red ant, wreathed in flames.",
	level_range = {15, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(20,40),
	combat = { damtype=DamageType.FIRE },
	combat_armor = 5, combat_def = 5,
	on_melee_hit = {[DamageType.FIRE]=5},
	talent_cd_reduction = {[Talents.T_FLAME_FURY]=-6},
	resolvers.talents{
		[Talents.T_RITCH_FLAMESPITTER_BOLT]={base=1, every=10},
		[Talents.T_FLAME_FURY]={base=2, every=10},
	},
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant ice ant", color=colors.WHITE, image="npc/ice_ant.png",
	desc = "It's a large white ant. The air is frigid around it.",
	level_range = {15, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(20,40),
	combat = { damtype=DamageType.ICE },
	combat_armor = 5, combat_def = 5,
	on_melee_hit = {[DamageType.ICE]=5},
	talent_cd_reduction = {[Talents.T_WATER_BOLT]=-7},
	resolvers.talents{
		[Talents.T_WATER_BOLT]={base=2, every=10},
		[Talents.T_ICY_SKIN]={base=2, every=10},
	},
	ingredient_on_death = "FROST_ANT_STINGER",
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant lightning ant", color=colors.YELLOW, image="npc/lightning_ant.png",
	desc = "It's a large yellow ant with sparks arcing across its body.",
	level_range = {15, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(20,40),
	combat = { damtype=DamageType.LIGHTNING },
	combat_armor = 5, combat_def = 5,
	on_melee_hit = {[DamageType.LIGHTNING]=5},
	talent_cd_reduction = {[Talents.T_CALL_LIGHTNING] = -7},
	resolvers.talents{
		[Talents.T_LIGHTNING_SPEED]={base=2, every=10},
		[Talents.T_CALL_LIGHTNING]={base=2, every=10},
	},
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant acid ant", color=colors.DARK_GREY, image="npc/acid_ant.png",
	desc = "It's a large black ant.  Its porous skin oozes acid.",
	level_range = {15, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(20,40),
	combat = { damtype=DamageType.ACID },
	combat_armor = 5, combat_def = 5,
	on_melee_hit = {[DamageType.ACID]=5},
	talent_cd_reduction = {[Talents.T_ACIDIC_SPRAY]=-7},
	resolvers.talents{
		[Talents.T_CRAWL_ACID]={base=2, every=10},
		[Talents.T_ACIDIC_SPRAY]={base=1, every=10},
	},
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant army ant", color=colors.ORANGE, image="npc/army_ant.png",
	desc = "It's a large ant with a heavy exoskeleton, geared for war.",
	level_range = {18, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(50,60),
	combat_armor = 15, combat_def = 7,
	resolvers.inscriptions(1, "infusion"),
	resolvers.talents{
		[Talents.T_STUN]={base=2, every=8, max=5},
		[Talents.T_DISARM]={base=1, every=8, max=5},
	},
}

newEntity{ base = "BASE_NPC_ANT",
	name = "Queen Ant", color=colors.VIOLET, unique=true, female = 1,
	desc = "Queen of the ants, queen of the biting death!",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/insect_ant_queen_ant.png", display_h=2, display_y=-1}}},
	level_range = {25, nil}, exp_worth = 2,
	rank = 3.5,
	size_category = 3,
	rarity = 50,
	max_life = 230, life_rating=12,
	combat_armor = 18, combat_def = 7,
	resolvers.drops{chance=100, nb=12, {type="money"} },
	resolvers.inscriptions(2, "infusion"),
	make_escort = {
		{type="insect", subtype="ant", number=resolvers.mbonus(5, 5)},
	},
	summon = {
		{type="insect", subtype="ant", number=2, hasexp=false},
	},
	resolvers.talents{
		[Talents.T_SLIME_SPIT]={base=3, every=5},
		[Talents.T_BITE_POISON]={base=3, every=5},
		[Talents.T_GRAB]={base=3, every=5},
		[Talents.T_STUN]={base=3, every=5},
		[Talents.T_ACIDIC_SPRAY]={base=3, every=10},
		[Talents.T_ACIDIC_SKIN]={base=5, every=10},
		[Talents.T_SUMMON]=1,
	},

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",
}
