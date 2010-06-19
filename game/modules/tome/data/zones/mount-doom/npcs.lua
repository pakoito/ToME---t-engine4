-- ToME - Tales of Middle-Earth
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

load("/data/general/npcs/rodent.lua")
load("/data/general/npcs/vermin.lua")
load("/data/general/npcs/molds.lua")
load("/data/general/npcs/skeleton.lua")
load("/data/general/npcs/snake.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SUNWALL_DEFENDER",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.WHITE,
	faction = "sunwall",

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 17,
	rank = 2,
	size_category = 3,

	open_door = true,

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	energy = { mod=1 },
	stats = { str=12, dex=8, mag=6, con=10 },
}

newEntity{ base = "BASE_NPC_SUNWALL_DEFENDER", define_as = "SUN_PALADIN_DEFENDER",
	name = "human sun-paladin", color=colors.GOLD,
	desc = [[A human in a shiny plate armour.]],
	level_range = {70, nil}, exp_worth = 1,
	rank = 3,
	positive_regen = 10,
	life_regen = 5,
	max_life = resolvers.rngavg(140,170),
	resolvers.equip{
		{type="weapon", subtype="mace", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="massive", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_MASSIVE_ARMOUR_TRAINING]=5,
		[Talents.T_CHANT_OF_FORTRESS]=5,
		[Talents.T_SEARING_LIGHT]=4,
		[Talents.T_MARTYRDOM]=4,
		[Talents.T_WEAPON_OF_LIGHT]=4,
		[Talents.T_FIREBEAM]=4,
		[Talents.T_WEAPON_COMBAT]=10,
		[Talents.T_HEALING_LIGHT]=4,
	},
	on_added = function(self)
		self.energy.value = game.energy_to_act self:useTalent(self.T_WEAPON_OF_LIGHT)
		self.energy.value = game.energy_to_act self:useTalent(self.T_CHANT_OF_FORTRESS)
	end,
}

newEntity{
	define_as = "BASE_NPC_ORC_ATTACKER",
	type = "humanoid", subtype = "orc",
	display = "o", color=colors.UMBER,
	faction = "orc-pride",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	infravision = 20,
	lite = 2,

	life_rating = 11,
	rank = 2,
	size_category = 3,

	open_door = true,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_target="mount_doom_target", talent_in=2, },
	energy = { mod=1 },
	stats = { str=20, dex=8, mag=6, con=16 },
}

newEntity{ base = "BASE_NPC_ORC_ATTACKER", define_as = "URUK-HAI_ATTACK",
	name = "uruk-hai", color=colors.DARK_RED,
	desc = [[A fierce soldier-orc.]],
	level_range = {42, nil}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(120,140),
	life_rating = 8,
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
	},
	combat_armor = 10, combat_def = 10,
	resolvers.talents{
		[Talents.T_SUNDER_ARMOUR]=5,
		[Talents.T_CRUSH]=4,
		[Talents.T_RUSH]=4,
		[Talents.T_WEAPON_COMBAT]=4,
	},
}
