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
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
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
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant brown ant", color=colors.UMBER, image="npc/brown_ant.png",
	desc = "It's a large brown ant.",
	level_range = {1, 15}, exp_worth = 1,
	rarity = 1,
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant carpenter ant", color=colors.BLACK, image="npc/carpenter_ant.png",
	desc = "It's a large black ant with huge mandibles.",
	level_range = {2, 25}, exp_worth = 1,
	rarity = 1,
	combat = { dam=6 },
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant green ant", color=colors.GREEN, image="npc/green_ant.png",
	desc = "It's a large green ant.",
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	combat = { DamageType.POISON },
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant red ant", color=colors.RED, image="npc/red_ant.png",
	desc = "It's a large red ant.",
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	combat = { damtype=DamageType.FIRE },
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant blue ant", color=colors.BLUE, image="npc/blue_ant.png",
	desc = "It's a large blue ant.",
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	combat = { damtype=DamageType.COLD },
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant yellow ant", color=colors.YELLOW, image="npc/yellow_ant.png",
	desc = "It's a large yellow ant.",
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	combat = { damtype=DamageType.LIGHTNING },
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant black ant", color=colors.BLACK, image="npc/black_ant.png",
	desc = "It's a large black ant.",
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	combat = { damtype=DamageType.ACID },
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
}

newEntity{ base = "BASE_NPC_ANT",
	name = "giant army ant", color=colors.ORANGE, image="npc/army_ant.png",
	desc = "It's a large ant with a heavy exoskeleton, geared for war.",
	level_range = {18, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(50,60),
	combat_armor = 15, combat_def = 7,
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
	make_escort = {
		{type="insect", subtype="ant", number=resolvers.mbonus(5, 5)},
	},
	summon = {
		{type="insect", subtype="ant", number=2, hasexp=false},
	},
	resolvers.talents{ [Talents.T_STUN]=3, [Talents.T_ACIDIC_SKIN]=5, [Talents.T_SUMMON]=1,},

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",
}
