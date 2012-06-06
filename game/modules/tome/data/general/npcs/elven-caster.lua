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

-- last updated: 9:25 AM 2/5/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_ELVEN_CASTER",
	type = "humanoid", subtype = "shalore",
	display = "p", color=colors.UMBER,
	faction = "rhalore",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 1,

	life_rating = 11,
	rank = 2,
	size_category = 3,

	open_door = true,
	silence_immune = 0.5,

	resolvers.racial(),
	resolvers.talents{ [Talents.T_ARMOUR_TRAINING]=1, },

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	stats = { str=20, dex=8, mag=6, con=16 },
	power_source = {arcane=true},
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	name = "elven mage", color=colors.TEAL,
	desc = [[An elven mage, dressed in dark robes.]],
	level_range = {2, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(70, 80), life_rating = 10,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_EARTHEN_MISSILES]={base=2, every=8, max=6},
		[Talents.T_SHOCK]={base=1, every=8, max=5},
	},
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	name = "elven tempest", color=colors.LIGHT_BLUE,
	desc = [[An elven mage, dressed in crackling blue robes, and smelling of ozone.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(70, 80), life_rating = 10,
	mana_regen = 30, max_mana = 200,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_LIGHTNING]={base=2, every=8, max=6},
		[Talents.T_THUNDERSTORM]={base=1, every=8, max=5},
	},
	resolvers.sustains_at_birth(),
}


newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	name = "elven cultist", color=colors.DARK_SEA_GREEN,
	desc = [[An elven cultist, dressed in sickening green robes.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	ai = "tactical",
	max_life = resolvers.rngavg(100, 110), life_rating = 13,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_DRAIN]={base=3, every=8, max=7},
		[Talents.T_DARK_PORTAL]={base=3, every=7, max=6},
		[Talents.T_SOUL_ROT]={base=4, every=8, max=6},
		[Talents.T_VIRULENT_DISEASE]={base=4, every=8, max=6},
		[Talents.T_FLAME_OF_URH_ROK]={base=3, every=8, max=6},
		[Talents.T_DARK_RITUAL]={base=3, every=8, max=6},
	},
	resolvers.sustains_at_birth(),
	resolvers.inscriptions(1, "rune"),
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	name = "elven blood mage", color=colors.ORCHID,
	desc = [[An elven blood mage, dressing in dark, bloodied robes.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	ai = "tactical",
	max_life = resolvers.rngavg(100, 110),
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_DRAIN]={base=4, every=8, max=7},
		[Talents.T_BLOOD_SPRAY]={base=4, every=8, max=7},
		[Talents.T_BLOOD_GRASP]={base=4, every=8, max=7},
		[Talents.T_BLOOD_BOIL]={base=3, every=8, max=7},
		[Talents.T_BLOOD_FURY]={base=3, every=8, max=7},
	},
	resolvers.sustains_at_birth(),
	resolvers.inscriptions(1, "rune"),
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	name = "elven corruptor", color=colors.ORCHID,
	desc = [[An elven corruptor, drawn to these blighted lands.]],
	level_range = {26, nil}, exp_worth = 1,
	rarity = 3,
	rank = 3,
	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",
	max_life = resolvers.rngavg(100, 110), life_rating = 12,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_BONE_SHIELD]={base=2, every=10, max=5},
		[Talents.T_BLOOD_SPRAY]={base=5, every=10, max=7},
		[Talents.T_DRAIN]={base=5, every=10, max=7},
		[Talents.T_SOUL_ROT]={base=5, every=10, max=7},
		[Talents.T_BLOOD_GRASP]={base=4, every=10, max=6},
		[Talents.T_BONE_SPEAR]={base=5, every=10, max=7},
	},
	resolvers.sustains_at_birth(),
	resolvers.inscriptions(1, "rune"),
}
