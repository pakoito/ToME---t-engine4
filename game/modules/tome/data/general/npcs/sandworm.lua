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
	define_as = "BASE_NPC_SANDWORM",
	type = "vermin", subtype = "sandworm",
	display = "w", color=colors.YELLOW,
	level_range = {15, nil},
	body = { INVEN = 10 },

	infravision = 20,
	max_life = 40, life_rating = 5,
	max_stamina = 85,
	max_mana = 85,
	resists = { [DamageType.FIRE] = 30, [DamageType.COLD] = -30 },
	rank = 2,
	size_category = 2,

	drops = resolvers.drops{chance=20, nb=1, {type="potion"}, {type="scroll"} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	stats = { str=15, dex=7, mag=3, con=3 },
	combat_armor = 1, combat_def = 1,
}

newEntity{ base = "BASE_NPC_SANDWORM",
	name = "sandworm",
	desc = [[A huge worm coloured as the sand it inhabits. It seems quite unhappy about you being in its lair..]],
	rarity = 4,
}

newEntity{ base = "BASE_NPC_SANDWORM",
	name = "sandworm destroyer",
	color={r=169,g=168,b=52},
	desc = [[A huge worm coloured as the sand it inhabits. This particular sandworm seems to have been bred for one purpose only, the eradication of everything that is non-sandworm, such as ... you.]],
	rarity = 6,

	resolvers.talents{
		[Talents.T_STAMINA_POOL]=1,
		[Talents.T_STUN]=2,
		[Talents.T_KNOCKBACK]=2,
	},
}

newEntity{ base = "BASE_NPC_SANDWORM",
	name = "sand-drake", display = 'D',
	color={r=204,g=255,b=95},
	desc = [[This unholy creature looks like a wingless dragon in shape, but resembles a sandworm in color.]],
	rarity = 8,
	rank = 3,
	size_category = 5,

	resolvers.talents{
		[Talents.T_STAMINA_POOL]=1,
		[Talents.T_SAND_BREATH]=3,
		[Talents.T_KNOCKBACK]=2,
	},
}
