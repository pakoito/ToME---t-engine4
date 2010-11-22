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
	define_as = "BASE_NPC_SNOW_GIANT",
	type = "giant", subtype = "ice",
	display = "P", color=colors.WHITE,

	combat = { dam=resolvers.mbonus(50, 10), atk=15, apr=15, dammod={str=0.8} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {type="money"} },

	infravision = 20,
	life_rating = 12,
	max_stamina = 90,
	rank = 2,
	size_category = 4,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
	energy = { mod=1 },
	stats = { str=20, dex=8, mag=6, con=16 },

	resists = { [DamageType.PHYSICAL] = 20, [DamageType.COLD] = 50, },

	no_breath = 1,
	confusion_immune = 1,
	poison_immune = 1,
}

newEntity{ base = "BASE_NPC_SNOW_GIANT",
	name = "snow giant", color=colors.WHITE,
	desc = [[A towering creature, humanoid but huge. It wields a giant maul and does not look friendly.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 0, combat_def = 0,
	on_melee_hit = {[DamageType.COLD]=resolvers.mbonus(15, 5)},
	melee_project = {[DamageType.COLD]=resolvers.mbonus(15, 5)},
	resolvers.talents{ [Talents.T_MIND_DISRUPTION]=2, },
}

newEntity{ base = "BASE_NPC_SNOW_GIANT",
	name = "snow giant thunderer", color=colors.LIGHT_BLUE,
	desc = [[A towering creature, humanoid but huge. It wields a giant maul and does not look friendly. Lightning crackles over its body.]],
	level_range = {14, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 0, combat_def = 0,
	on_melee_hit = {[DamageType.COLD]=resolvers.mbonus(15, 5)},
	melee_project = {[DamageType.COLD]=resolvers.mbonus(15, 5)},
	autolevel = "warriormage",
	resolvers.talents{ [Talents.T_LIGHTNING]=3, [Talents.T_CHAIN_LIGHTNING]=3, },
}

newEntity{ base = "BASE_NPC_SNOW_GIANT",
	name = "snow giant boulder thrower", color=colors.LIGHT_UMBER,
	desc = [[A towering creature, humanoid but huge. It wields a giant maul and does not look friendly.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 0, combat_def = 0,
	on_melee_hit = {[DamageType.COLD]=resolvers.mbonus(15, 5)},
	melee_project = {[DamageType.COLD]=resolvers.mbonus(15, 5)},
	resolvers.talents{ [Talents.T_THROW_BOULDER]=3, },
}

newEntity{ base = "BASE_NPC_SNOW_GIANT",
	name = "snow giant chieftain", color=colors.AQUAMARINE,
	desc = [[A towering creature, humanoid but huge. It wields a giant maul and does not look friendly.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 7,
	rank = 3,
	max_life = resolvers.rngavg(150,170),
	combat_armor = 12, combat_def = 12,
	on_melee_hit = {[DamageType.COLD]=resolvers.mbonus(15, 10)},
	melee_project = {[DamageType.COLD]=resolvers.mbonus(15, 10)},
	resolvers.talents{ [Talents.T_KNOCKBACK]=3, [Talents.T_STUN]=3, },
	make_escort = {
		{type="giant", subtype="ice", number=3},
	},

	resolvers.drops{chance=100, nb=1, {ego_chance=10} },
}
