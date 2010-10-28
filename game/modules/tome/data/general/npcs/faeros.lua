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
	define_as = "BASE_NPC_FAEROS",
	type = "elemental", subtype = "fire",
	display = "E", color=colors.ORANGE,

	combat = { dam=resolvers.mbonus(40, 15), atk=15, apr=15, dammod={mag=0.8}, damtype=DamageType.FIRE },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 20,
	life_rating = 8,
	rank = 2,
	size_category = 3,

	autolevel = "dexmage",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
	energy = { mod=1 },
	stats = { str=10, dex=8, mag=6, con=16 },

	resists = { [DamageType.PHYSICAL] = 10, [DamageType.FIRE] = 100, [DamageType.COLD] = -30, },

	no_breath = 1,
	poison_immune = 1,
	desease_immune = 1,
}

newEntity{ base = "BASE_NPC_FAEROS",
	name = "faeros", color=colors.ORANGE,
	desc = [[Faeros are highly intelligent fire elementals, rarely seen outside volcanos they are probably not native to this world.]],
	level_range = {20, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.FIRE] = resolvers.mbonus(20, 10), },

	resolvers.talents{
		[Talents.T_FLAME]=3,
	},
}

newEntity{ base = "BASE_NPC_FAEROS",
	name = "greater faeros", color=colors.ORANGE,
	desc = [[Faeros are highly intelligent fire elementals, rarely seen outside volcanos they are probably not native to this world.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80), life_rating = 10,
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.FIRE] = resolvers.mbonus(20, 10), },

	resolvers.talents{
		[Talents.T_FLAME]=4,
		[Talents.T_FIERY_HANDS]=3,
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_FAEROS",
	name = "ultimate faeros", color=colors.ORANGE,
	desc = [[Faeros are highly intelligent fire elementals, rarely seen outside volcanos they are probably not native to this world.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.FIRE] = resolvers.mbonus(20, 10), },

	resolvers.talents{
		[Talents.T_FLAME]=4,
		[Talents.T_FIERY_HANDS]=3,
		[Talents.T_FLAMESHOCK]=3,
		[Talents.T_INFERNO]=3,
	},
	resolvers.sustains_at_birth(),
}
