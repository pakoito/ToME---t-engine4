-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

if not currentZone.is_collapsed then
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
else
	load("/data/general/npcs/canine.lua", rarity(6))
	load("/data/general/npcs/snake.lua", rarity(4))
	load("/data/general/npcs/ooze.lua", rarity(3))
	load("/data/general/npcs/jelly.lua", rarity(3))
	load("/data/general/npcs/thieve.lua", rarity(0))
	load("/data/general/npcs/horror-corrupted.lua", rarity(0))
	load("/data/general/npcs/horror_temporal.lua", rarity(1))

	load("/data/general/npcs/all.lua", rarity(4, 35))
end

local Talents = require("engine.interface.ActorTalents")

-- The boss of the maze, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "HORNED_HORROR",
	allow_infinite_dungeon = true,
	type = "horror", subtype = "corrupted", unique = true,
	name = "Horned Horror",
	display = "h", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_corrupted_horner_horror.png", display_h=2, display_y=-1}}},
	desc = [[Some horrible power has twisted this brutish minotaur into something altogether more terrifying. Huge tentacles undulate from its back as it clenches and unclenches its powerful fists.]],
	killer_message = "and revived as a mindless horror",
	level_range = {12, nil}, exp_worth = 2,
	max_life = 250, life_rating = 17, fixed_rating = true,
	stats = { str=20, dex=20, cun=20, mag=10, wil=10, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 10,
	move_others=true,
	instakill_immune = 1,
	blind_immune = 1,
	no_breath = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HANDS=1, },
	resolvers.equip{
		{type="armor", subtype="hands", defined="STORM_BRINGER_GAUNTLETS", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	combat_mindpower = 20,
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=3, every=9, max=4},
		[Talents.T_UNARMED_MASTERY]={base=2, every=6, max=5},
		[Talents.T_UPPERCUT]={base=2, every=6, max=5},
		[Talents.T_DOUBLE_STRIKE]={base=2, every=6, max=5},
		[Talents.T_SPINNING_BACKHAND]={base=1, every=6, max=5},
		[Talents.T_FLURRY_OF_FISTS]={base=1, every=6, max=5},
		[Talents.T_VITALITY]={base=2, every=6, max=5},
		[Talents.T_TENTACLE_GRAB]={base=1, every=6, max=5},
	},

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(2, {"invisibility rune", "lightning rune"}),

	on_die = function(self, who)
		game.state:activateBackupGuardian("NIMISIL", 2, 40, "Have you hard about the patrol that disappeared in the maze in the west?")
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "maze")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "maze-horror")
	end,
}

-- The boss of the maze, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "MINOTAUR_MAZE",
	allow_infinite_dungeon = true,
	type = "giant", subtype = "minotaur", unique = true,
	name = "Minotaur of the Labyrinth",
	display = "H", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_minotaur_minotaur_of_the_labyrinth.png", display_h=2, display_y=-1}}},
	desc = [[A fearsome bull-headed monster, he swings a mighty axe as he curses all who defy him.]],
	killer_message = "and hung on a wall-spike",
	level_range = {12, nil}, exp_worth = 2,
	max_life = 250, life_rating = 17, fixed_rating = true,
	max_stamina = 200,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 10,
	move_others=true,
	instakill_immune = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, },
	resolvers.equip{
		{type="weapon", subtype="battleaxe", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="head", defined="HELM_OF_GARKUL", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=1, every=9, max=4},
		[Talents.T_STAMINA_POOL]={base=1, every=6, max=5},
		[Talents.T_WARSHOUT]={base=1, every=6, max=5},
		[Talents.T_STUNNING_BLOW]={base=1, every=6, max=5},
		[Talents.T_SUNDER_ARMOUR]={base=1, every=6, max=5},
		[Talents.T_SUNDER_ARMS]={base=1, every=6, max=5},
		[Talents.T_CRUSH]={base=1, every=6, max=5},
	},

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(2, "infusion"),

	on_die = function(self, who)
		game.state:activateBackupGuardian("NIMISIL", 2, 40, "Have you hard about the patrol that disappeared in the maze in the west?")
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "maze")
	end,
}

newEntity{ base = "BASE_NPC_SPIDER", define_as = "NIMISIL",
	unique = true,
	allow_infinite_dungeon = true,
	name = "Nimisil", color=colors.VIOLET,
	desc = [[Covered by eerie luminescent growths and protuberances, this spider now haunts the maze's silent passageways.]],
	level_range = {43, nil}, exp_worth = 3,
	max_life = 520, life_rating = 21, fixed_rating = true,
	rank = 4,
	negative_regen = 40,
	positive_regen = 40,

	move_others=true,
	instakill_immune = 1,

	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="LUNAR_SHIELD", random_art_replace={chance=75}} },

	combat_armor = 25, combat_def = 33,

	combat = {dam=80, atk=30, apr=15, dammod={mag=1.1}, damtype=DamageType.ARCANE},

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(5, {}),
	inc_damage = {all=40},

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=5, every=5, max=7},
		[Talents.T_LAY_WEB]={base=5, every=5, max=7},
		[Talents.T_PHASE_DOOR]={base=5, every=5, max=7},

		[Talents.T_HYMN_OF_MOONLIGHT]={base=5, every=5, max=7},
		[Talents.T_MOONLIGHT_RAY]={base=5, every=5, max=7},
		[Talents.T_SHADOW_BLAST]={base=5, every=5, max=7},

		[Talents.T_SEARING_LIGHT]={base=5, every=5, max=7},
	},
}
