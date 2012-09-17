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
	define_as = "BASE_NPC_GHOUL",
	type = "undead", subtype = "ghoul",
	display = "z", color=colors.WHITE,

	combat = { dam=1, atk=1, apr=1 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	drops = resolvers.drops{chance=70, nb=1, {type="money"}, {} },
	autolevel = "ghoul",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
	stats = { str=14, dex=12, mag=10, con=12 },
	rank = 2,
	size_category = 3,
	infravision = 10,

	resolvers.racial(),

	open_door = true,

	blind_immune = 1,
	see_invisible = 2,
	undead = 1,
	ingredient_on_death = "GHOUL_FLESH",
	not_power_source = {nature=true},
}

newEntity{ base = "BASE_NPC_GHOUL",
	name = "ghoul", color=colors.TAN, define_as = "GHOUL",
	desc = [[Flesh is falling off in chunks from this decaying abomination.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 2, combat_def = 7,
	resolvers.talents{
		[Talents.T_STUN]={base=1, every=10, max=5},
		[Talents.T_BITE_POISON]={base=1, every=10, max=5},
		[Talents.T_ROTTING_DISEASE]={base=1, every=10, max=5},
	},
	ai_state = { talent_in=4, },

	combat = { dam=resolvers.levelup(10, 1, 1), atk=resolvers.levelup(5, 1, 1), apr=3, dammod={str=0.6} },
}

newEntity{ base = "BASE_NPC_GHOUL",
	name = "ghast", color=colors.UMBER,
	desc = [[This vile abomination is a relative of ghouls, and often leads packs of them. It smells foul, and its bite carries a rotting disease.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 2, combat_def = 8,
	ai_state = { talent_in=3, },

	combat = { dam=resolvers.levelup(17, 1, 1.1), atk=resolvers.levelup(6, 1, 1), apr=3, dammod={str=0.6} },

	summon = {{type="undead", subtype="ghoul", name="ghoul", number=1, hasxp=false}, },
	resolvers.talents{
		[Talents.T_STUN]={base=2, every=9, max=5},
		[Talents.T_BITE_POISON]={base=2, every=9, max=5},
		[Talents.T_SUMMON]=1,
		[Talents.T_ROTTING_DISEASE]={base=2, every=9, max=5},
		[Talents.T_DECREPITUDE_DISEASE]={base=2, every=9, max=5},
	},
}

newEntity{ base = "BASE_NPC_GHOUL",
	name = "ghoulking", color={0,0,0},
	desc = [[Stench rises from this rotting abomination. Its brow is adorned with gold, and it moves at you with hatred gleaming from its eyes.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 3, combat_def = 10,
	ai_state = { talent_in=2, ai_pause=20 },

	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	combat = { dam=resolvers.levelup(30, 1, 1.2), atk=resolvers.levelup(8, 1, 1), apr=4, dammod={str=0.6} },

	summon = {
		{type="undead", subtype="ghoul", name="ghoul", number=1, hasxp=false},
		{type="undead", subtype="ghoul", name="ghast", number=1, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_STUN]={base=3, every=9, max=7},
		[Talents.T_BITE_POISON]={base=3, every=9, max=7},
		[Talents.T_SUMMON]=1,
		[Talents.T_ROTTING_DISEASE]={base=4, every=9, max=7},
		[Talents.T_DECREPITUDE_DISEASE]={base=3, every=9, max=7},
		[Talents.T_WEAKNESS_DISEASE]={base=3, every=9, max=7},
	},
}

newEntity{ base = "BASE_NPC_GHOUL", define_as = "RISEN_CORPSE",
	display = "z", color=colors.GREY, image="npc/undead_ghoul_ghoul.png",
	name = "risen corpse",
	desc = [[a body raised through dark magic]],
	exp_worth = 1,
	combat_armor = 5, combat_def = 3,
	resolvers.equip{
		{type="weapon", subtype="longsword", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.talents{
		[Talents.T_STUN]={base=3, every=9, max=7},
		[Talents.T_BITE_POISON]={base=3, every=9, max=7},
		[Talents.T_ROTTING_DISEASE]={base=4, every=9, max=7},
		},
}
