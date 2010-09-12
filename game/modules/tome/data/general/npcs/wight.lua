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

--  Wights had the power to confuse and paralyze
-- their icy grasp will sap willpower and drain exp
--
--they will have high treasure, but be *hard*

--in the books they could confuse and paralyze and sleep and bend lesser minds to do their will and cause fear.  fear would be more of an aura (need to save against it, but realistically it would only be once).
-- they could also be mind affecting too :)

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_WIGHT",
	type = "undead", subtype = "wight",
	display = "W", color=colors.WHITE,
	desc = [[These be white wights.]],

	combat = { dam=resolvers.mbonus(30, 10), atk=10, apr=9, damtype=DamageType.DRAINEXP },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {ego_chance=20} },

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=4, },
	energy = { mod=1 },
	stats = { str=11, dex=11, mag=15, con=12 },
	infravision = 20,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.tmasteries{ ["technique/other"]=0.3, ["spell/air"]=0.3, ["spell/fire"]=0.3 },
	resolvers.sustains_at_birth(),

	resists = { [DamageType.COLD] = 80, [DamageType.FIRE] = 20, [DamageType.LIGHTNING] = 40, [DamageType.PHYSICAL] = 35, [DamageType.LIGHT] = -50, },
	poison_immune = 1,
	blind_immune = 1,
	see_invisible = 7,
	undead = 1,
--	free_action = 1,
--	sleep_immune = 1,
}

newEntity{ base = "BASE_NPC_WIGHT",
	name = "forest wight", color=colors.GREEN,
	desc=[[It is a ghostly apparition with a humanoid form.]],
	level_range = {16, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(40,50),
	combat_armor = 7, combat_def = 6,

	resolvers.talents{
		[Talents.T_FLAMESHOCK]=1, [Talents.T_LIGHTNING]=1, [Talents.T_CORROSIVE_VAPOUR]=1,
		[Talents.T_MIND_DISRUPTION]=1,
	},
}

newEntity{ base = "BASE_NPC_WIGHT",
	name = "grave wight", color=colors.SLATE,
	desc=[[It is a ghostly form with eyes that haunt you.]],
	level_range = {22, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 9, combat_def = 6,

	resolvers.talents{ [Talents.T_MANA_POOL]=1, [Talents.T_FLAMESHOCK]=2, [Talents.T_LIGHTNING]=2, [Talents.T_CORROSIVE_VAPOUR]=2,
		[Talents.T_MIND_DISRUPTION]=2,
	},
}

newEntity{ base = "BASE_NPC_WIGHT",
	name = "barrow wight", color=colors.LIGHT_RED,
	desc=[[It is a ghostly nightmare of an entity.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(80,90),
	combat_armor = 10, combat_def = 8,

	resolvers.talents{ [Talents.T_MANA_POOL]=1, [Talents.T_FLAMESHOCK]=3, [Talents.T_LIGHTNING]=3, [Talents.T_CORROSIVE_VAPOUR]=3,
		[Talents.T_MIND_DISRUPTION]=3,
	},
}

newEntity{ base = "BASE_NPC_WIGHT",
	name = "emperor wight", color=colors.RED,
	desc=[[Your life force is torn from your body as this powerful unearthly being approaches.]],
	level_range = {30, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(100,150),
	max_mana = resolvers.rngavg(300,350),
	combat_armor = 12, combat_def = 10,
	make_escort = {
		{type="undead", subtype="wight", number=resolvers.mbonus(2, 2)},
	},
	resolvers.talents{ [Talents.T_MANA_POOL]=3, [Talents.T_FLAMESHOCK]=3, [Talents.T_LIGHTNING]=4, [Talents.T_CORROSIVE_VAPOUR]=3, [Talents.T_THUNDERSTORM]=2,
		[Talents.T_MIND_DISRUPTION]=4,
	},
}
