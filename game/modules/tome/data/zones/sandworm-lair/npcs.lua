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

-- Load some various npc types but up their rarity to make some sandworms are the norm
load("/data/general/npcs/vermin.lua", function(e) if e.rarity then e.rarity = e.rarity * 6 end end)
load("/data/general/npcs/ooze.lua", function(e) if e.rarity then e.rarity = e.rarity * 6 end end)
load("/data/general/npcs/jelly.lua", function(e) if e.rarity then e.rarity = e.rarity * 6 end end)
load("/data/general/npcs/sandworm.lua")

local Talents = require("engine.interface.ActorTalents")

-- They make the tunnels, temporarily
-- High life to not kill them by accident
newEntity{ define_as = "SANDWORM_TUNNELER",
	type = "vermin", subtype = "sandworm",
	name = "sandworm burrower",
	display = "w", color=colors.GREEN,
	desc = [[This sandworm seems to not care about your presence at all and simply continues digging its way through the sand.
	Maybe following it is the only way to move around here...]],
	level_range = {12, 50}, exp_worth = 0,
	max_life = 10000,
	faction = "sandworm burrowers",
	energy = {mod=1},

	move_body = 1,
	size_category = 5,

	autolevel = "warrior",
	ai = "sandworm_tunneler", ai_state = {},
}

-- The boss of the sandworm lair, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "SANDWORM_QUEEN",
	type = "vermin", subtype = "sandworm", unique = true,
	name = "Sandworm Queen",
	display = "w", color=colors.VIOLET,
	desc = [[Before you stands the queen of the sandworms. Massive and bloated she slugs toward you, calling for her offspring!]],
	level_range = {15, 50}, exp_worth = 2,
	max_life = 150, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 85,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },

	stun_immune = 1,
	no_breath = 1,
	rank = 4,
	size_category = 5,

	resists = { [DamageType.FIRE] = 30, [DamageType.COLD] = -30 },

	body = { INVEN = 10, BODY=1 },

	resolvers.drops{chance=100, nb=1, {defined="SANDQUEEN_HEART"}, },
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_STAMINA_POOL]=1,
		[Talents.T_MANA_POOL]=1,
		[Talents.T_SUMMON]=1,
		[Talents.T_CRAWL_POISON]=5,
		[Talents.T_CRAWL_ACID]=3,
		[Talents.T_SAND_BREATH]=4,
	},

	summon = {
		{type="vermin", subtype="sandworm", number=4, hasxp=false},
	},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, },

	on_die = function(self, who)
		who:resolveSource():grantQuest("starter-zones")
		who:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "sandworm-lair")
	end,
}
