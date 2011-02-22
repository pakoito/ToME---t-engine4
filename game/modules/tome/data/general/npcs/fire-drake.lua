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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_FIRE_DRAKE",
	type = "dragon", subtype = "fire",
	display = "D", color=colors.WHITE,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {type="money"} },

	infravision = 20,
	life_rating = 15,
	rank = 2,
	size_category = 5,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
	energy = { mod=1 },
	stats = { str=20, dex=20, mag=30, con=16 },

	resists = { [DamageType.FIRE] = 100, },

	knockback_immune = 1,
	stun_immune = 1,
}

newEntity{ base = "BASE_NPC_FIRE_DRAKE",
	name = "fire drake hatchling", color=colors.RED, display="d",
	desc = [[A drake hatchling; not too powerful by itself, but it usually comes with its brothers and sisters.]],
	level_range = {8, nil}, exp_worth = 1,
	rarity = 1,
	rank = 1, size_category = 2,
	max_life = resolvers.rngavg(40,60),
	combat_armor = 5, combat_def = 0,
	combat = { dam=resolvers.rngavg(25,40), atk=resolvers.rngavg(25,60), apr=25, dammod={str=1.1} },
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(7, 2)},
	combat = { dam=resolvers.rngavg(10,15), atk=15, apr=5, dammod={str=0.6} },

	make_escort = {
		{type="dragon", subtype="fire", name="fire drake hatchling", number=3, no_subescort=true},
	},
}

newEntity{ base = "BASE_NPC_FIRE_DRAKE",
	name = "fire drake", color=colors.RED, display="D",
	desc = [[A mature fire drake, armed with a deadly breath weapon and nasty claws.]],
	level_range = {14, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(100,110),
	combat_armor = 12, combat_def = 0,
	combat = { dam=resolvers.rngavg(25,70), atk=resolvers.rngavg(25,70), apr=25, dammod={str=1.1} },
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(15, 10)},
	lite = 1,

	summon = {
		{type="dragon", name="fire drake hatchling", number=1, hasxp=false},
--		{type="dragon", name="fire drake", number=1, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_SUMMON]=1,
		[Talents.T_WING_BUFFET]=2,
		[Talents.T_FIRE_BREATH]=3,
	},
}

newEntity{ base = "BASE_NPC_FIRE_DRAKE",
	name = "fire wyrm", color=colors.LIGHT_RED, display="D",
	desc = [[An old and powerful fire drake, armed with a deadly breath weapon and nasty claws.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(170,190),
	combat_armor = 30, combat_def = 0,
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(25, 10)},
	combat = { dam=resolvers.rngavg(25,110), atk=resolvers.rngavg(25,70), apr=25, dammod={str=1.1} },
	lite = 1,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",
	ai_status = {ally_compassion = 0},
	
	summon = {
		{type="dragon", name="fire drake", number=1, hasxp=false},
--		{type="dragon", name="fire wyrm", number=1, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_SUMMON]=1,
		[Talents.T_WING_BUFFET]=5,
		[Talents.T_FLAME]=5,
		[Talents.T_FIRE_BREATH]=5,
		[Talents.T_DEVOURING_FLAME]=3,
	},
}
