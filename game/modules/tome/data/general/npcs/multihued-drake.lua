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
	define_as = "BASE_NPC_MULTIHUED_DRAKE",
	type = "dragon", subtype = "multihued",
	display = "D", color=colors.PURPLE,
	shader = "quad_hue",

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {type="money"} },

	infravision = 20,
	life_rating = 18,
	rank = 2,
	size_category = 5,

	autolevel = "drake",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	energy = { mod=1 },
	stats = { str=20, dex=20, mag=30, con=16 },

	knockback_immune = 1,
	stun_immune = 1,
	poison_immune = 0.5,
}

newEntity{ base = "BASE_NPC_MULTIHUED_DRAKE",
	name = "multi-hued drake hatchling", color=colors.PURPLE, display="d",
	desc = [[A drake hatchling, not too powerful in itself, but it usually comes with its brothers and sisters.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 1,
	rank = 1, size_category = 2,
	max_life = resolvers.rngavg(60,80),
	combat_armor = 5, combat_def = 0,
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(7, 3), [DamageType.COLD]=resolvers.mbonus(7, 3)},
	combat = { dam=resolvers.rngavg(25,35), atk=15, apr=5, dammod={str=0.6} },

	resists = { [DamageType.PHYSICAL] = 20, [DamageType.FIRE] = 20, [DamageType.COLD] = 20, [DamageType.ACID] = 20, [DamageType.LIGHTNING] = 20, },

	make_escort = {
		{type="dragon", subtype="multihued", name="multi-hued drake hatchling", number=3, no_subescort=true},
	},
	resolvers.talents{
		[Talents.T_ICE_CLAW]=1,
	}
}

newEntity{ base = "BASE_NPC_MULTIHUED_DRAKE",
	name = "multi-hued drake", color=colors.PURPLE, display="D",
	desc = [[A mature multi-hued drake, armed with many deadly breath weapons and nasty claws.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(150,170),
	combat_armor = 12, combat_def = 0,
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(10, 5), [DamageType.COLD]=resolvers.mbonus(10, 5)},
	combat = { dam=resolvers.rngavg(35,45), atk=15, apr=25, dammod={str=1} },

	resists = { [DamageType.PHYSICAL] = 30, [DamageType.FIRE] = 30, [DamageType.COLD] = 30, [DamageType.ACID] = 30, [DamageType.LIGHTNING] = 30, },

	resolvers.talents{
		[Talents.T_ICE_CLAW]=3,
		[Talents.T_WING_BUFFET]=3,

		[Talents.T_FIRE_BREATH]=4,
		[Talents.T_ICE_BREATH]=4,
		[Talents.T_SAND_BREATH]=4,
		[Talents.T_POISON_BREATH]=4,
		[Talents.T_LIGHTNING_BREATH]=4,
		[Talents.T_ACID_BREATH]=4,
	},
}

newEntity{ base = "BASE_NPC_MULTIHUED_DRAKE",
	name = "greater multi-hued wyrm", color=colors.VIOLET, display="D",
	desc = [[An old and powerful multi-hued drake, armed with many deadly breath weapons and nasty claws.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	max_life = resolvers.rngavg(220,250),
	combat_armor = 30, combat_def = 30,
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(10, 5), [DamageType.COLD]=resolvers.mbonus(10, 5), [DamageType.LIGHTNING]=resolvers.mbonus(10, 5), [DamageType.ACID]=resolvers.mbonus(10, 5)},
	combat = { dam=resolvers.rngavg(50,70), atk=25, apr=25, dammod={str=1.1} },

	resists = { [DamageType.PHYSICAL] = 40, [DamageType.FIRE] = 40, [DamageType.COLD] = 40, [DamageType.ACID] = 40, [DamageType.LIGHTNING] = 40, },

	summon = {
		{type="dragon", number=2, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_SUMMON]=1,

		[Talents.T_ICE_CLAW]=8,
		[Talents.T_WING_BUFFET]=5,
		[Talents.T_DEVOURING_FLAME]=8,

		[Talents.T_FIRE_BREATH]=13,
		[Talents.T_ICE_BREATH]=13,
		[Talents.T_SAND_BREATH]=13,
		[Talents.T_POISON_BREATH]=13,
		[Talents.T_LIGHTNING_BREATH]=13,
		[Talents.T_ACID_BREATH]=13,
	},
}
