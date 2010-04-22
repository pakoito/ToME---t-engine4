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
	energy = { mod=1 },
	stats = { str=14, dex=12, mag=10, con=12 },
	rank = 2,
	size_category = 3,

	resolvers.tmasteries{ ["technique/other"]=1, },

	blind_immune = 1,
	see_invisible = 2,
	undead = 1,
}

newEntity{ base = "BASE_NPC_GHOUL",
	name = "ghoul", color=colors.TAN,
	desc = [[Flesh is falling off in chunks from this decaying abomination.]],
	level_range = {7, 50}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 2, combat_def = 7,
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=1, [Talents.T_BITE_POISON]=1, [Talents.T_ROTTING_DISEASE]=1, },
	ai_state = { talent_in=4, },

	combat = { dam=5, atk=5, apr=3, dammod={str=0.6} },
}

newEntity{ base = "BASE_NPC_GHOUL",
	name = "ghast", color=colors.UMBER,
	desc = [[This vile abomination is a relative of ghouls, and often leads packs of them. It smells foul, and its bite carries a rotting disease.]],
	level_range = {10, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 2, combat_def = 8,
	ai_state = { talent_in=3, },

	combat = { dam=7, atk=6, apr=3, dammod={str=0.6} },

	summon = {{type="undead", subtype="ghoul", name="ghoul", number=1, hasxp=false}, },
	resolvers.talents{ [Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=2, [Talents.T_BITE_POISON]=2,  [Talents.T_SUMMON]=1, [Talents.T_ROTTING_DISEASE]=2, [Talents.T_DECREPITUDE_DISEASE]=2, },
}

newEntity{ base = "BASE_NPC_GHOUL",
	name = "ghoulking", color={0,0,0},
	desc = [[Stench rises from this rotting abomination, its brow is adorned with gold, and it moves at you with hatred gleaming from its eyes.]],
	level_range = {15, 50}, exp_worth = 1,
	rarity = 10,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 3, combat_def = 10,
	ai_state = { talent_in=2, ai_pause=20 },

	rank = 3,

	combat = { dam=10, atk=8, apr=4, dammod={str=0.6} },

	summon = {
		{type="undead", subtype="ghoul", name="ghoul", number=1, hasxp=false},
		{type="undead", subtype="ghoul", name="ghast", number=1, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=3, [Talents.T_BITE_POISON]=3,  [Talents.T_SUMMON]=1,
		[Talents.T_ROTTING_DISEASE]=4, [Talents.T_DECREPITUDE_DISEASE]=3, [Talents.T_WEAKNESS_DISEASE]=3,
	},
}
