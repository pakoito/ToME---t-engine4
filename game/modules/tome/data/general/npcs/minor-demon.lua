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

-- last updated:  10:46 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_DEMON",
	type = "demon", subtype = "minor",
	display = "u", color=colors.WHITE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	stats = { str=12, dex=10, mag=3, con=13 },
	energy = { mod=1 },
	life_rating = 7,
	combat_armor = 1, combat_def = 1,
	combat = { dam=resolvers.mbonus(46, 20), atk=15, apr=7, dammod={str=0.7} },
	max_life = resolvers.rngavg(100,120),
	infravision = 20,
	open_door = true,
	rank = 2,
	size_category = 3,
	no_breath = 1,
	demon = 1,
}

newEntity{ base = "BASE_NPC_DEMON",
	name = "fire imp", color=colors.CRIMSON,
	desc = "A small demon, lobbing spells at you.",
	level_range = {10, nil}, exp_worth = 1,
	rarity = 3,
	rank = 2,
	size_category = 1,
	autolevel = "caster",
	combat_armor = 1, combat_def = 0,
	combat = {damtype=DamageType.FIRE},

	resists={[DamageType.FIRE] = resolvers.mbonus(12, 5)},

	resolvers.talents{
		[Talents.T_FIRE_IMP_BOLT]=4,
		[Talents.T_PHASE_DOOR]=2,
	},
}

newEntity{ base = "BASE_NPC_DEMON",
	name = "quasit", color=colors.LIGHT_GREY,
	desc = "A small, heavily armoured demon, rushing toward you.",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	size_category = 1,
	autolevel = "warrior",
	combat_armor = 1, combat_def = 0,
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	resolvers.talents{
		[Talents.T_HEAVY_ARMOUR_TRAINING]=1,
		[Talents.T_SHIELD_PUMMEL]=2,
		[Talents.T_RIPOSTE]=3,
		[Talents.T_OVERPOWER]=1,
		[Talents.T_RUSH]=6,
	},
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true}
	},
}
