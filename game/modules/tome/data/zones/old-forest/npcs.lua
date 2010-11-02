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

load("/data/general/npcs/bear.lua", rarity(1))
load("/data/general/npcs/vermin.lua", rarity(3))
load("/data/general/npcs/canine.lua", rarity(0))
load("/data/general/npcs/snake.lua", rarity(0))
load("/data/general/npcs/swarm.lua", rarity(1))
load("/data/general/npcs/plant.lua", rarity(0))
load("/data/general/npcs/ant.lua", rarity(2))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

-- The boss of trollshaws, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "WILLOWRATH",
	type = "giant", subtype = "huorn", unique = true,
	name = "Willowrath",
	display = "#", color=colors.OLIVE_DRAB,
	desc = [[The ancient grey willow tree, ruler of the Old Forest. He despises
	trespassers in his territory.]],
	level_range = {12, 35}, exp_worth = 2,
	max_life = 200, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 200,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	rank = 4,
	size_category = 5,
	infravision = 20,
	instakill_immune = 1,
	move_others=true,

	combat = { dam=27, atk=10, apr=0, dammod={str=1.2} },

	resists = { [DamageType.FIRE] = -50 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{ {type="armor", subtype="shield", defined="WILLOWRATH_SHIELD", random_art_replace={chance=75}, autoreq=true}, },
	drops = resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=2,

		[Talents.T_MANA_POOL]=1,
		[Talents.T_ICE_STORM]=1,
		[Talents.T_TIDAL_WAVE]=1,
		[Talents.T_FREEZE]=2,
	},

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar", },

	on_die = function(self, who)
		game.state:activateBackupGuardian("SNAPROOT", 3, 50, "Have you heard, the old forest seems to have been claimed bya new evil!")
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "old-forest")
	end,
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "cute little bunny", color=colors.SALMON,
	desc = [[It looks at you with cute little eyes before jumping at you with razor sharp teeth.]],
	level_range = {1, 15}, exp_worth = 3,
	rarity = 200,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=50, atk=15, apr=10 },
	combat_armor = 1, combat_def = 20,
}

newEntity{ define_as = "SNAPROOT", -- backup guardian
	type = "giant", subtype = "ent", unique = true,
	name = "Snaproot",
	display = "#", color=VIOLET,
	desc = [[This ancient Treant's bark is scorched almost black. It sees humanity as a scourge, to be purged.]],
	level_range = {50, 75}, exp_worth = 3,

	max_life = 1000, life_rating = 40, fixed_rating = true,
	max_stamina = 200,

	combat = { dam=100, atk=10, apr=0, dammod={str=1.2} },

	stats = { str=40, dex=10, cun=15, mag=20, wil=38, con=45 },

	rank = 4,
	size_category = 5,
	infravision = 20,
	instakill_immune = 1,
	stun_immune = 1,
	move_others = true,

	resists = { [DamageType.FIRE] = -20, [DamageType.PHYSICAL] = 50, [DamageType.COLD] = 50, [DamageType.NATURE] = 25 },
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="PETRIFIED_WOOD", random_art_replace={chance=75}}},
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },
	resolvers.talents{
		[Talents.T_STUN]=5,
		[Talents.T_GRAB]=5,
		[Talents.T_THROW_BOULDER]=5,
		[Talents.T_CRUSH]=5,
	},
	autolevel = "warriorwill",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar", },
}
