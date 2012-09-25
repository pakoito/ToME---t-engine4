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
	define_as = "BASE_NPC_VENOM_DRAKE",
	type = "dragon", subtype = "venom",
	display = "D", color=colors.WHITE,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {type="money"} },

	infravision = 10,
	life_rating = 15,
	rank = 2,
	size_category = 5,

	autolevel = "drake",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
	stats = { str=20, dex=20, mag=30, con=16 },

	resists = { [DamageType.ACID] = 100, },

	knockback_immune = 1,
	stun_immune = 0.5,
	blind_immune = 0.5,
}

newEntity{ base = "BASE_NPC_VENOM_DRAKE",
	name = "venom drake hatchling", color=colors.GREEN, display="d",
	desc = [[A corrosive venom drake hatchling; not too powerful by itself, but it usually comes with its brothers and sisters.]],
	level_range = {8, nil}, exp_worth = 1,
	rarity = 1,
	rank = 1, size_category = 2,
	max_life = resolvers.rngavg(40,60),
	combat_armor = 5, combat_def = 0,
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,40), 1, 0.6), atk=resolvers.rngavg(25,60), apr=25, dammod={str=1.1} },
	on_melee_hit = {[DamageType.ACID]=resolvers.mbonus(7, 2)},

	make_escort = {
		{type="dragon", subtype="venom", name="venom drake hatchling", number=3, no_subescort=true},
	},
}

newEntity{ base = "BASE_NPC_VENOM_DRAKE",
	name = "venom drake", color=colors.GREEN, display="D",
	desc = [[A mature corrosive venom drake, armed with a deadly breath weapon and nasty claws.]],
	level_range = {14, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(100,110),
	combat_armor = 12, combat_def = 0,
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,70), 1, 1.2), atk=resolvers.rngavg(25,70), apr=25, dammod={str=1.1} },
	on_melee_hit = {[DamageType.ACID]=resolvers.mbonus(15, 10)},
	stats_per_level = 4,
	lite = 1,

	make_escort = {
		{type="dragon", name="venom drake hatchling", number=1},
	},

	resolvers.talents{
		[Talents.T_ACIDIC_SPRAY]={base=2, every=5, max=7},
		[Talents.T_CORROSIVE_BREATH]={base=3, every=5, max=9},
	},
}

newEntity{ base = "BASE_NPC_VENOM_DRAKE",
	name = "venom wyrm", color=colors.LIGHT_GREEN, display="D",
	desc = [[An old and powerful corrosive venom drake, armed with a deadly breath weapon and nasty claws.]],
	resolvers.nice_tile{tall=1},
	level_range = {25, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(170,190),
	combat_armor = 30, combat_def = 0,
	on_melee_hit = {[DamageType.ACID]=resolvers.mbonus(25, 10)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,110), 1, 2), atk=resolvers.rngavg(25,70), apr=25, dammod={str=1.1} },
	stats_per_level = 5,
	lite = 1,
	stun_immune = 0.8,
	blind_immune = 0.8,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	make_escort = {
		{type="dragon", name="venom drake", number=1},
		{type="dragon", name="venom drake", number=1, no_subescort=true},
	},

	resolvers.talents{
		[Talents.T_ACIDIC_SPRAY]={base=5, every=7},
		[Talents.T_CORROSIVE_MIST]={base=5, every=5},
		[Talents.T_CORROSIVE_BREATH]={base=5, every=4},
		[Talents.T_DISSOLVE]={base=5, every=6},
	},
}
