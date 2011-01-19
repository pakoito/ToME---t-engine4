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

-- last updated: 9:25 AM 2/5/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_ELVEN_CASTER",
	type = "humanoid", subtype = "elf",
	display = "p", color=colors.UMBER,
	faction = "rhalore",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 20,
	lite = 2,

	life_rating = 11,
	rank = 2,
	size_category = 3,

	open_door = true,
	silence_immune = 0.5,

	resolvers.talents{ [Talents.T_HEAVY_ARMOUR_TRAINING]=1, },
	resolvers.inscriptions(1, "rune"),

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	energy = { mod=1 },
	stats = { str=20, dex=8, mag=6, con=16 },
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	name = "elven cultist", color=colors.DARK_SEA_GREEN,
	desc = [[An elven cultist, dressed in dark robes.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	vim_regen = 20,
	max_life = resolvers.rngavg(100, 110), life_rating = 13,
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloth", autoreq=true},
	},
	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_DARK_PORTAL]=3,
		[Talents.T_SOUL_ROT]=4,
		[Talents.T_VIRULENT_DISEASE]=4,
		[Talents["T_FLAME_OF_URH'ROK"]]=3,
		[Talents.T_DARK_RITUAL]=3,
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	name = "elven blood mage", color=colors.ORCHID,
	desc = [[An elven blood mage, dressing in dark, bloodied robes.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	vim_regen = 20,
	max_life = resolvers.rngavg(100, 110),
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloth", autoreq=true},
	},
	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_BLOOD_SPRAY]=4,
		[Talents.T_BLOOD_GRASP]=4,
		[Talents.T_BLOOD_BOIL]=3,
		[Talents.T_BLOOD_FURY]=3,
		[Talents.T_BONE_SPEAR]=5,
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	name = "elven corruptor", color=colors.ORCHID,
	desc = [[An elven corruptor, drawn to these blighted lands.]],
	level_range = {26, nil}, exp_worth = 1,
	rarity = 3,
	rank = 3,
	vim_regen = 20,
	max_life = resolvers.rngavg(100, 110), life_rating = 12,
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloth", autoreq=true},
	},
	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_BONE_SHIELD]=2,
		[Talents.T_BLOOD_SPRAY]=5,
		[Talents.T_SOUL_ROT]=5,
		[Talents.T_BLOOD_GRASP]=4,
		[Talents.T_BONE_SPEAR]=5,
	},
	resolvers.sustains_at_birth(),
}
