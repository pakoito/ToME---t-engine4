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

load("/data/general/npcs/gwelgoroth.lua", function(e) if e.rarity then e.derth_rarity, e.rarity = e.rarity, nil end end)

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_LAST_HOPE_TOWN",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.WHITE,
	faction = "allied-kingdoms",
	anger_emote = "Catch @himher@!",

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.inscriptions(1, "infusion"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	stats = { str=12, dex=8, mag=6, con=10 },

	emote_random = resolvers.emote_random{allow_backup_guardian=true},
}

newEntity{ base = "BASE_NPC_LAST_HOPE_TOWN",
	name = "last hope guard", color=colors.LIGHT_UMBER,
	desc = [[A stern-looking guard, he will not let you disturb the town.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_RUSH]=1, [Talents.T_PERFECT_STRIKE]=1, },
}

newEntity{ base = "BASE_NPC_LAST_HOPE_TOWN",
	name = "halfling guard", color=colors.UMBER,
	subtype = "halfling",
	desc = [[A Halfling, with a sling. Beware.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(50,60),
	resolvers.talents{ [Talents.T_SHOOT]=1, },
	ai_state = { talent_in=2, },
	autolevel = "slinger",
	resolvers.equip{ {type="weapon", subtype="sling", autoreq=true}, {type="ammo", subtype="shot", autoreq=true} },
}

newEntity{ base = "BASE_NPC_LAST_HOPE_TOWN",
	name = "human citizen", color=colors.WHITE,
	desc = [[A clean looking human resident of Last Hope.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(30,40),
	combat_armor = 2, combat_def = 0,
}

newEntity{ base = "BASE_NPC_LAST_HOPE_TOWN",
	name = "halfling citizen", color=colors.WHITE,
	subtype = "halfling",
	desc = [[A clean looking halfling resident of Last Hope.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(30,40),
}
