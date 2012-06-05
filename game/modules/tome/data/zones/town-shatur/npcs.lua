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
	define_as = "BASE_NPC_ELVALA_TOWN",
	type = "humanoid", subtype = "thalore",
	display = "p", color=colors.WHITE,
	faction = "thalore",
	anger_emote = "Catch @himher@!",

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.inscriptions(1, "rune"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },

	emote_random = resolvers.emote_random{allow_backup_guardian=true},
}

newEntity{ base = "BASE_NPC_ELVALA_TOWN",
	name = "thalore hunter", color=colors.LIGHT_UMBER,
	desc = [[A stern-looking guard, he will not let you disturb the town.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.talents{
		[Talents.T_BOW_MASTERY]={base=1, every=10, max=5},
		[Talents.T_SHOOT]=1,
	},
	ai_state = { talent_in=1, },

	autolevel = "archer",
	resolvers.inscriptions(1, "infusion"),
	resolvers.equip{
		{type="weapon", subtype="longbow", autoreq=true},
		{type="ammo", subtype="arrow", autoreq=true},
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_ELVALA_TOWN",
	name = "thalore wilder", color=colors.GREEN,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_thalore_thalore_wilder.png", display_h=2, display_y=-1}}},
	desc = [[A tall elf, his skin covered in green moss.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(50,60),
	ai_state = { talent_in=1, },
	autolevel = "wildcaster",
	resolvers.talents{
		[Talents.T_RIMEBARK]={base=1, every=5, max=10},
		[Talents.T_WAR_HOUND]={base=1, every=5, max=10},
	},
	resolvers.inscriptions(3, "infusion"),
}
