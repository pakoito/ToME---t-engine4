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
	define_as = "BASE_NPC_TELUGOROTH", -- telu goroth = time terror
	type = "elemental", subtype = "temporal",
	blood_color = colors.PURPLE,
	display = "E", color=colors.YELLOW,

	combat = { dam=resolvers.mbonus(40, 15), atk=15, apr=15, dammod={mag=0.8}, damtype=DamageType.TEMPORAL },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 20,
	life_rating = 8,
	rank = 2,
	size_category = 3,

	autolevel = "dexmage",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
	energy = { mod=1.5 },
	stats = { str=8, dex=12, mag=12, wil=12, con=10 },

	resists = { [DamageType.PHYSICAL] = 10, [DamageType.TEMPORAL] = 100, },

	no_breath = 1,
	poison_immune = 1,
	disease_immune = 1,
}

newEntity{ base = "BASE_NPC_TELUGOROTH",
	name = "telugoroth", color=colors.KHAKI,
	desc = [[A temporal elemental, rarely encountered except by those who travel through time itself.  It's blurred form constantly shifts before your eyes.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },

	resolvers.talents{
		[Talents.T_TURN_BACK_THE_CLOCK]=3,
	},
}

newEntity{ base = "BASE_NPC_TELUGOROTH",
	name = "greater telugoroth", color=colors.YELLOW,
	desc = [[A temporal elemental, rarely encountered except by those who travel through time itself.  It's blurred form constantly shifts before your eyes.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(70,80), life_rating = 10,
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },

	resolvers.talents{
		[Talents.T_TURN_BACK_THE_CLOCK]=4,
		[Talents.T_ECHOES_FROM_THE_PAST]=3,
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_TELUGOROTH",
	name = "ultimate telugoroth", color=colors.GOLD,
	desc = [[A temporal elemental, rarely encountered except by those who travel through time itself.  It's blurred form constantly shifts before your eyes.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 6,
	rank = 3,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },

	ai = "tactical",

	resolvers.talents{
		[Talents.T_TURN_BACK_THE_CLOCK]=5,
		[Talents.T_ECHOES_FROM_THE_PAST]=4,
		[Talents.T_RETHREAD]=3,
		[Talents.T_STOP]=4,
	},
	resolvers.sustains_at_birth(),
}
-- telu vorta = time storm
newEntity{ base = "BASE_NPC_TELUGOROTH",
	name = "teluvorta", color=colors.DARK_KHAKI,
	desc = [[Time and space collapse in upon this erratically moving time elemental.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(50,70),
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_snake" },

	stun_immune = 1,
	blind_immune = 1,
	confusion_immune = 1,
	pin_immune = 1,

	resolvers.talents{
		[Talents.T_ANOMALY_REARRANGE]=1,
		[Talents.T_TEMPORAL_WAKE]=3,
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_TELUGOROTH",
	name = "greater teluvorta", color=colors.TAN,
	desc = [[Time and space collapse in upon this erratically moving time elemental.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(50,70),
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_snake" },

	stun_immune = 1,
	blind_immune = 1,
	confusion_immune = 1,
	pin_immune = 1,

	resolvers.talents{
		[Talents.T_DIMENSIONAL_STEP]=5,
		[Talents.T_ANOMALY_REARRANGE]=1,
		[Talents.T_TEMPORAL_WAKE]=4,
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_TELUGOROTH",
	name = "ultimate teluvorta", color=colors.DARK_TAN,
	desc = [[Time and space collapse in upon this erratically moving time elemental.]],
	level_range = {18, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	size_category = 4,
	max_life = resolvers.rngavg(50,70),
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_snake" },

	stun_immune = 1,
	blind_immune = 1,
	confusion_immune = 1,
	pin_immune = 1,

	resolvers.talents{
		[Talents.T_ANOMALY_TEMPORAL_STORM]=1,
		[Talents.T_QUANTUM_SPIKE]=5,
		[Talents.T_DIMENSIONAL_STEP]=5,
		[Talents.T_ANOMALY_REARRANGE]=1,
		[Talents.T_TEMPORAL_WAKE]=4,
	},
	resolvers.sustains_at_birth(),
}
