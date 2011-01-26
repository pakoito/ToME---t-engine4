-- ToME - Tales of Maj'Eyal
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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SKELETON",
	type = "undead", subtype = "skeleton",
	blood_color = colors.GREY,
	display = "s", color=colors.WHITE,

	combat = { dam=1, atk=1, apr=1 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },
	infravision = 20,
	rank = 2,
	size_category = 3,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=4, },
	energy = { mod=1 },
	stats = { str=14, dex=12, mag=10, con=12 },

	resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },

	open_door = true,

	cut_immune = 1,
	blind_immune = 1,
	fear_immune = 1,
	see_invisible = 2,
	undead = 1,
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "degenerated skeleton warrior", color=colors.WHITE, image="npc/degenerated_skeleton_warrior.png",
	level_range = {1, 18}, exp_worth = 1,
	rarity = 1,
	resolvers.equip{ {type="weapon", subtype="greatsword", autoreq=true} },
	max_life = resolvers.rngavg(40,50),
	combat_armor = 5, combat_def = 1,
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "skeleton warrior", color=colors.SLATE, image="npc/skeleton_warrior.png",
	level_range = {3, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 5, combat_def = 1,
	resolvers.equip{ {type="weapon", subtype="greatsword", autoreq=true} },
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUNNING_BLOW]=1, },
	ai_state = { talent_in=1, },
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "skeleton mage", color=colors.LIGHT_RED, image="npc/skeleton_mage.png",
	level_range = {4, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(50,60),
	max_mana = resolvers.rngavg(70,80),
	combat_armor = 3, combat_def = 1,
	stats = { str=10, dex=12, cun=14, mag=14, con=10 },
	resolvers.talents{ [Talents.T_MANA_POOL]=1, [Talents.T_FLAME]=2, [Talents.T_MANATHRUST]=3 },

	resolvers.equip{ {type="weapon", subtype="staff", autoreq=true} },

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "skeleton archer", color=colors.UMBER, image="npc/skeleton_archer.png",
	level_range = {5, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 5, combat_def = 1,
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_SHOOT]=1, },
	ai_state = { talent_in=1, },

	autolevel = "archer",
	resolvers.equip{ {type="weapon", subtype="longbow", autoreq=true}, {type="ammo", subtype="arrow", autoreq=true} },
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "skeleton master archer", color=colors.LIGHT_UMBER, image="npc/master_skeleton_archer.png",
	level_range = {15, nil}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 5, combat_def = 1,
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_SHOOT]=1, [Talents.T_PINNING_SHOT]=3, [Talents.T_CRIPPLING_SHOT]=3, },
	ai_state = { talent_in=1, },
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",

	autolevel = "archer",
	resolvers.equip{ {type="weapon", subtype="longbow", autoreq=true}, {type="ammo", subtype="arrow", autoreq=true} },
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "armoured skeleton warrior", color=colors.STEEL_BLUE, image="npc/armored_skeleton_warrior.png",
	level_range = {10, nil}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 5, combat_def = 1,
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	resolvers.inscriptions(1, "rune"),
	resolvers.talents{
		[Talents.T_HEAVY_ARMOUR_TRAINING]=1,
		[Talents.T_SHIELD_PUMMEL]=1,
		[Talents.T_RIPOSTE]=3,
		[Talents.T_OVERPOWER]=1,
		[Talents.T_DISARM]=3,
	},
	resolvers.equip{ {type="weapon", subtype="longsword", autoreq=true}, {type="armor", subtype="shield", autoreq=true}, {type="armor", subtype="heavy", autoreq=true} },
	ai_state = { talent_in=1, },
}
