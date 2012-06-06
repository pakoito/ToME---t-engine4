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
	define_as = "BASE_NPC_ORC_RAK_SHOR",
	type = "humanoid", subtype = "orc",
	display = "o", color=colors.DARK_GREY,
	faction = "orc-pride", pride = "rak-shor",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 1,

	life_rating = 11,
	rank = 2,
	size_category = 3,

	resolvers.racial(),

	open_door = true,
	resolvers.inscriptions(3, "rune"),

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	stats = { str=20, dex=8, mag=6, con=16 },
	ingredient_on_death = "ORC_HEART",
}

newEntity{ base = "BASE_NPC_ORC_RAK_SHOR",
	name = "orc necromancer", color=colors.DARK_GREY,
	desc = [[An orc dressed in black robes. He mumbles in a harsh tongue.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(70,80), life_rating = 7,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 5,

	necrotic_aura_base_souls = resolvers.rngavg(5, 10),

	resolvers.talents{
		[Talents.T_NECROTIC_AURA] = 1,
		[Talents.T_AURA_MASTERY] = 5,
		[Talents.T_CREATE_MINIONS]={base=4, every=5, max=7},
		[Talents.T_RIGOR_MORTIS]={base=3, every=5, max=7},
		[Talents.T_INVOKE_DARKNESS]={base=5, every=5, max=9},
		[Talents.T_VAMPIRIC_GIFT]={base=2, every=7, max=7},
	},
	resolvers.rngtalent{
		[Talents.T_CIRCLE_OF_DEATH]={base=3, every=5, max=7},
		[Talents.T_SURGE_OF_UNDEATH]={base=3, every=5, max=7},
		[Talents.T_WILL_O__THE_WISP]={base=3, every=5, max=7},
		[Talents.T_FORGERY_OF_HAZE]={base=3, every=5, max=7},
		[Talents.T_FROSTDUSK]={base=3, every=5, max=7},
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_ORC_RAK_SHOR",
	name = "orc blood mage", color=colors.CRIMSON,
	desc = [[An orc dressed in blood-stained robes. He mumbles in a harsh tongue.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(110,120), life_rating = 12,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 5,

	-- Nullify their cooldowns
	talent_cd_reduction={[Talents.T_SOUL_ROT]=2, [Talents.T_BLOOD_GRASP]=4, },

	resolvers.talents{
		[Talents.T_SOUL_ROT]={base=5, every=10, max=8},
		[Talents.T_BLOOD_GRASP]={base=5, every=10, max=8},
		[Talents.T_CURSE_OF_VULNERABILITY]={base=5, every=10, max=8},
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_ORC_RAK_SHOR",
	name = "orc corruptor", color=colors.GREY,
	desc = [[An orc dressed in putrid robes. He mumbles in a harsh tongue.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	max_life = resolvers.rngavg(160,180), life_rating = 15,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 5,

	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",

	inc_damage = { [DamageType.BLIGHT] = resolvers.mbonus(20, 10) },

	resolvers.talents{
		[Talents.T_SOUL_ROT]={base=5, every=10, max=8},
		[Talents.T_BLOOD_GRASP]={base=5, every=10, max=8},
		[Talents.T_CURSE_OF_VULNERABILITY]={base=5, every=10, max=8},
		[Talents.T_BLIGHTZONE]={base=3, every=10, max=6},
		[Talents.T_BONE_SHIELD]={base=5, every=150, max=8},
		[Talents.T_BLOOD_SPRAY]={base=4, every=10, max=8},
	},
	resolvers.sustains_at_birth(),
}
