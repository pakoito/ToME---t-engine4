-- ToME - Tales of Maj'Eyal
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
load("/data/general/npcs/vermin.lua", rarity(7))
load("/data/general/npcs/ooze.lua", rarity(5))
load("/data/general/npcs/jelly.lua", rarity(7))
load("/data/general/npcs/sandworm.lua", rarity(0))

--load("/data/general/npcs/all.lua", rarity(4, 35))

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
	faction = "sandworm-burrowers",
	energy = {mod=1},

	invulnerable = 1,
	move_body = 1,
	size_category = 5,
	no_breath = 1,

	autolevel = "warrior",
	ai = "sandworm_tunneler", ai_state = {},
}

-- The boss of the sandworm lair, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "SANDWORM_QUEEN",
	allow_infinite_dungeon = true,
	type = "vermin", subtype = "sandworm", unique = true,
	name = "Sandworm Queen",
	display = "w", color=colors.VIOLET,
	desc = [[Before you stands the queen of the sandworms. Massive and bloated she slugs toward you, calling for her offspring!]],
	level_range = {15, 50}, exp_worth = 2,
	max_life = 150, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 85,
	infravision = 20,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	move_others=true,

	instakill_immune = 1,
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
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_astar", },

	on_die = function(self, who)
		game.state:activateBackupGuardian("CORRUPTED_SAND_WYRM", 1, 45, "Did you hear? Something seems to have devoured all the last sandworms!", function(gen)
			if gen then return end
			for i = #game.level.e_array, 1, -1 do
				local e = game.level.e_array[i]
				if not e.unique and not e.player then game.level:removeEntity(e) end
			end
		end)
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "sandworm-lair")
	end,
}

-- The boss of the sandworm lair, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "CORRUPTED_SAND_WYRM",
	allow_infinite_dungeon = true,
	type = "dragon", subtype = "sand", unique = true,
	name = "Corrupted Sand Wyrm",
	display = "D", color=colors.VIOLET,
	desc = [[The sandworms are gone, devoured by this shrieking, warped horror.]],
	level_range = {47, nil}, exp_worth = 3,
	max_life = 850, life_rating = 24, fixed_rating = true,
	infravision = 20,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	move_others=true,

	instakill_immune = 1,
	blind_immune = 1,
	no_breath = 1,
	rank = 4,
	size_category = 5,

	combat = { dam=140, atk=130, apr=25, dammod={str=1.2} },

	resists = { [DamageType.BLIGHT] = 25, [DamageType.NATURE] = 50 },

	body = { INVEN = 10, BODY=1 },

	can_pass = {pass_wall=20},
	move_project = {[DamageType.DIG]=1},

	resolvers.drops{chance=100, nb=1, {defined="PUTRESCENT_POTION"}, },
	resolvers.drops{chance=100, nb=5, {type="gem"} },

	resolvers.talents{
		[Talents.T_BLOOD_GRASP]=5,
		[Talents.T_BLIGHTZONE]=5,
		[Talents.T_SOUL_ROT]=5,
		[Talents.T_RUSH]=5,
		[Talents.T_SWALLOW]=3,
		[Talents.T_SAND_BREATH]=9,
		[Talents.T_STUN]=5,
		[Talents.T_KNOCKBACK]=5,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { ai_target="target_player_radius", sense_radius=400, talent_in=1, },
}
