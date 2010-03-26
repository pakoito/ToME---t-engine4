load("/data/general/npcs/vermin.lua")
load("/data/general/npcs/rodent.lua")
load("/data/general/npcs/canine.lua")
load("/data/general/npcs/snake.lua")
load("/data/general/npcs/ooze.lua")
load("/data/general/npcs/jelly.lua")
load("/data/general/npcs/ant.lua")
load("/data/general/npcs/thieve.lua")
load("/data/general/npcs/minotaur.lua")

local Talents = require("engine.interface.ActorTalents")

-- The boss of the maze, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "MINOTAUR_MAZE",
	type = "giant", subtype = "minotaur", unique = true,
	name = "Minotaur of the Labyrinth",
	display = "H", color=colors.VIOLET,
	desc = [[A fearsome bull-headed monster, he swings a mighty axe as he curses all that defy him.]],
	level_range = {12, 18}, exp_worth = 2,
	max_life = 250, life_rating = 17, fixed_rating = true,
	max_stamina = 200,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="battleaxe"},
		{type="armor", subtype="head", defined="HELM_OF_HAMMERHAND"},
	},
	drops = resolvers.drops{chance=100, nb=5, {ego_chance=100} },

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
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },

	on_die = function(self, who)
		who:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "maze")
	end,
}
