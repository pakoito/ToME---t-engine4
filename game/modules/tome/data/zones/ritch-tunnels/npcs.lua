-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

load("/data/general/npcs/ritch.lua", rarity(0))
load("/data/general/npcs/vermin.lua", rarity(0))
load("/data/general/npcs/ant.lua", rarity(2))
load("/data/general/npcs/jelly.lua", rarity(3))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_RITCH_REL",
	type = "insect", subtype = "ritch",
	display = "I", color=colors.RED,
	desc = [[Ritches are giant insects native to the arid wastes of the southern parts of the Far East.
Vicious predators, they inject corrupting diseases into their foes, and their sharp claws cut through most armours.]],
	killer_message = ", who incubated her eggs in the corpse,",

	combat = { dam=resolvers.rngavg(10,32), atk=0, apr=4, damtype=DamageType.BLIGHT, dammod={dex=1.2} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	size_category = 1,
	rank = 2,

	autolevel = "slinger",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=15, dex=15, mag=8, con=10 },

	poison_immune = 0.5,
	disease_immune = 0.5,
	ingredient_on_death = "RITCH_STINGER",
	resists = { [DamageType.BLIGHT] = 20, [DamageType.FIRE] = 40 },
}

newEntity{ base = "BASE_NPC_RITCH_REL",
	name = "ritch flamespitter", color=colors.DARK_RED,
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 5,
	life_rating = 3,
	lite = 1,

	rank = 2,

	ai_state = { ai_move="move_complex", talent_in=1, },
	resolvers.talents{
		[Talents.T_RITCH_FLAMESPITTER_BOLT]=1,
	},
}

newEntity{ base = "BASE_NPC_RITCH_REL",
	name = "ritch impaler", color=colors.UMBER,
	level_range = {2, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 50,
	life_rating = 11,

	rank = 2,

	ai_state = { ai_move="move_complex", talent_in=1, },
	resolvers.talents{
		[Talents.T_RUSHING_CLAWS]=1,
	},
}

newEntity{ base = "BASE_NPC_RITCH_REL",
	name = "chitinous ritch", color=colors.YELLOW,
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 100,
	life_rating = 13,

	rank = 2,
	combat_armor = 6,

	ai_state = { ai_move="move_complex", talent_in=1, },
}

newEntity{ base = "BASE_NPC_RITCH_REL", define_as = "HIVE_MOTHER",
	unique = true,
	name = "Ritch Great Hive Mother", image = "npc/insect_ritch_ritch_hive_mother.png",
	display = "I", color=colors.VIOLET,
	desc = [[This huge ritch seems to be the mother of all those here. Her sharp, fiery, claws dart toward you!]],
	level_range = {7, nil}, exp_worth = 2,
	max_life = 120, life_rating = 14, fixed_rating = true,
	equilibrium_regen = -50,
	infravision = 10,
	stats = { str=15, dex=10, cun=8, mag=16, wil=16, con=10 },
	move_others=true,

	instakill_immune = 1,
	blind_immune = 1,
	no_breath = 1,
	tier1 = true,
	rank = 4,
	size_category = 4,

	combat = { dam=30, atk=22, apr=7, dammod={str=1.1} },

	resists = { [DamageType.BLIGHT] = 40 },

	body = { INVEN = 10, BODY=1 },

	inc_damage = {all=-30},

	resolvers.drops{chance=100, nb=1, {defined="FLAMEWROUGHT", random_art_replace={chance=75}}, },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_SUMMON]=1,
		[Talents.T_SHRIEK]=2,
		[Talents.T_WEAKNESS_DISEASE]=1,
		[Talents.T_RITCH_FLAMESPITTER_BOLT]=2,
		[Talents.T_SPIT_BLIGHT]=2,
	},
	resolvers.sustains_at_birth(),

	summon = {
		{type="insect", subtype="ritch", number=1, hasxp=false},
	},

	autolevel = "dexmage",
	ai = "tactical", ai_state = { talent_in=2, },

	on_die = function(self, who)
		game.player:setQuestStatus("start-yeek", engine.Quest.COMPLETED, "ritch")
	end,
}
