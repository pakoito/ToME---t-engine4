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
	define_as = "BASE_NPC_TROLL",
	type = "giant", subtype = "troll",
	display = "T", color=colors.UMBER,
	level_range = {1, nil}, exp_worth = 1,

	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	energy = { mod=1 },

	open_door = true,
	fear_immune = 1,
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "forest troll", color=colors.YELLOW_GREEN, image="npc/troll_f.png",
	desc = [[Green-skinned and ugly, this massive humanoid glares at you, clenching wart-covered green fists.]],
	rarity = 1,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 4, combat_def = 0,
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "stone troll", color=colors.DARK_SLATE_GRAY, image="npc/troll_s.png",
	desc = [[A giant troll with scabrous black skin. With a shudder, you notice the belt of dwarf skulls around his massive waist.]],
	rarity = 1,
	max_life = resolvers.rngavg(120,140),
	combat_armor = 7, combat_def = 0,
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "cave troll", color=colors.SLATE, image="npc/troll_c.png",
	desc = [[This huge troll wields a massive spear and has a disturbingly intelligent look in its piggy eyes.]],
	rarity = 2,
	max_life = resolvers.rngavg(120,140),
	combat_armor = 9, combat_def = 3,
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "mountain troll", color=colors.UMBER, image="npc/troll_m.png",
	desc = [[A large and athletic troll with an extremely tough and warty hide.]],
	rarity = 3,
	max_life = resolvers.rngavg(120,140),
	combat_armor = 12, combat_def = 4,
}

newEntity{ base = "BASE_NPC_TROLL",
	name = "mountain troll thunderer", color=colors.AQUAMARINE, image="npc/troll_mt.png",
	desc = [[A large and athletic troll with an extremely tough and warty hide.]],
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(120,140),
	combat_armor = 8, combat_def = 4,
	resolvers.talents{
		[Talents.T_LIGHTNING]=4,
	},
}
