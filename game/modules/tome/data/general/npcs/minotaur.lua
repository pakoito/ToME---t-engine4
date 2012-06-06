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

-- last updated: 11:56 AM 2/5/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_MINOTAUR",
	type = "giant", subtype = "minotaur",
	display = "H", color=colors.WHITE,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=40, nb=1, {type="money"} },

	infravision = 10,
	lite = 1,
	max_stamina = 100,
	life_rating = 13,
	max_life = resolvers.rngavg(100,120),
	rank = 2,
	size_category = 4,

	open_door = true,

	resolvers.inscriptions(1, "rune"),
	resolvers.inscriptions(1, "infusion"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=5, },
	global_speed_base = 1.2,
	stats = { str=15, dex=12, mag=6, cun=12, con=15 },

	resolvers.tmasteries{ ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3, ["technique/combat-training"]=0.3, },
	ingredient_on_death = "MINOTAUR_NOSE",
}

newEntity{ base = "BASE_NPC_MINOTAUR",
	name = "minotaur", color=colors.UMBER,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_minotaur_minotaur.png", display_h=2, display_y=-1}}},
	desc = [[It is a cross between a human and a bull.]],
	resolvers.equip{ {type="weapon", subtype="battleaxe", autoreq=true}, },
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	combat_armor = 13, combat_def = 8,
	resolvers.talents{
		[Talents.T_WARSHOUT]={base=3, every=10, max=6},
		[Talents.T_STUNNING_BLOW]={base=3, every=10, max=6},
		[Talents.T_SUNDER_ARMOUR]={base=2, every=10, max=5},
		[Talents.T_SUNDER_ARMS]={base=2, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_MINOTAUR",
	name = "maulotaur", color=colors.SLATE,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_minotaur_maulotaur.png", display_h=2, display_y=-1}}},
	desc = [[A belligerent minotaur with a destructive magical arsenal, and armed with a hammer.]],
	level_range = {20, nil}, exp_worth = 1,
	rarity = 4,
	combat_armor = 15, combat_def = 7,
	resolvers.equip{ {type="weapon", subtype="maul", forbid_power_source={antimagic=true}, autoreq=true} },

	autolevel = "caster",
	resists = { [DamageType.FIRE] = 100 },
	max_mana = 100,
	resolvers.talents{
		[Talents.T_FLAME]={base=3, every=8, max=6},
		[Talents.T_FIREFLASH]={base=2, every=10, max=6}
	},
}
