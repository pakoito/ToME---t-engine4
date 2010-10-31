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

load("/data/general/npcs/vermin.lua", rarity(5))
load("/data/general/npcs/rodent.lua", rarity(5))
load("/data/general/npcs/canine.lua", rarity(6))
load("/data/general/npcs/snake.lua", rarity(4))
load("/data/general/npcs/ooze.lua", rarity(3))
load("/data/general/npcs/jelly.lua", rarity(3))
load("/data/general/npcs/ant.lua", rarity(4))
load("/data/general/npcs/thieve.lua", rarity(0))
load("/data/general/npcs/minotaur.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

-- The boss of the maze, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "MINOTAUR_MAZE",
	type = "giant", subtype = "minotaur", unique = true,
	name = "Minotaur of the Labyrinth",
	display = "H", color=colors.VIOLET,
	desc = [[A fearsome bull-headed monster, he swings a mighty axe as he curses all that defy him.]],
	level_range = {12, 35}, exp_worth = 2,
	max_life = 250, life_rating = 17, fixed_rating = true,
	max_stamina = 200,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 20,
	move_others=true,
	instakill_immune = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, },
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
		{type="armor", subtype="head", defined="HELM_OF_HAMMERHAND", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_HEAVY_ARMOUR_TRAINING]=1,
		[Talents.T_STAMINA_POOL]=1,
		[Talents.T_WARSHOUT]=1,
		[Talents.T_STUNNING_BLOW]=1,
		[Talents.T_SUNDER_ARMOUR]=1,
		[Talents.T_SUNDER_ARMS]=1,
		[Talents.T_CRUSH]=1,
	},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar", },

	on_die = function(self, who)
		game.state:activateBackupGuardian("NIMISIL", rng.range(1, 5), 40, "Have you hard about the patrol that disappeared in the maze in the west?")
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "maze")
	end,
}

newEntity{ base = "BASE_NPC_SPIDER", define_as = "NIMISIL",
	name = "Nimisil", color=colors.VIOLET,
	desc = [[Covered by eerie luminescent growths and protuberances, this spider now haunts the maze's silent passageways.]],
	level_range = {43, nil}, exp_worth = 3,
	max_life = 520, life_rating = 21, fixed_rating = true,
	rank = 4,
	negative_regen = 40,
	positive_regen = 40,

	move_others=true,
	instakill_immune = 1,

	resolvers.drops{chance=100, nb=5, {ego_chance=100} },
	resolvers.drops{chance=100, nb=1, {defined="LUNAR_SHIELD", random_art_replace={chance=75}} },

	combat_armor = 25, combat_def = 33,

	combat = {dam=80, atk=30, apr=15, dammod={mag=1.1}, damtype="ARCANE"},

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar", },
	inc_damage = {all=40},

	resolvers.talents{
		[Talents.T_SPIDER_WEB]=5,
		[Talents.T_LAY_WEB]=5,
		[Talents.T_PHASE_DOOR]=5,

		[Talents.T_HYMN_OF_MOONLIGHT]=4,
		[Talents.T_MOONLIGHT_RAY]=5,
		[Talents.T_SHADOW_BLAST]=5,

		[Talents.T_SEARING_LIGHT]=4,
	},
}
