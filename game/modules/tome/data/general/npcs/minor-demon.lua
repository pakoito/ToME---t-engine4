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

-- last updated:  10:46 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_DEMON",
	type = "demon", subtype = "minor",
	display = "u", color=colors.WHITE,
	blood_color = colors.GREEN,
	faction = "fearscape",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	stats = { str=12, dex=10, mag=3, con=13 },
	life_rating = 7,
	combat_armor = 1, combat_def = 1,
	combat = { dam=resolvers.mbonus(46, 20), atk=15, apr=7, dammod={str=0.7} },
	max_life = resolvers.rngavg(100,120),
	infravision = 10,
	open_door = true,
	rank = 2,
	size_category = 3,
	no_breath = 1,
	demon = 1,
	random_name_def = "demon",
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
		[Talents.T_RITCH_FLAMESPITTER_BOLT]={base=4, every=8, max=8},
		[Talents.T_PHASE_DOOR]=2,
	},
}

newEntity{ base = "BASE_NPC_DEMON",
	name = "wretchling", color=colors.GREEN,
	desc = "Acid oozes all over this small demon's skin.  Beware, they tend to hunt in packs.",
	level_range = {16, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	size_category = 1,
	autolevel = "caster",
	combat_armor = 1, combat_def = 0,
	combat = {dam=resolvers.mbonus(55, 15), apr=10, atk=resolvers.mbonus(50, 15), damtype=DamageType.ACID, dammod={mag=1}},

	resists={[DamageType.ACID] = 100},

	resolvers.talents{
		[Talents.T_RUSH]=6,
		[Talents.T_ACID_BLOOD]={base=3, every=10, max=6},
		[Talents.T_CORROSIVE_VAPOUR]={base=3, every=10, max=6},
	},

	make_escort = {
		{type="demon", subtype="minor", name="wretchling", number=rng.range(1, 4), no_subescort=true},
	},
	ingredient_on_death = "WRETCHLING_EYE",
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
		[Talents.T_ARMOUR_TRAINING]={base=3, every=6, max=7},
		[Talents.T_SHIELD_PUMMEL]={base=2, every=6, max=5},
		[Talents.T_RIPOSTE]={base=3, every=6, max=6},
		[Talents.T_OVERPOWER]={base=1, every=6, max=5},
		[Talents.T_RUSH]=6,
	},
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true}
	},
}
