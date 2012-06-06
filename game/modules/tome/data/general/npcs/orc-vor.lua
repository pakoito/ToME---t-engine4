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
	define_as = "BASE_NPC_ORC_VOR",
	type = "humanoid", subtype = "orc",
	display = "o", color=colors.RED,
	faction = "orc-pride", pride = "vor",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 1,

	max_mana = 400,
	life_rating = 11,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),

	resolvers.inscriptions(2, "rune"),

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	stats = { str=10, dex=8, mag=20, con=16 },
	ingredient_on_death = "ORC_HEART",
}

newEntity{ base = "BASE_NPC_ORC_VOR",
	name = "orc pyromancer", color=colors.RED,
	desc = [[An orc dressed in bright red robes. He mumbles in a harsh tongue.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(100,110), life_rating = 7,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 5,

	resolvers.talents{
		[Talents.T_FLAME]={base=4, every=10, max=8},
		[Talents.T_FLAMESHOCK]={base=3, every=10, max=7},
		[Talents.T_FIREFLASH]={base=3, every=10, max=7},
		[Talents.T_SPELLCRAFT]={base=3, every=10, max=7},
		[Talents.T_PHASE_DOOR]=2,
	},
}

newEntity{ base = "BASE_NPC_ORC_VOR",
	name = "orc high pyromancer", color=colors.LIGHT_RED,
	desc = [[An orc dressed in bright red robes. He mumbles in a harsh tongue.]],
	level_range = {37, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(100,110), life_rating = 10,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 5,
	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",
	rank = 3,

	resolvers.talents{
		[Talents.T_FLAME]={base=5, every=10, max=9},
		[Talents.T_FLAMESHOCK]={base=5, every=10, max=9},
		[Talents.T_FIREFLASH]={base=5, every=10, max=9},
		[Talents.T_INFERNO]={base=5, every=10, max=9},
		[Talents.T_BLASTWAVE]={base=5, every=10, max=9},
		[Talents.T_BURNING_WAKE]={base=5, every=10, max=9},
		[Talents.T_SPELLCRAFT]=5,
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_ESSENCE_OF_SPEED]={base=1, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_ORC_VOR",
	name = "orc cryomancer", color=colors.BLUE,
	desc = [[An orc dressed in cold blue robes. He mumbles in a harsh tongue.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(100,110), life_rating = 10,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 5,

	resolvers.talents{
		[Talents.T_FREEZE]={base=4, every=10, max=8},
		[Talents.T_ICE_STORM]={base=5, every=10, max=9},
		[Talents.T_TIDAL_WAVE]={base=3, every=10, max=7},
		[Talents.T_SPELLCRAFT]={base=3, every=10, max=7},
		[Talents.T_PHASE_DOOR]=2,
	},
}

newEntity{ base = "BASE_NPC_ORC_VOR",
	name = "orc high cryomancer", color=colors.LIGHT_BLUE,
	desc = [[An orc dressed in cold blue robes. He mumbles in a harsh tongue.]],
	level_range = {37, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(100,110), life_rating = 10,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 5,
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",

	resolvers.talents{
		[Talents.T_FREEZE]={base=5, every=10, max=9},
		[Talents.T_ICE_STORM]={base=5, every=10, max=9},
		[Talents.T_TIDAL_WAVE]={base=5, every=10, max=9},
		[Talents.T_ICE_SHARDS]={base=5, every=10, max=9},
		[Talents.T_FROZEN_GROUND]={base=5, every=10, max=9},
		[Talents.T_SPELLCRAFT]={base=5, every=10, max=9},
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_ESSENCE_OF_SPEED]={base=1, every=10, max=5},
	},
}
