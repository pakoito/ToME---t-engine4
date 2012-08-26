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
	define_as = "BASE_NPC_SKELETON",
	type = "undead", subtype = "skeleton",
	blood_color = colors.GREY,
	display = "s", color=colors.WHITE,
	sound_moam = {"creatures/skeletons/skell_%d", 1, 4},
	sound_die = "creatures/skeletons/skell_die",
	sound_random = {"creatures/skeletons/skell_%d", 1, 4},

	combat = { dam=1, atk=1, apr=1 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },
	infravision = 10,
	rank = 2,
	size_category = 3,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=4, },
	stats = { str=14, dex=12, mag=10, con=12 },

	resolvers.racial(),
	resolvers.tmasteries{ ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },

	open_door = true,

	cut_immune = 1,
	blind_immune = 1,
	fear_immune = 1,
	poison_immune = 1,
	see_invisible = 2,
	undead = 1,
	not_power_source = {nature=true},
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "degenerated skeleton warrior", color=colors.WHITE, image="npc/degenerated_skeleton_warrior.png",
	level_range = {1, 18}, exp_worth = 1,
	rarity = 1,
	resolvers.equip{ {type="weapon", subtype="greatsword", forbid_power_source={antimagic=true}, autoreq=true} },
	max_life = resolvers.rngavg(40,50),
	combat_armor = 5, combat_def = 1,
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "skeleton warrior", color=colors.SLATE, image="npc/skeleton_warrior.png",
	level_range = {3, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 5, combat_def = 1,
	resolvers.equip{ {type="weapon", subtype="greatsword", forbid_power_source={antimagic=true}, autoreq=true} },
	resolvers.talents{ [Talents.T_STUNNING_BLOW]={base=1, every=7, max=5}, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5}, },
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
	resolvers.talents{ [Talents.T_FLAME]={base=1, every=7, max=5}, [Talents.T_MANATHRUST]={base=2, every=7, max=5} },

	resolvers.equip{ {type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true} },

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	ingredient_on_death = "SKELETON_MAGE_SKULL",
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "skeleton archer", color=colors.UMBER, image="npc/skeleton_archer.png",
	level_range = {5, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 5, combat_def = 1,
	resolvers.talents{ [Talents.T_BOW_MASTERY]={base=1, every=10, max=5}, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_SHOOT]=1, },
	ai_state = { talent_in=1, },

	autolevel = "archer",
	resolvers.equip{ {type="weapon", subtype="longbow", forbid_power_source={antimagic=true}, autoreq=true}, {type="ammo", subtype="arrow", forbid_power_source={antimagic=true}, autoreq=true} },
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "skeleton master archer", color=colors.LIGHT_UMBER, image="npc/master_skeleton_archer.png",
	level_range = {15, nil}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 5, combat_def = 1,
	resolvers.talents{ [Talents.T_BOW_MASTERY]={base=1, every=10, max=5}, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_SHOOT]=1, [Talents.T_PINNING_SHOT]=3, [Talents.T_CRIPPLING_SHOT]=3, },
	ai_state = { talent_in=1, },
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",

	autolevel = "archer",
	resolvers.equip{ {type="weapon", subtype="longbow", forbid_power_source={antimagic=true}, autoreq=true}, {type="ammo", subtype="arrow", forbid_power_source={antimagic=true}, autoreq=true} },
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
		[Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5},
		[Talents.T_ARMOUR_TRAINING]={base=4, every=7, max=8},
		[Talents.T_SHIELD_PUMMEL]={base=1, every=7, max=5},
		[Talents.T_RIPOSTE]={base=3, every=7, max=7},
		[Talents.T_OVERPOWER]={base=1, every=7, max=5},
		[Talents.T_DISARM]={base=3, every=7, max=7},
	},
	resolvers.equip{ {type="weapon", subtype="longsword", forbid_power_source={antimagic=true}, autoreq=true}, {type="armor", subtype="shield", forbid_power_source={antimagic=true}, autoreq=true}, {type="armor", subtype="heavy", forbid_power_source={antimagic=true}, autoreq=true} },
	ai_state = { talent_in=1, },
}
