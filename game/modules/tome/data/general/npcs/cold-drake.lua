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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_COLD_DRAKE",
	type = "dragon", subtype = "cold",
	display = "D", color=colors.WHITE,

	combat = { dam=resolvers.rngavg(25,30), atk=15, apr=25, dammod={str=1} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {type="money"} },

	infravision = 20,
	life_rating = 15,
	rank = 2,
	size_category = 5,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, },
	energy = { mod=1 },
	stats = { str=20, dex=20, mag=30, con=16 },

	resists = { [DamageType.COLD] = 100, },

	knockback_immune = 1,
	stun_immune = 1,
}

newEntity{ base = "BASE_NPC_COLD_DRAKE",
	name = "cold drake hatchling", color=colors.WHITE, display="d",
	desc = [[A drake hatchling, not too powerful in itself, but it usually comes with its brothers and sisters.]],
	level_range = {7, 50}, exp_worth = 1,
	rarity = 7,
	rank = 1, size_category = 2,
	max_life = resolvers.rngavg(40,60),
	combat_armor = 5, combat_def = 0,
	on_melee_hit = {[DamageType.COLD]=resolvers.mbonus(7, 2)},
	combat = { dam=resolvers.rngavg(15,20), atk=15, apr=25, dammod={str=0.7} },

	make_escort = {
		{type="dragon", subtype="cold", name="cold drake hatchling", number=3, no_subescort=true},
	},
}

newEntity{ base = "BASE_NPC_COLD_DRAKE",
	name = "cold drake", color=colors.SLATE, display="D",
	desc = [[A mature cold drake, armed with a deadly breath weapon and nasty claws.]],
	level_range = {14, 50}, exp_worth = 1,
	rarity = 8,
	max_life = resolvers.rngavg(100,110),
	combat_armor = 12, combat_def = 0,
	on_melee_hit = {[DamageType.COLD]=resolvers.mbonus(15, 10)},

	resolvers.talents{
		[Talents.T_ICE_CLAW]=2,
		[Talents.T_ICE_BREATH]=3,
	},
}

newEntity{ base = "BASE_NPC_COLD_DRAKE",
	name = "ice wyrm", color=colors.AQUAMARINE, display="D",
	desc = [[An old and powerful cold drake, armed with a deadly breath weapon and nasty claws.]],
	level_range = {25, 50}, exp_worth = 1,
	rarity = 12,
	rank = 3,
	max_life = resolvers.rngavg(170,190),
	combat_armor = 30, combat_def = 0,
	on_melee_hit = {[DamageType.COLD]=resolvers.mbonus(25, 10)},
	combat = { dam=resolvers.rngavg(25,40), atk=25, apr=25, dammod={str=1.1} },

	resolvers.talents{
		[Talents.T_ICE_CLAW]=5,
		[Talents.T_FREEZE]=5,
		[Talents.T_ICE_BREATH]=5,
	},
}
