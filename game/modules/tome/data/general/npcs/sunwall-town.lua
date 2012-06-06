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
	define_as = "BASE_NPC_SUNWALL_TOWN",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.WHITE,
	faction = "sunwall",

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	lite = 1,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },
}

newEntity{ base = "BASE_NPC_SUNWALL_TOWN",
	name = "human guard", color=colors.LIGHT_UMBER,
	desc = [[A stern-looking guard, he will not let you disturb the town.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_RUSH]=1, [Talents.T_PERFECT_STRIKE]=1, },
}

newEntity{ base = "BASE_NPC_SUNWALL_TOWN",
	name = "elven archer", subtype = "elf", color=colors.UMBER,
	desc = [[A stern-looking guard, he will not let you disturb the town.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(50,60),
	resolvers.talents{ [Talents.T_SHOOT]=1, },
	ai_state = { talent_in=2, },
	autolevel = "archer",
	resolvers.equip{ {type="weapon", subtype="longbow", autoreq=true}, {type="ammo", subtype="arrow", autoreq=true} },
}

newEntity{ base = "BASE_NPC_SUNWALL_TOWN",
	name = "human sun-paladin", color=colors.GOLD,
	desc = [[A human in a shiny plate armour.]],
	level_range = {5, nil}, exp_worth = 1,
	rarity = 3,
	rank = 3,
	max_life = resolvers.rngavg(80,90),
	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",
	resolvers.equip{
		{type="weapon", subtype="mace", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="shield", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="massive", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]=4,
		[Talents.T_CHANT_OF_FORTITUDE]=2,
		[Talents.T_SEARING_LIGHT]=2,
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_SUNWALL_TOWN",
	name = "elven sun-mage", subtype = "elf", color=colors.YELLOW,
	desc = [[An elf dressed in glowing robes.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 3,
	rank = 3,
	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="stagg", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="robe", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.talents{
		[Talents.T_CHANT_OF_LIGHT]=2,
		[Talents.T_SEARING_LIGHT]=3,
		[Talents.T_FIREBEAM]=2,
	},
	resolvers.sustains_at_birth(),
}
