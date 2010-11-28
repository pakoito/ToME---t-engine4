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

load("/data/general/npcs/rodent.lua", rarity(5))
load("/data/general/npcs/vermin.lua", rarity(2))
load("/data/general/npcs/canine.lua", rarity(0))
load("/data/general/npcs/troll.lua", rarity(0))
load("/data/general/npcs/snake.lua", rarity(3))
load("/data/general/npcs/plant.lua", rarity(0))
load("/data/general/npcs/swarm.lua", rarity(3))
load("/data/general/npcs/bear.lua", rarity(2))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

-- The boss of trollshaws, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "TROLL_BILL",
	allow_infinite_dungeon = true,
	type = "giant", subtype = "troll", unique = true,
	name = "Bill the Stone Troll",
	display = "T", color=colors.VIOLET, image="npc/troll_bill.png",
	desc = [[Big, brawny, powerful and with a taste for halfling.
He is wielding a small tree trunk and towering toward you.]],
	level_range = {7, nil}, exp_worth = 2,
	max_life = 250, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	stats = { str=25, dex=10, cun=8, mag=10, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 20,
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{ {type="weapon", subtype="greatmaul", defined="GREATMAUL_BILL_TRUNK", random_art_replace={chance=75}, autoreq=true}, },
	resolvers.drops{chance=100, nb=3, {ego_chance=100} },
	resolvers.drops{chance=100, nb=1, {defined="ROD_OF_RECALL"} },

	resolvers.talents{
		[Talents.T_RUSH]=3,
		[Talents.T_KNOCKBACK]=1,
	},
	inc_damage = { all = -50 },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=4, ai_move="move_astar", },

	on_die = function(self, who)
		game.state:activateBackupGuardian("ALUIN", 2, 35, "... and we thought the trollshaws were safer now!")
		game.player:resolveSource():setQuestStatus("start-allied", engine.Quest.COMPLETED, "trollshaws")
	end,
}

newEntity{ define_as = "ALUIN",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "human", unique = true,
	name = "Aluin the Fallen",
	display = "p", color=colors.VIOLET,
	desc = [[His once shining armour now dull and bloodstained, this sun paladin has given in to despair.]],
	level_range = {35, nil}, exp_worth = 3,
	max_life = 350, life_rating = 23, fixed_rating = true,
	hate_regen = 10,
	stats = { str=25, dex=10, cun=8, mag=10, con=20 },
	rank = 4,
	size_category = 3,
	infravision = 20,
	instakill_immune = 1,
	blind_immune = 1,
	see_invisible = 30,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="waraxe", ego_chance=100, autoreq=true},
		{type="armor", subtype="shield", defined="SANGUINE_SHIELD", random_art_replace={chance=65}, autoreq=true},
		{type="armor", subtype="massive", ego_chance=100, autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_MASSIVE_ARMOUR_TRAINING]=5,
		[Talents.T_WEAPON_COMBAT]=6,
		[Talents.T_WEAPONS_MASTERY]=6,
		[Talents.T_RUSH]=4,

		[Talents.T_ENRAGE]=3,
		[Talents.T_SUPPRESSION]=4,
		[Talents.T_BLINDSIDE]=4,
		[Talents.T_GLOOM]=4,
		[Talents.T_WEAKNESS]=4,
		[Talents.T_TORMENT]=4,
		[Talents.T_LIFE_LEECH]=4,

		[Talents.T_CHANT_OF_LIGHT]=5,
		[Talents.T_SEARING_LIGHT]=5,
		[Talents.T_MARTYRDOM]=5,
		[Talents.T_BARRIER]=5,
		[Talents.T_WEAPON_OF_LIGHT]=5,
		[Talents.T_CRUSADE]=8,
		[Talents.T_FIREBEAM]=7,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_astar", },
}
