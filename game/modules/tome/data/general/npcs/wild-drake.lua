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
	define_as = "BASE_NPC_WILD_DRAKE",
	type = "dragon", subtype = "wild",
	display = "D", color=colors.SLATE,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, PSIONIC_FOCUS=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {type="money"} },

	infravision = 10,
	life_rating = 15,
	rank = 2,
	size_category = 5,

	autolevel = "drake",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
	stats = { str=20, dex=20, mag=30, con=16 },

	knockback_immune = 1,
	stun_immune = 0.6,
	blind_immune = 0.6,
	resolvers.sustains_at_birth(),
}


newEntity{ base = "BASE_NPC_WILD_DRAKE",
	name = "spire dragon", color=colors.SLATE, display="D",
	desc = [[A monstrous, coiled wyrm, patient and hateful. Its hide, studded with spikes and crests and blades, turns aside steel and sorcery with equal ease.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/dragon_wild_spire_dragon.png", display_h=2, display_y=-1}}},
	level_range = {35, nil}, exp_worth = 1,
	rarity = 6,
	rank = 3,
	global_speed_base = 1.3,
	size_category = 5,
	autolevel = "warrior",
	max_life = resolvers.rngavg(170,190),
	combat_armor = 70, combat_def = 50,
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,110), 1, 2), atk=resolvers.rngavg(25,70), apr=45, dammod={str=1.5} },
	resists={all = resolvers.mbonus(25, 30)},
	--resolvers.equip{ {type="gem", autoreq=true}, },
	resolvers.drops{chance=100, nb=2, {type="gem"} },

	ai = "tactical",

	resolvers.talents{
		[Talents.T_CONSTRICT]={base=4, every=5, max = 10},
		[Talents.T_RUSHING_CLAWS]={base=3, every=5, max = 5},
		[Talents.T_KINETIC_AURA]={base=4, every=5, max = 8},
		[Talents.T_KINETIC_SHIELD]={base=4, every=5, max = 8},
		[Talents.T_SHATTERING_CHARGE]={base=4, every=5, max = 10},
		[Talents.T_INSATIABLE]={base=5, every=5, max = 30},
	},
}

newEntity{ base = "BASE_NPC_WILD_DRAKE",
	name = "blinkwyrm", color=colors.YELLOW, display="D",
	desc = [[A shifting, writhing, snake-like dragon, blinking in and out of existance, just waiting for you to turn your back.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/dragon_wild_blinkwyrm.png", display_h=2, display_y=-1}}},
	level_range = {40, nil}, exp_worth = 1,
	rarity = 7,
	rank = 3,
	global_speed_base = 1.4,
	size_category = 4,
	autolevel = "caster",
	max_life = resolvers.rngavg(100,120),
	combat_armor = 0, combat_def = 90,
	mana_regen = 100, positive_regen = 100, negative_regen = 100, equilibrium_regen = -100, vim_regen = 100, stamina_regen = 100,

	ai = "tactical",

	resolvers.talents{
		[Talents.T_DISRUPTION_SHIELD]={base=4, every=5, max = 10},
		[Talents.T_DISPLACEMENT_SHIELD]={base=3, every=5, max = 10},
		[Talents.T_TIME_SHIELD]={base=4, every=5, max = 10},
		[Talents.T_ARCANE_POWER]={base=4, every=5, max = 8},
		[Talents.T_MANATHRUST]={base=4, every=5, max = 10},
		[Talents.T_MANAFLOW]={base=5, every=5, max = 10},
		[Talents.T_DISPERSE_MAGIC]={base=4, every=5, max = 8},
		[Talents.T_QUICKEN_SPELLS]={base=4, every=5, max = 10},
		[Talents.T_METAFLOW]={base=5, every=5, max = 10},
		[Talents.T_ESSENCE_OF_SPEED]={base=4, every=5, max = 10},
		[Talents.T_MINDLASH]={base=5, every=5, max = 10},
		[Talents.T_KINETIC_LEECH]={base=5, every=5, max = 10},
		[Talents.T_THERMAL_LEECH]={base=4, every=5, max = 10},
		[Talents.T_CHARGE_LEECH]={base=5, every=5, max = 10},
		[Talents.T_INSATIABLE]={base=5, every=5, max = 30},
		[Talents.T_PHASE_DOOR]={base=5, every=5, max = 10},
		[Talents.T_PROBABILITY_TRAVEL]={base=5, every=5, max = 10},
	},

	resolvers.inscriptions(2, {"phase door rune", "phase door rune"}),

}
