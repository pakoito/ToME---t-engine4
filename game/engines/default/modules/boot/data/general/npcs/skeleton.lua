-- ToME - Tales of Middle-Earth
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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SKELETON",
	type = "undead", subtype = "skeleton",
	display = "s", color=colors.WHITE,
	level_range = {1, nil}, exp_worth = 1,

	combat = { dam=1, atk=1, apr=1 },

	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	energy = { mod=1 },

	open_door = true,

	blind_immune = 1,
	fear_immune = 1,
	see_invisible = 2,
	undead = 1,
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "degenerated skeleton warrior", color=colors.WHITE, image="npc/degenerated_skeleton_warrior.png",
	rarity = 1,
	max_life = resolvers.rngavg(40,50),
	combat_armor = 5, combat_def = 1,
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "skeleton warrior", color=colors.SLATE, image="npc/skeleton_warrior.png",
	rarity = 1,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 5, combat_def = 1,
	ai_state = { talent_in=1, },
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "skeleton mage", color=colors.LIGHT_RED, image="npc/skeleton_mage.png",
	rarity = 3,
	max_life = resolvers.rngavg(50,60),
	max_mana = resolvers.rngavg(70,80),
	combat_armor = 3, combat_def = 1,
	stats = { str=10, dex=12, cun=14, mag=14, con=10 },
	resolvers.talents{ [Talents.T_FLAME]=2, [Talents.T_MANATHRUST]=3 },
}

newEntity{ base = "BASE_NPC_SKELETON",
	name = "armoured skeleton warrior", color=colors.STEEL_BLUE,
	level_range = {10, nil}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 5, combat_def = 1,
}
