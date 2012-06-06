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
	define_as = "BASE_NPC_ZIGURANTH",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.UMBER,
	faction = "zigur",
	killer_message = "and burned on a pyre",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	infravision = 10,
	lite = 1,

	life_rating = 15,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),

	resolvers.talents{ [Talents.T_ARMOUR_TRAINING]=4, },
	resolvers.inscriptions(1, "infusion"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	stats = { str=20, dex=15, mag=1, con=16, wil=19 },
	not_power_source = {arcane=true},
}

newEntity{ base = "BASE_NPC_ZIGURANTH",
	name = "ziguranth warrior", color=colors.CRIMSON,
	desc = [[A Ziguranth warrior, clad in heavy armour.]],
	subtype = "dwarf",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(100,110),
	resolvers.equip{
		{type="weapon", subtype="waraxe", forbid_power_source={arcane=true}, autoreq=true},
		{type="armor", subtype="shield", forbid_power_source={arcane=true}, autoreq=true},
		{type="armor", subtype="heavy", forbid_power_source={arcane=true}, autoreq=true},
	},
	combat_armor = 10, combat_def = 6,
	resolvers.talents{
		[Talents.T_RESOLVE]={base=4, every=5, max=8},
		[Talents.T_AURA_OF_SILENCE]={base=4, every=5, max=8},
		[Talents.T_WEAPON_COMBAT]={base=2, every=10, max=4},
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max=4},
		[Talents.T_SHIELD_PUMMEL]={base=4, every=5, max=8},
		[Talents.T_RUSH]={base=4, every=5, max=8},
	},
}

newEntity{ base = "BASE_NPC_ZIGURANTH",
	name = "ziguranth summoner", color=colors.CRIMSON,
	desc = [[A Ziguranth wilder, attuned to nature.]],
	subtype = "thalore",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(100,110),
	resolvers.equip{
		{type="weapon", subtype="waraxe", forbid_power_source={arcane=true}, autoreq=true},
		{type="armor", subtype="shield", forbid_power_source={arcane=true}, autoreq=true},
		{type="armor", subtype="heavy", forbid_power_source={arcane=true}, autoreq=true},
	},
	combat_armor = 10, combat_def = 6, life_rating = 11,
	equilibrium_regen = -20,

	autolevel = "wildcaster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },

	resolvers.talents{
		[Talents.T_RESOLVE]={base=4, every=5, max=8},
		[Talents.T_MANA_CLASH]={base=3, every=5, max=7},
		[Talents.T_RESILIENCE]={base=4, every=5, max=8},
		[Talents.T_RITCH_FLAMESPITTER]={base=4, every=5, max=8},
		[Talents.T_HYDRA]={base=4, every=5, max=8},
		[Talents.T_WAR_HOUND]={base=4, every=5, max=8},
		[Talents.T_MINOTAUR]={base=4, every=5, max=8},
		[Talents.T_FIRE_DRAKE]={base=4, every=5, max=8},
		[Talents.T_SPIDER]={base=4, every=5, max=8},
	},
}

newEntity{ base = "BASE_NPC_ZIGURANTH",
	name = "ziguranth wyrmic", color=colors.CRIMSON,
	desc = [[A Ziguranth wilder, attuned to nature.]],
	level_range = {20, nil}, exp_worth = 1,
	rarity = 2,
	rank = 3,
	max_life = resolvers.rngavg(100,110),
	resolvers.equip{
		{type="weapon", subtype="battleaxe", forbid_power_source={arcane=true}, autoreq=true},
		{type="armor", subtype="heavy", forbid_power_source={arcane=true}, autoreq=true},
	},
	combat_armor = 10, combat_def = 6, life_rating = 14,
	equilibrium_regen = -20,

	autolevel = "warriorwill",
	ai_state = { ai_move="move_dmap", talent_in=2, },
	ai = "tactical",

	resolvers.talents{
		[Talents.T_RESOLVE]={base=4, every=5, max=8},
		[Talents.T_ANTIMAGIC_SHIELD]={base=3, every=5, max=8},
		[Talents.T_FIRE_BREATH]={base=4, every=5, max=8},
		[Talents.T_ICE_BREATH]={base=4, every=5, max=8},
		[Talents.T_LIGHTNING_BREATH]={base=4, every=5, max=8},
		[Talents.T_ICY_SKIN]={base=4, every=5, max=8},
		[Talents.T_LIGHTNING_SPEED]={base=4, every=5, max=8},
		[Talents.T_TORNADO]={base=4, every=5, max=8},
	},
}
